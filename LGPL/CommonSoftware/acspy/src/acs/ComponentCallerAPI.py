import simplejson as json
import traceback
import time
import asyncio

from xml.dom.minidom import parseString

import tornado.ioloop
import tornado.web
import tornado.gen
import tornado.concurrent

from concurrent.futures import ThreadPoolExecutor

import threading

import ACS, ACS__POA

from Acspy.Servants.ContainerServices import ContainerServices
from Acspy.Servants.ComponentLifecycle import ComponentLifecycle
from Acspy.Servants.ACSComponent import ACSComponent

from .JSONUtil import AcsJsonEncoder, AcsJsonDecoder

class ComponentCallerAPI(ACS__POA.ACSComponent,
                         ACSComponent,
                         ContainerServices,
                         ComponentLifecycle):

    def __init__(self):
        ACSComponent.__init__(self)
        ContainerServices.__init__(self)

        self.event_loop = asyncio.new_event_loop()
        self.service = TornadoThread(self)
        self.service.daemon = True
        self.policies = None

    def initialize(self):
        try:
            dom = parseString(self.getCDBRecord('alma/ComponentCallerAPI'))
            self.policies = self._parse_access_policies_from_dom(dom)
        except:
            self.policies = None
        self.service.start()

    def cleanUp(self):
        self.event_loop.stop()

    def isAuthorized(self, comp_name, method_name):
        #If AccessPolicies tag is not present, everything is authorized
        if self.policies is None:
            return True

        #If AccessPolicies tag is present, but empy, nothing is authorized
        if len(self.policies) == 0:
            return False

        try:
            comp_type = self.availableComponents(comp_name)[0].type
        except:
            comp_type = None

        for pol in self.policies:
            if 'name' in pol and 'type' in pol:
                if comp_name == pol['name'] and comp_type == pol['type']:
                    if len(pol['methods']) == 0 or method_name in pol['methods']:
                        return True
            elif 'name' in pol:
                if comp_name == pol['name']:
                    if len(pol['methods']) == 0 or method_name in pol['methods']:
                        return True
            elif 'type' in pol:
                if comp_type == pol['type']:
                    if len(pol['methods']) == 0 or method_name in pol['methods']:
                        return True

        return False

    def _parse_access_policies_from_dom(self, dom):
        allowed_access = []
        policies = dom.getElementsByTagName('AccessPolicies')

        if len(policies) == 0:
            return None

        components = policies[0].getElementsByTagName('Component')
        for comp in components:
            c = {}
            if comp.hasAttribute('name'):
                c['name'] = comp.getAttribute('name')
            if comp.hasAttribute('type'):
                c['type'] = comp.getAttribute('type')
            c['methods'] = []

            methods = comp.getElementsByTagName('Method')
            for m in methods:
                c['methods'].append(m.getAttribute('name'))
            allowed_access.append(c)

        return allowed_access

class TornadoThread(threading.Thread):
    def __init__(self, services):
        threading.Thread.__init__(self)
        self.services = services
        self.event_loop = services.event_loop

    def run(self):
        asyncio.set_event_loop(self.event_loop)
        app = tornado.web.Application([
            (r"/", CorbaHandler, {'services': self.services}),
            (r"/async/", CorbaAsyncHandler, {'services': self.services}),
        ])

        # TODO: parametrize server port using CDB
        LISTENING_IP = '0.0.0.0'
        LISTENING_PORT = 9000

        app.listen(LISTENING_PORT)

        print(('== Server listening in {0}:{1}'.format(LISTENING_IP, LISTENING_PORT)))
        tornado.ioloop.IOLoop.current().start()


# -----------------------------------------------
#                   Handlers
# -----------------------------------------------

class JsonHandler(tornado.web.RequestHandler):
    def set_default_headers(self):
        self.set_header('Content-Type', 'application/json')

    def prepare(self):
        if self.request.body:
            try:
                json_data = json.loads(self.request.body)
                self.request.arguments.update(json_data)
            except ValueError:
                raise tornado.web.HTTPError(
                    status_code=400, reason='Unable to parse JSON body')

    def write_error(self, status_code, **kwargs):
        if "exc_info" in kwargs:

            # in debug mode, try to send a traceback
            lines = []

            for line in traceback.format_exception(*kwargs["exc_info"]):
                lines.append(line)

            self.finish(json.dumps({
                'error': {
                    'code': status_code,
                    'message': self._reason,
                    'traceback': lines,
                }
            }))

        else:
            self.finish(json.dumps({
                'error': {
                    'code': status_code,
                    'message': self._reason,
                }
            }))

    def write_json(self, data, status_code=200):
        self.set_status(status_code)
        self.write(json.dumps(obj=data, cls=AcsJsonEncoder))

