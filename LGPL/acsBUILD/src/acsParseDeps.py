#! /usr/bin/env python
import os
import re
import sys
import glob
import zipfile
import argparse

from lxml import etree
import subprocess
from urllib.request import urlopen

ns = '{http://maven.apache.org/POM/4.0.0}'

def get_confluence_page(url):
    return str(urlopen(url).read()).replace('\n', ' ')

def get_table_element(el):
    text = el.text
    while text is None:
        if len(el.getchildren()) == 0: break
        el = el.getchildren()[0]
        text = el.text
    return el

def get_deps_from_confluence(url):
    dhtml = get_confluence_page(url)
    dtables = re.findall(r'<table[^>]*>.*?</table>', dhtml)
    deps = []
    for dt in [dtables[1]]:
        table = etree.HTML(dt).find("body/table")
        rows = iter(table.getchildren()[1])
        headers = [get_table_element(col).text for col in next(rows)]
        for row in rows:
            values = [get_table_element(col).text for col in row]
            if values[0] is not None: values[0] = values[0].strip().replace('\\xc2\\xa0', '')
            deps.append(dict(zip(headers, values)))
    cdeps = dict((d['Name'], dict(d, index=index)) for (index, d) in enumerate(deps))
    return cdeps

def get_pom():
    if 'ALMASW_INSTDIR' not in os.environ: return None
    poms_path = os.getenv('ACSDEPS')
    acs_pom = os.path.join(poms_path, 'acs-pom.xml')
    return (poms_path, acs_pom)

def get_pom_project(pom_file):
    pom = etree.parse(pom_file)
    return pom.getroot()

def get_deps_from_project(prj):
    deps = []
    for dep in prj.find('{}dependencies'.format(ns)).getchildren():
        if dep.tag != '{}dependency'.format(ns): continue
        deps.append({'Group': dep.find('{}groupId'.format(ns)).text ,'Name': dep.find('{}artifactId'.format(ns)).text, 'Current': dep.find('{}version'.format(ns)).text})
    return deps

def get_mods_from_project(prj):
    poms_path = get_pom()[0]
    mods = []
    for mod in prj.find('{}modules'.format(ns)).getchildren():
        mprj = get_pom_project(os.path.join(poms_path, mod.text, 'pom.xml'))
        mods.append({'Group': mprj.find('{}groupId'.format(ns)).text ,'Name': mprj.find('{}artifactId'.format(ns)).text, 'Current': mprj.find('{}version'.format(ns)).text.replace('-acs', '')})
    return mods

def get_deps_from_pom_file():
    prj = get_pom_project(get_pom()[1])
    if prj is None: return {}
    deps = get_deps_from_project(prj) + get_mods_from_project(prj)
    pdeps = dict((d['Name'], dict(d, index=index)) for (index, d) in enumerate(deps))
    return pdeps

def get_deps_from_reqs_file():
    acs_req = os.path.join(sys.prefix, 'acs-py.req')
    with open(acs_req, 'r') as f:
        reqs = f.read()[:-1]
    reqs = re.sub(r'#.*$', r'', reqs, flags=re.M)
    reqs = re.sub(r'^$\n', r'', reqs, flags=re.M)
    reqs = [{'Name':r.split('==')[0].lower().replace('_','-'), 'Current':r.split('==')[1]} for r in reqs.split('\n')]
    rdeps = dict((d['Name'], dict(d, index=index)) for (index, d) in enumerate(reqs))
    return rdeps

