from Acspy.Servants.ContainerServices import ContainerServices
from Acspy.Servants.ComponentLifecycle import ComponentLifecycle
from Acspy.Servants.ACSComponent import ACSComponent
from Acspy.Nc.Consumer import Consumer

from threading import Lock
from importlib import import_module
from acs.JSONUtil import AcsJsonEncoder
from xml.dom.minidom import parseString

import ACS__POA

import os
import json
import time
import redis
import traceback

def expand_vars(in_var, local_env=None, depth=100):
    #Props can be dict, list or string
    if isinstance(in_var, dict):
        props = in_var
    elif isinstance(in_var, list):
        props = { str(idx) : x for idx, x in enumerate(in_var) }
    elif isinstance(in_var, str):
        props = {"str" : in_var}
    else:
        raise Exception("The received type can't be expanded: " + str(type(in_var)))

    #Backup original environment variables
    tmp_env = os.environ

    #Replace local variables up-to 'depth' nested levels
    if local_env is not None:
        os.environ = local_env
        for k in props:
            for i in range(depth):
                props[k] = os.path.expandvars(props[k])
        os.environ = tmp_env

    #Replace environment variables
    for k in props:
        props[k] = os.path.expandvars(props[k])

    #Return result with the same type as the input
    if isinstance(in_var, dict):
        return props
    elif isinstance(in_var, list):
        return list(props.values())
    elif isinstance(in_var, str):
        return props["str"]

def __create_pubsub_handler__(logger, ps_queue, redis_ref, channel_name):
    """
    Creates a handler according to the Notification channel client API

    :param redis_ref: the reference to redis connection
    :param channel_name: the name of the channel to create a handler function
    :return: the function reference to a notification channel handler
    """

    ps_queue_lock = ps_queue.pop()

    def _pubsub_publish_queue():
        while ps_queue:
            redis_ref.publish(channel_name, json.dumps(obj=ps_queue[0], cls=AcsJsonEncoder))
            ps_queue.pop(0)

    def _handler(event):
        """
        This event handler converts the event into JSON

        :param event: the actual event
        """
        logger.logInfo("Handling of PubSub events on channel '%s'. Event: %s" % (channel_name, str(event)))
        with ps_queue_lock:
            ps_queue.append(event)
            try:
                _pubsub_publish_queue()
            except Exception as e:
                logger.logWarning("Retrying in 1 second due to problems (%s) during handling of PubSub events on channel '%s'. Event: %s" % (str(e), channel_name, str(event)))
                try:
                    time.sleep(1)
                    _pubsub_publish_queue()
                except Exception as e:
                    logger.logError("Error (%s) during handling of PubSub events on channel '%s'. Event: %s" % (str(e), channel_name, str(event)))

    return _handler

def __create_reliable_subscriber_handler__(logger, rs_queue, redis_ref, rs_name, options):
    """
    Creates a handler according to the Notification channel client API

    :param redis_ref: the reference to redis connection
    :param channel_name: the name of the channel to create a handler function
    :return: the function reference to a notification channel handler
    """
    queue_limit = int(options.get('queueLimit')) if options.get('queueLimit') else 10000
    rs_queue_lock = rs_queue.pop()

    def _rs_lpush_queue():
        while rs_queue:
            redis_ref.lpush(rs_name, json.dumps(obj=rs_queue[0], cls=AcsJsonEncoder))
            rs_queue.pop(0)

            # check defined queue limit and trim it if exceeded
            queue_length = redis_ref.llen(rs_name)

            if queue_length > queue_limit:
                logger.logWarning("Queue limit reached during handling of ReliableSubscriber event on service '%s'. Removing oldest element from list. Event: %s" % (rs_name, str(event)))
                redis_ref.ltrim(rs_name, 0, queue_limit - 1)

    def _handler(event):
        """
        This event handler converts the event into JSON

        :param event: the actual event
        """

        logger.logInfo("Handling of ReliableSubscriber event on service '%s'. Event: %s" % (rs_name, str(event)))
        with rs_queue_lock:
            rs_queue.append(event)
            try:
                _rs_lpush_queue()
            except Exception as e:
                logger.logWarning("Retrying in 1 second due to problems (%s) during handling of ReliableSubscriber events on service '%s'. Event: %s" % (str(e), rs_name, str(event)))
                try:
                    time.sleep(1)
                    _rs_lpush_queue()
                except Exception as e:
                    logger.logError("Error (%s) during handling of ReliableSubscriber events on service '%s'. Event: %s" % (str(e), rs_name, str(event)))

    return _handler

