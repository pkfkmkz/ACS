#!/alma/ACS-current/Python/bin/python
from xml.dom import minidom
from xml.dom.minidom import Document, Element
import socket
import datetime
import os
import re
import sys


class TestSuite:

    _illegal_xml_chars_RE = re.compile('[\x00-\x08\x0b\x0c\x0e-\x1F\uD800-\uDFFF\uFFFE\uFFFF]')

    def __init__(self, stdout_str):
        """
        :type: stdout_str: str
        :param stdout_str:
        """
        # Attributes
        self.errors = 0
        self.failures = 0
        self.hostname = socket.gethostname()
        self.name = None
        self.path = None
        self.skipped = 0
        self.time = 0.0
        self.timestamp = datetime.datetime.utcnow().isoformat()[:19]
        self.system_out = stdout_str
        # Elements
        self.testcases = []
        """:type : list of [TestCase]"""
        # Internal fields
        self.xmldoc = minidom.Document()

    def to_xml_doc(self):
        """
        :rtype: Document
        """
        suite = self.xmldoc.createElement('testsuite')
        suite.setAttribute('errors', str(self.errors))
        suite.setAttribute('failures', str(self.failures))
        suite.setAttribute('hostname', self.hostname)
        suite.setAttribute('name', self.name)
        suite.setAttribute('skipped', str(self.skipped))
        suite.setAttribute('tests', str(len(self.testcases)))
        suite.setAttribute('time', str(self.time))
        suite.setAttribute('timestamp', self.timestamp)

        properties = self.xmldoc.createElement('properties')
        for key in os.environ:
            prop = self.xmldoc.createElement('property')
            prop.setAttribute('name', key)
            prop.setAttribute('value', os.environ[key])
            properties.appendChild(prop)
        suite.appendChild(properties)

        for tc in self.testcases:
            suite.appendChild(tc.to_xml_element(self.xmldoc))

        soe = self.xmldoc.createElement('system-out')
        outStr = ""
        for line in self.system_out:
            outStr = outStr + line
        soe.appendChild(self.xmldoc.createCDATASection(self._illegal_xml_chars_RE.sub('?',outStr)))
        suite.appendChild(soe)

        suite.appendChild(self.xmldoc.createElement('system-err'))

        self.xmldoc.appendChild(suite)

        return self.xmldoc

    def parse_sys_out(self):
        import re
        p = re.compile('TEST\d*\s+[\w&-]+\s+\w+\.(\t\d\d:\d\d:\d\d){0,1}')
        buff = []
        skipped = False
        for line in self.system_out:
            if line.startswith('############'):
                self.path = line.split(' ')[1]
                self.name = self.path.replace('/ws', '').replace('/test', '')
                print(line, self.name)
            elif not skipped and (line.startswith('Error: exec make all') or line.startswith('Error: The prologue script fails:')):
                buff.append(line)
                skipped = True
            elif p.match(line):
                buff.append(line)
                tc = TestCase(self.name, line, buff)
                tc.parse_sys_out()
                self.testcases.append(tc)
                if tc.error is not None:
                    self.errors += 1
                elif tc.failure is not None:
                    self.failures += 1
                elif tc.skipped is not None:
                    self.skipped += 1
            elif line.startswith('TEST NAME:'):
                buff = [line]
            else:
                buff.append(line)
        if skipped:
            testcases = self.get_suite_test_cases()
            for t in testcases:
                tc = TestCase(self.name, '', buff)
                tc.name = "TEST"+t[1]+"."+t[0]
                tc.skipped = True
                self.testcases.append(tc)
                print(tc.name)
                self.skipped += 1

    def get_suite_test_cases(self):
        import re
        import os.path
        testcases = []
        testsuite_file = None
        testlistnames = ['TestList', 'TestList.lite', 'TestList_WS.lite', 'TestList_BOTH.lite']
        for f in testlistnames:
            testlist = self.path + '/' + f
            if os.path.isfile(testlist):
                testsuite_file = testlist
                break
        if testsuite_file is not None:
            with open(testsuite_file, 'r') as fp:
                tl = fp.readlines()
            buf = None
            for line in tl:
                line = line.replace('\n', '').split('#', 1)[0].strip()
                if line == '':
                    pass
                elif line.endswith('\\'):
                    if buf is None:
                        buf = line
                    else:
                        buf = buf + line
                elif line.startswith('SOURCE '):
                    pass
                elif line.startswith('PROLOGUE '):
                    pass
                elif line.startswith('EPILOGUE '):
                    pass
                else:
                    if buf is not None:
                        line = buf.replace('\\', ' ') + line
                        buf = None
                    skipone = False
                    skipstr = False
                    n = ''
                    for word in line.split():
                        if skipstr:
                            if word.endswith('"'): skipstr = False
                        elif word.startswith('"'):
                            skipstr = True
                            skipone = False
                        elif skipone:
                            skipone = False
                        elif re.match(r'\d+', word):
                            n = word
                        elif word == 'SOURCE' or word == 'PROLOGUE' or word == 'EPILOGUE':
                            skipone = True
                        else:
                            testcases.append([word, n])
                            break
        return testcases