class MyCBvoid(ACS__POA.CBvoid):
    def __init__ (self, propName = None): 
        self.is_done = False
        self.value = "void"
        if propName != None:
            self.propName = propName
        else:
            self.propName = "NoName"
    def working (self, completion, desc):
        pass
    def done (self,  completion, desc):
        self.is_done = True 
    def negotiate (self, time_to_transmit, desc):
        return TRUE

class MyCBdouble(ACS__POA.CBdouble):
    def __init__ (self, propName = None): 
        self.is_done = False
        self.value = None
        if propName != None:
            self.propName = propName
        else:
            self.propName = "NoName"
        
    def working (self, value, completion, desc):
        pass
    def done (self, value, completion, desc):
        self.is_done = True 
        self.value = value
    def negotiate (self, time_to_transmit, desc):
        return TRUE

class CorbaAsyncHandler(JsonHandler):
    MAX_ATTEMPTS = 5
    executor = ThreadPoolExecutor()

    def initialize(self, services):
        self.services = services

    @tornado.concurrent.run_on_executor
    def corba_async_invoke(self, component_name, property_name, cb, arguments):
        params = json.loads(s=json.dumps(arguments), cls=AcsJsonDecoder)
        corba_params = []

        for key, value in params.items():
            corba_params.append(value)

        corba_component = self.services.getComponentNonSticky(component_name)
        corba_method = getattr(corba_component, property_name)
        
        cbServant = self.services.activateOffShoot(cb)        
        desc = ACS.CBDescIn(0,0,0)
        corba_method(*corba_params,cbServant,desc)

        counter = 0
        while not cb.is_done:
            time.sleep(1)
            counter+=1
            if counter >= CorbaAsyncHandler.MAX_ATTEMPTS:
                break

        if cb.is_done:
           return {'message': 'done', 'value': cb.value}
        else:
           return {'message': 'unknown'}

    @tornado.gen.coroutine
    def post(self):
        if not self.request.body:
            raise tornado.web.HTTPError(
                status_code=400, reason='Invalid arguments provided')

        body = json.loads(self.request.body)

        try:
            component_name = str(body['componentName'])
            method_name = str(body['methodName'])
            cb_type = str(body['cb_type'])
            arguments = body['arguments']
        except:
            raise tornado.web.HTTPError(
                status_code=400, reason='Invalid request format')

        if cb_type == "CBvoid":
            cb = MyCBvoid(method_name)
        elif cb_type == "CBdouble":
            cb = MyCBdouble(method_name)
        else:
            raise tornado.web.HTTPError(
                status_code=400, reason='Invalid callback type')

        if not self.services.isAuthorized(component_name, method_name):
            raise tornado.web.HTTPError(status_code=403, reason="The request to '%s' method of '%s' component is not authorized." % (method_name, component_name))

        corba_response = yield self.corba_async_invoke(component_name, method_name, cb, arguments)

        # Response is written by callback
        self.write_json(data={
            'data': corba_response
        })

class CorbaHandler(JsonHandler):
    executor = ThreadPoolExecutor()

    def initialize(self, services):
        self.services = services

    @tornado.concurrent.run_on_executor
    def corba_invoke(self, component_name, method_name, arguments):

        params = json.loads(s=json.dumps(arguments), cls=AcsJsonDecoder)
        corba_params = []

        for key, value in params.items():
            corba_params.append(value)

        corba_component = self.services.getComponentNonSticky(component_name)
        corba_method = getattr(corba_component, method_name)

        return corba_method(*corba_params)
    @tornado.gen.coroutine
    def post(self):
        if not self.request.body:
            raise tornado.web.HTTPError(
                status_code=400, reason='Invalid arguments provided')

        body = json.loads(self.request.body)

        try:
            component_name = str(body['componentName'])
            method_name = str(body['methodName'])
            arguments = json.loads(str(body['arguments']))
        except:
            raise tornado.web.HTTPError(
                status_code=400, reason='Invalid request format')

        if not self.services.isAuthorized(component_name, method_name):
            raise tornado.web.HTTPError(status_code=403, reason="The request to '%s' method of '%s' component is not authorized." % (method_name, component_name))

        corba_response = yield self.corba_invoke(component_name, method_name, arguments)

        self.write_json(data={
            'data': corba_response
        })