class EventConverter(ACS__POA.ACSComponent,
                     ACSComponent,
                     ContainerServices,
                     ComponentLifecycle):
    """
    ACS component intended to convert the ACS Notification Channel Events into redis pubsub messages

    The definition of what channels and event types can be setup if the ACS CDB XML Doc of this component e.g:
    ``/alma/EventConverter``. The following is an example of how the component should be configured:

        <?xml version="1.0" encoding="ISO-8859-1"?>
        <EventConverter xmlns="urn:schemas-cosylab-com:EventConverter:1.0"
                    xmlns:baci="urn:schemas-cosylab-com:BACI:1.0"
                    xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

            <RedisConn host="localhost" port="6379"/>
            <PubSub>
                <Channel name="CONTROL_SYSTEM">
                    <EventType type="Control.ExecBlockStartedEvent"/>
                    <EventType type="Control.ExecBlockEndedEvent"/>
                    <EventType type="Control.ASDMArchivedEvent"/>
                </Channel>
                <Channel name="ShiftlogScriptInformation">
                    <EventType type="obops.ScriptInformationEvent"/>
                </Channel>
                <Channel name="TelCalPublisherEventNC">
                    <EventType type="telcal.WVRReducedEvent"/>
                </Channel>
                <Channel name="SCHEDULING_CHANNEL">
                    <EventType type="scheduling.CreatedArrayEvent"/>
                    <EventType type="scheduling.DestroyedArrayEvent"/>
                    <EventType type="scheduling.StartSessionEvent"/>
                </Channel>
            </PubSub>
            <ReliableSubscribers>
                <Subscriber name="slt" queueLimit="10">
                    <Channel name="SCHEDULING_CHANNEL">
                        <EventType type="scheduling.CreatedArrayEvent"/>
                        <EventType type="scheduling.DestroyedArrayEvent"/>
                        <EventType type="scheduling.StartSessionEvent"/>
                    </Channel>
                    <Channel name="TelCalPublisherEventNC">
                        <EventType type="telcal.WVRReducedEvent"/>
                    </Channel>
                </Subscriber>
            </ReliableSubscribers>
        </EventConverter>

    The Event Converter component will listen the given Notification channel, then convert the events into JSON
    format with the following structure:
    * A meta section for metadata structures, like the ``type`` of the event, which can be used later to decode the
    JSON Object
    * A Data section contained the event converted to JSON format

    Finally the JSON Object is forwarded to redis using the same channel name defined in the configuration.

    If you want to receive the messages in redis, please review the Redis pubsub API.
    """

    def __init__(self):
        ACSComponent.__init__(self)
        ContainerServices.__init__(self)

        # Keeps track of consumer instances
        self._consumers = {}

        # Reference to redis connection
        self.redis_ref = None

        # PubSub queues
        self.ps_queue = {}

        # Reliable Subscriber queues
        self.rs_queue = {}

    def _parse_metadata_properties_from_dom(self, dom):
        """
        Return datastruct to store properties to be propagated with events as metadata
        """
        parent_node = dom.getElementsByTagName('Metadata')[0]
        properties = {}

        if not parent_node:
            return properties

        props = parent_node.getElementsByTagName('Property')

        for prop in props:
            properties[prop.getAttribute('name')] = prop.getAttribute('value')

        properties = expand_vars(properties, properties)

        return properties

    def _parse_reliable_subscribers_from_dom(self, dom):
        """
        Return datastruct to store for each Reliable Subscriber the events to be listened to each channel
        """

        parent_node = dom.getElementsByTagName('ReliableSubscribers')[0]

        if not parent_node:
            return {}

        reliable_subscribers = {}
        subscribers = parent_node.getElementsByTagName('Subscriber')

        for sub in subscribers:
            sub_name = sub.getAttribute('name')
            reliable_subscribers[sub_name] = {}

            sub_channels = sub.getElementsByTagName('Channel')

            for sub_channel in sub_channels:
                sub_channel_name = sub_channel.getAttribute('name')
                reliable_subscribers[sub_name][sub_channel_name] = []

                sub_events = sub_channel.getElementsByTagName('EventType')

                reliable_subscribers[sub_name][sub_channel_name] = list(map(lambda e: e.getAttribute('type'), sub_events))

        return reliable_subscribers

    def _parse_reliable_subscribers_options_from_dom(self, dom):
            """
            Return datastruct to store for each Reliable Subscriber the events to be listened to each channel
            """

            parent_node = dom.getElementsByTagName('ReliableSubscribers')[0]

            if not parent_node:
                return {}

            reliable_subscribers_options = {}
            subscribers = parent_node.getElementsByTagName('Subscriber')

            for sub in subscribers:
                sub_name = sub.getAttribute('name')
                reliable_subscribers_options[sub_name] = dict(filter(lambda x: x[0] != 'name', sub.attributes.items()))

            return reliable_subscribers_options

    def _parse_pubsub_from_dom(self, dom):
        """
        Return datastruct to store pubsub related subscriptions
        """

        parent_node = dom.getElementsByTagName('PubSub')[0]

        if not parent_node:
            return {}

        pubsub = {}

        sub_channels = parent_node.getElementsByTagName('Channel')

        for sub_channel in sub_channels:
            sub_channel_name = sub_channel.getAttribute('name')
            pubsub[sub_channel_name] = []

            sub_events = sub_channel.getElementsByTagName('EventType')

            pubsub[sub_channel_name] = list(map(lambda e: e.getAttribute('type'), sub_events))

        return pubsub


    def _get_acs_module_from_string(self, s):
        module_str_index = s.rfind('.')

        if module_str_index == 0:
            return None

        module_name = s[:module_str_index]

        return import_module(module_name)

    def _get_acs_class_from_string(self, s):
        class_str_index = s.rfind('.')

        if class_str_index == 0:
            return None

        acs_module = self._get_acs_module_from_string(s)

        return acs_module.__dict__[s[class_str_index + 1:]]

    def initialize(self):
        """
        Read configuration from CDB
        Initializes redis connection and consumers connecting them into the ACS Notification Channel
        """
        dom = parseString(self.getCDBRecord('alma/EventConverter'))

        # define metadata properties
        properties = self._parse_metadata_properties_from_dom(dom)
        AcsJsonEncoder.setProperties(properties)

        redis_node = dom.getElementsByTagName('RedisConn')

        self.getLogger().logInfo("Connecting to redis with following parameters host=%s, port=%s"
                                % (redis_node[0].getAttribute('host'),
                                   str(redis_node[0].getAttribute('port'))))

        self.redis_ref = redis.StrictRedis(host=redis_node[0].getAttribute('host'),
                                           port=redis_node[0].getAttribute('port'))

        topic_prefix = expand_vars(redis_node[0].getAttribute('prefix'), properties, 1)
        topic_suffix = expand_vars(redis_node[0].getAttribute('suffix'), properties, 1)

        self.getLogger().logInfo('Read CDB Node subscribers configuration')

        # define pubsub subscriptions:
        pubsub = self._parse_pubsub_from_dom(dom)

        for channel_name, events in pubsub.items():
            if not channel_name in self._consumers:
                self._consumers[channel_name] = Consumer(channel_name)

            for event in events:
                try:
                    ps_channel_event = channel_name + "_" + event
                    self.ps_queue[ps_channel_event] = [Lock()]
                    clazz = self._get_acs_class_from_string(event)

                    redis_channel_name = topic_prefix + channel_name + topic_suffix
                    funczz = __create_pubsub_handler__(self.getLogger(), self.ps_queue[ps_channel_event], self.redis_ref, redis_channel_name)

                    self.getLogger().logInfo('[PubSub] Registering %s, %s' % (clazz, funczz))

                    self._consumers[channel_name].addSubscription(clazz, funczz)
                except Exception as e:
                    self.getLogger().logError("I have no idea how to handle a class outside a package. Help!")
                    traceback.print_exc()

        # define reliable subscriptions:
        reliable_subscribers = self._parse_reliable_subscribers_from_dom(dom)
        reliable_subscribers_options = self._parse_reliable_subscribers_options_from_dom(dom)

        for rs_name, subscriptions in reliable_subscribers.items():
            rs_options = reliable_subscribers_options.get(rs_name) or {}

            for channel_name, events in subscriptions.items():
                rs_name_channel = rs_name + '_' + channel_name
                if not (rs_name_channel) in self._consumers:
                    self._consumers[rs_name_channel] = Consumer(channel_name)

                for event in events:
                    try:
                        rs_name_channel_event = rs_name_channel + "_" + event
                        self.rs_queue[rs_name_channel_event] = [Lock()]
                        clazz = self._get_acs_class_from_string(event)
                        # create a new event handler function per event
                        redis_rs_name = topic_prefix + rs_name + topic_suffix
                        funczz = __create_reliable_subscriber_handler__(self.getLogger(), self.rs_queue[rs_name_channel_event], self.redis_ref, redis_rs_name, rs_options)

                        self.getLogger().logInfo('[Reliable Subscribers] Registering for queue %s: %s, %s' % (rs_name, clazz, funczz))

                        self._consumers[rs_name_channel].addSubscription(clazz, funczz)
                    except Exception as e:
                        self.getLogger().logError("I have no idea how to handle a class outside a package. Help!")
                        traceback.print_exc()

        # Start all consumers:
        for consumer in self._consumers.values():
            consumer.consumerReady()

    def cleanUp(self):
        for consumer in self._consumers.values():
            consumer.disconnect()