class TestCase:
    def __init__(self, module_name, stdout_line, stdout):
        """
        :type module_name: str
        :type stdout_line: str
        :type stdout: list of [str]
        """""
        # Attributes
        self.name = ''
        self.classname = module_name.replace('/', '.')
        self.time = 0.0
        # Elements
        self.error = None
        self.failure = None
        self.skipped = None
        """:type: Failure"""
        self.__stdout_line = stdout_line
        self.__stdout = stdout

    def to_xml_element(self, xmldoc):
        """
        :type xmldoc: Document
        :rtype: Element
        """
        tce = xmldoc.createElement('testcase')
        tce.setAttribute('name', self.name)
        tce.setAttribute('classname', self.classname)
        tce.setAttribute('time', str(self.time))
        if (self.error is not None) + (self.failure is not None) + (self.skipped is not None) > 1:
            raise MalformedException()
        if self.error is not None:
            ee = xmldoc.createElement('error')
            tce.appendChild(ee)
        elif self.failure is not None:
            tce.appendChild(self.failure.to_xml_element(xmldoc))
        elif self.skipped is not None:
            ee = xmldoc.createElement('skipped')
            ee.setAttribute('message', 'TestSuite failed to compile.')
            tce.appendChild(ee)
        else:
            pass

        return tce

    def parse_sys_out(self):
        r = self.__stdout_line.split(' ')
        self.name = r[0] + '.' + r[1]
        print(self.name)
        if r[2].startswith('FAILED'):
            diff_filepath = None
            # Differences found in <file>
            if len(self.__stdout) > 2 and self.__stdout[-2].startswith('Differences found in'):
                diff_filepath = self.__stdout[-2].split(' ')[3].rstrip()

            print("Diff file:", diff_filepath)
            self.failure = Failure(self.__stdout_line, diff_filepath)


class Failure:
    def __init__(self, line, diff_file):
        self.message = 'FAILED'
        self.type = 'TAT Failure'
        if diff_file is not None:
            import os.path
            if os.path.isfile(diff_file):
                enc = sys.getdefaultencoding()
                try:
                    with open(diff_file, 'r') as fp:
                        self.data = fp.read().encode('ascii', 'ignore').decode()
                except:
                    try:
                        with open(diff_file, 'r', encoding = 'iso-8859-1') as fp:
                            self.data = fp.read().encode('ascii', 'ignore').decode()
                    except:
                        with open(diff_file, 'rb') as check_enc:
                            import chardet
                            enc = chardet.detect(check_enc.read())['encoding']
                        with open(diff_file, 'r', encoding = enc) as fp:
                            self.data = fp.read().encode('ascii', 'ignore').decode()
            else:
                self.data = line.replace('\n', '')
        else:
            self.data = line.replace('\n', '')

    def to_xml_element(self, xmldoc):
        """
        :type xmldoc: Document
        :rtype: Element
        :param xmldoc:
        :return:
        """
        fe = xmldoc.createElement('failure')
        fe.setAttribute('message', self.message)
        fe.setAttribute('type', self.type)
        fe.appendChild(xmldoc.createTextNode(self.data))
        return fe


class ParseException(Exception):
    pass


class MalformedException(Exception):
    pass


def main():
    tatlog = open(sys.argv[1], 'r')
    testsuites_str = []
    buff = None
    tmp = None
    with tatlog:
        tmp = tatlog.readlines()[1:-1]

    for line in tmp:
        if line.startswith('######## ==>') or line.startswith('  ######## ==>'):
            # Ignore the modules without test structure
            pass
        elif line.startswith('############ DONE'):
            # Ignore submodules
            pass
        elif line.startswith('############ TEST'):
            # Ignore submodules
            pass
        elif line.startswith('############ Clean Test Log File:'):
            pass
        elif line.startswith('############'):
            if buff is not None:
                print(buff)
                testsuites_str.append(buff)
            buff = [line]
        elif line.startswith('  ############'):
            if buff is not None:
                print(buff)
                testsuites_str.append(buff)
            buff = [line[2:-1]]
        else:
            buff.append(line)
    if buff is not None and (len(buff) > 1):
        print(buff)
        testsuites_str.append(buff)

    test_suites = []
    """:type: list of [TestSuite]"""
    for tcs in testsuites_str:
        test_suites.append(TestSuite(tcs))

    jdir = 'junit'
    if os.path.exists(jdir):
        import shutil
        shutil.rmtree(jdir)
    os.makedirs(jdir)

    for ts in test_suites:
        ts.parse_sys_out()
        doc = ts.to_xml_doc()
        file_path = jdir + '/' + ts.name.replace('/', '.') + '.xml'
        xml_file = open(file_path, 'w')
        with xml_file:
            xml_file.write(doc.toprettyxml())

if __name__ == "__main__":
    main()