def get_deps_from_maven():
    if 'ALMASW_INSTDIR' not in os.environ: return []
    acs_pom = os.path.join(os.getenv('ACSDEPS'), 'acs-pom.xml')
    maven = subprocess.Popen('mvn -f ' + acs_pom + ' versions:display-dependency-updates -Dverbose=true', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    maven.wait()
    out = maven.stdout.read().decode(sys.getdefaultencoding()).replace('\\n', '\n')
    dout = out.replace('[INFO] ', '')
    index = dout.find('---------------------< alma.acs:acs-dependencies >----------------------')
    dout = dout[index:]
    index1 = dout.find('The following dependencies in Dependencies are using the newest version:') + len('The following dependencies in Dependencies are using the newest version:') + 1
    index2 = dout.find('The following dependencies in Dependencies have newer versions:') - 2
    index = dout.find('The following dependencies in Dependencies have newer versions:') + len('The following dependencies in Dependencies have newer versions:') + 1
    doutup = dout[index1:index2]
    dout = dout[index:]
    index = dout.find('------------------------------------------------------------------------') - 2
    dout = dout[:index]
    dout = re.sub(r'^  ', r'', dout, flags=re.M)
    dout = re.sub(r'\n +', r' ', dout, flags=re.M)
    doutup = re.sub(r'^  ', r'', doutup, flags=re.M)
    doutup = re.sub(r'\n +', r' ', doutup, flags=re.M)
    groups = re.findall(r'^([^:]+):([^ ]+) \.+ ([^ ]+) -> ([^ ]+)$', dout, flags=re.M)
    groupsup = re.findall(r'^([^:]+):([^ ]+) \.+ ([^ ]+)$', doutup, flags=re.M)
    dlist = [{'Group':x[0], 'Name':x[1], 'Current':x[2].replace('.Final', '').replace('.RELEASE', '').replace('-GA', ''), 'Latest':x[3].replace('.Final', '').replace('.RELEASE', '').replace('-GA', '')} for x in groups]
    dlist = dlist + [{'Group':x[0], 'Name':x[1], 'Current':x[2].replace('.Final', '').replace('.RELEASE', '').replace('-GA', ''), 'Latest':x[2].replace('.Final', '').replace('.RELEASE', '').replace('-GA', '')} for x in groupsup]
    pmdeps = dict((d['Name'], dict(d, index=index)) for (index, d) in enumerate(dlist))
    return pmdeps

def get_deps_from_pip():
    pip = subprocess.Popen('pip list -o --path ' + os.path.join(sys.prefix, 'lib/python' + str(sys.version_info.major) + '.' + str(sys.version_info.minor), 'site-packages'), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    pip.wait()
    out = pip.stdout.read().decode(sys.getdefaultencoding()).replace('\\n', '\n')
    dout = '\n'.join(out.split('\n')[2:-1])

    pip = subprocess.Popen('pip list -u --path ' + os.path.join(sys.prefix, 'lib/python' + str(sys.version_info.major) + '.' + str(sys.version_info.minor), 'site-packages'), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    pip.wait()
    out = pip.stdout.read().decode(sys.getdefaultencoding()).replace('\\n', '\n')
    doutup = '\n'.join(out.split('\n')[2:-1])

    groups = re.findall(r'^([^ ]+) *([^ ]+) *([^ ]+) *([^ ]+)$', dout, flags=re.M)
    groupsup = re.findall(r'^([^ ]+) *([^ ]+)$', doutup, flags=re.M)
    dlist = [{'Name':x[0].lower().replace('_','-'), 'Current':x[1], 'Latest':x[2]} for x in groups]
    dlist = dlist + [{'Name':x[0].lower().replace('_','-'), 'Current':x[1], 'Latest':x[1]} for x in groupsup]
    dlist = sorted(dlist, key = lambda x: x['Name'])
    pmdeps = dict((d['Name'], dict(d, index=index)) for (index, d) in enumerate(dlist))
    return pmdeps

def compare_confluence_with_package_manager(fdeps, cdeps, pmdeps, usedby):
    report = {}
    report['unhandled'] = [x for x in pmdeps if x not in fdeps and x not in ['pip']]
    report['missing'] = [x for x in fdeps if x not in cdeps]
    report['cleanup'] = [x for x in cdeps if x not in pmdeps and x not in fdeps]
    report['update'] = [x for x in pmdeps if x in cdeps and pmdeps[x]['Latest'] != cdeps[x]['Current'] and pmdeps[x]['Latest'] != cdeps[x]['Latest']]
    if len(usedby):
        report['used-acs'] = [x for x in fdeps if len(usedby[x]['acs']) > 0]
        report['used-almasw'] = [x for x in fdeps if len(usedby[x]['almasw']) > 0]
        report['not-used-acs'] = [x for x in fdeps if len(usedby[x]['acs']) == 0]
        report['not-used-almasw'] = [x for x in fdeps if len(usedby[x]['almasw']) == 0]
    return report

def print_report(report, fdeps, cdeps, pmdeps, usedby, isusedby):
    maxlen = len(max(list(cdeps.keys()) + list(pmdeps.keys()), key=len))
    strformat = '{:<' + str(maxlen)+ '} | {:<20} | {:<20}'
    linefeed = strformat.format('-'*maxlen, '-'*20, '-'*20)
    print("Missing entries in Confluence page: " + str(len(report['missing'])))
    if len(report['missing']) > 0:
        print(strformat.format('Name', 'Current', 'Latest'))
        print(linefeed)
        for k in report['missing']:
            print(strformat.format(k, str(pmdeps[k]['Current']), str(pmdeps[k]['Latest'])))
    print()
    print("Candidate Confluence page entries for cleaning up: " + str(len(report['cleanup'])))
    if len(report['cleanup']) > 0:
        print(strformat.format('Name', 'Current', 'Latest'))
        print(linefeed)
        for k in report['cleanup']:
            print(strformat.format(k, str(cdeps[k]['Current']), str(cdeps[k]['Current']) if cdeps[k]['Latest'] is None else str(cdeps[k]['Latest'])))
    print()
    print("Candidate Confluence page entries for updating information: " + str(len(report['update'])))
    if len(report['update']) > 0:
        print(strformat.format('Name', 'Current', 'Latest'))
        print(linefeed)
        for k in report['update']:
            print(strformat.format(k, str(pmdeps[k]['Current']), str(pmdeps[k]['Latest'])))
    print()
    print("Unhandled transitive dependencies: " + str(len(report['unhandled'])))
    if len(report['unhandled']) > 0:
        print(strformat.format('Name', 'Current', 'Latest'))
        print(linefeed)
        for k in report['unhandled']:
            print(strformat.format(k, str(pmdeps[k]['Current']), str(pmdeps[k]['Latest'])))
    print()

    if isusedby:
        print()
        maxlen = len(max(list(fdeps.keys()), key=len))
        strformat = '{:<' + str(maxlen)+ '} | {}'
        linefeed = strformat.format('-'*maxlen, '-'*20, '-'*20)
        print("ACS Modules using each dependency: " + str(len(report['used-acs'])))
        if len(report['used-acs']):
            print(strformat.format('Name', 'ACS'))
            print(linefeed)
            for k in report['used-acs']:
                print(strformat.format(k, str(usedby[k]['acs'])))
        print()
        print("Dependencies without explicit use on ACS: " + str(len(report['not-used-acs'])))
        if len(report['not-used-acs']):
            print(strformat.format('Name', 'ACS'))
            print(linefeed)
            for k in report['not-used-acs']:
                print(strformat.format(k, str(usedby[k]['acs'])))
        print()
        print("ALMA SW Subsystems using each dependency: " + str(len(report['used-almasw'])))
        if len(report['used-almasw']):
            print(strformat.format('Name', 'ALMA SW'))
            print(linefeed)
            for k in report['used-almasw']:
                print(strformat.format(k, str(usedby[k]['almasw'])))
        print()
        print("Dependencies without explicit use on ALMA SW: " + str(len(report['not-used-almasw'])))
        if len(report['not-used-almasw']):
            print(strformat.format('Name', 'ALMA SW'))
            print(linefeed)
            for k in report['not-used-almasw']:
                print(strformat.format(k, str(usedby[k]['almasw'])))


def get_used_by_analysis(deps, args):
    if args.java:
        return get_used_by_analysis_java(deps)
    if args.python:
        return get_used_by_analysis_python(deps)

def get_used_by_analysis_java(deps):
    if 'ALMASW_INSTDIR' not in os.environ: return {}
    usedby = {}
    tpkgs = []
    for dep in deps:
        jar = os.path.join(os.getenv('ACSDEPS'), 'lib', deps[dep]['Name']+'-'+deps[dep]['Current']+'.jar')
        if not os.path.exists(jar):
            jar = os.path.join(os.getenv('ACSDEPS'), 'lib', deps[dep]['Name']+'-'+deps[dep]['Current']+'-acs.jar')
        if not os.path.exists(jar):
            print('ERROR: The following JAR was not found on the system: ' + jar)
            jar = None
        usedby[dep] = {'Name': deps[dep]['Name'], 'Current': deps[dep]['Current'], 'jar':jar, 'pkgs': [], 'acs': [], 'almasw': []}
        if jar is not None:
            pkgs = get_pkgs_from_jar(jar)
            usedby[dep]['pkgs'] = pkgs
            tpkgs += pkgs
    tpkgs = sorted(list(set(tpkgs)))
    usedacs = get_used_by_acs_from_pkgs(tpkgs, java=True)
    usedalmasw = get_used_by_almasw_from_pkgs(tpkgs, java=True)
    for dep in deps:
        usedby[dep]['acs'] = sorted(list(set(sum([usedacs[p] for p in usedacs.keys() if p in usedby[dep]['pkgs']], []))))
        usedby[dep]['almasw'] = sorted(list(set(sum([usedalmasw[p] for p in usedalmasw.keys() if p in usedby[dep]['pkgs']], []))))
    return usedby

def get_used_by_acs_from_pkgs(pkgs, java=False, python=False):
    if java:
        return get_used_by_java_dir_from_pkgs('ACS/LGPL/', pkgs, exclude=None)
    if python:
        return get_used_by_python_dir_from_pkgs('ACS/LGPL/', pkgs, exclude=None)
    return {}

def get_used_by_almasw_from_pkgs(pkgs, java=False, python=False):
    if java:
        return get_used_by_java_dir_from_pkgs('', pkgs, exclude='ACS')
    if python:
        return get_used_by_python_dir_from_pkgs('', pkgs, exclude='ACS')
    return {}

def get_used_by_java_dir_from_pkgs(dirname, pkgs, exclude=None):
    if 'WORKDIR' not in os.environ: return {}
    if len(pkgs) == 0: return {}
    basepath = os.path.join(os.getenv('WORKDIR'), dirname)
    java_files = os.path.join(basepath, '**', '*.java')
    uses = {k: [] for k in pkgs}
    for java in glob.glob(java_files, recursive=True):
        javaname = java.replace(basepath, '').replace('/src-gen/', '/src/')
        if dirname == '':
            module = re.sub(r'([^/]+)/.*', r'\1', javaname)
        else:
            module = re.sub(r'(.*?)/(src|test)/.*', r'\2:\1', javaname)
        if exclude is not None and javaname.startswith(exclude): continue
        with open(java, 'r') as f:
            source = f.read()
        source = re.sub(r'//.*$', r'', source, flags=re.M)
        source = re.sub(r'/\*.*?\*/', r'', source, flags=re.M|re.DOTALL)
        reg = r'import *('+ re.escape(pkgs[0])
        for pkg in pkgs[1:]:
            reg += '|' + re.escape(pkg)
        reg += ').[^.]+;'
        result = sorted(list(set(re.findall(reg, source))))
        if result is not None and len(result) > 0:
            for pkg in result:
                uses[pkg].append(module)
    for pkg in uses:
        uses[pkg] = sorted(list(set(uses[pkg])))
    return uses

def get_pkgs_from_jar(jar):
    archive = zipfile.ZipFile(jar, 'r')
    javas = [re.sub(r'META-INF/versions/\d+/', r'', f) for f in archive.namelist()]
    return sorted(list(set([re.sub(r'/[^/]+.class', r'', f).replace('/', '.') for f in javas if '.class' in f and '/' in f])))

def get_used_by_analysis_python(deps):
    if 'ALMASW_INSTDIR' not in os.environ: return {}
    usedby = {}
    tpkgs = []
    #deps = {'alabaster':deps['alabaster']}
    for dep in deps:
        pip = subprocess.Popen('pip show -f ' + dep, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out = pip.communicate()[0].decode(sys.getdefaultencoding()).replace('\\n', '\n')
        #out = pip.stdout.read().decode(sys.getdefaultencoding()).replace('\\n', '\n')
        loc = re.sub(r'.*Location: (.*?)\n.*', r'\1', out, flags=re.M|re.DOTALL)
        files = re.sub(r'.*Files:\n(.*)', r'\1', out, flags=re.M|re.DOTALL)
        mods = [f.strip().replace('.py', '').replace('/', '.') for f in re.findall(r' [^ .]*.py\n', files) if '/__init__.py' not in f]
        pkgs = sorted(list(set(sum([get_pkgs_from_module(m) for m in mods], []))))
        usedby[dep] = {'Name': deps[dep]['Name'], 'Current': deps[dep]['Current'], 'ins':loc, 'pkgs': pkgs, 'acs': [], 'almasw': []}
        tpkgs += pkgs
    tpkgs = sorted(list(set(tpkgs)))
    usedacs = get_used_by_acs_from_pkgs(tpkgs, python=True)
    usedalmasw = get_used_by_almasw_from_pkgs(tpkgs, python=True)
    for dep in deps:
        usedby[dep]['acs'] = sorted(list(set(sum([usedacs[p] for p in usedacs.keys() if p in usedby[dep]['pkgs']], []))))
        usedby[dep]['almasw'] = sorted(list(set(sum([usedalmasw[p] for p in usedalmasw.keys() if p in usedby[dep]['pkgs']], []))))
    return usedby

def get_pkgs_from_module(mod):
    mods = []
    while True:
        mods.append(mod)
        if '.' not in mod: break
        mod = mod.rsplit('.', 1)[0]
    return mods

def get_used_by_python_dir_from_pkgs(dirname, pkgs, exclude=None):
    if 'WORKDIR' not in os.environ: return {}
    if len(pkgs) == 0: return {}
    site_packages = 'lib/python/site-packages'
    if 'PYTHON_SITE_PACKAGES' in os.environ:
        site_packages = os.getenv('PYTHON_SITE_PACKAGES')
    basepath = os.path.join(os.getenv('WORKDIR'), dirname)
    py_files = os.path.join(basepath, '**', '*.py')
    uses = {k: [] for k in pkgs}
    for py in glob.glob(py_files, recursive=True):
        if os.path.islink(py): continue
        if site_packages in py: continue
        pyname = py.replace(basepath, '').replace('/src-gen/', '/src/')
        if dirname == '':
            module = re.sub(r'([^/]+)/.*', r'\1', pyname)
        else:
            module = re.sub(r'(.*?)/(src|test)/.*', r'\2:\1', pyname)
        if exclude is not None and pyname.startswith(exclude): continue
        with open(py, 'r') as f:
            source = f.read()
        source = re.sub(r'#.*$', r'', source, flags=re.M)
        source = re.sub(r'""".*?"""', r'', source, flags=re.M|re.DOTALL)
        source = re.sub(r"'''.*?'''", r'', source, flags=re.M|re.DOTALL)
        reg = r'^ *(import|from) *('+ re.escape(pkgs[0])
        for pkg in pkgs[1:]:
            reg += '|' + re.escape(pkg)
        reg += ') *($|import *[^ ]* *$)'
        result = sorted(list(set(re.findall(reg, source, re.M))))
        if result is not None and len(result) > 0:
            for pkg in result:
                uses[pkg[1]].append(module)
    for pkg in uses:
        uses[pkg] = sorted(list(set(uses[pkg])))
    return uses

if __name__ == '__main__': # pragma: no cover
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-j', '--java', action='store_true', help='Obtain dependencies for Java')
    group.add_argument('-p', '--python', action='store_true', help='Obtain dependencies for Python')
    parser.add_argument('-u', '--used-by', action='store_true', help='Show a report of ACS and ALMA SW using each dependency')
    args = parser.parse_args()
    if args.python:
        url = 'https://confluence.alma.cl/display/ICTACS/Python+Dependencies'
        fdeps = get_deps_from_reqs_file()
        pmdeps = get_deps_from_pip()
    if args.java:
        url = 'https://confluence.alma.cl/display/ICTACS/Java+Dependencies'
        fdeps = get_deps_from_pom_file()
        pmdeps = get_deps_from_maven()
    cdeps = get_deps_from_confluence(url)
    usedby = {}
    if args.used_by:
        usedby = get_used_by_analysis(fdeps, args)
    report = compare_confluence_with_package_manager(fdeps, cdeps, pmdeps, usedby)
    print_report(report, fdeps, cdeps, pmdeps, usedby, args.used_by)
