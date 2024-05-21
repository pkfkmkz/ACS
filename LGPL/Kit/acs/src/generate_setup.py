#!/usr/bin/env python
"""Generate setup.py script.

Usage:
    generate_setup.py [-h] [-c PROJECT_DIR] [-v VERSION] [-f FILE_NAME] [-p PACKAGES] [-m MODULES] [-r | -d DEPENDENCIES] -n NAME

Options:
    -h, --help                                      Show this screen.
    -c, --current-dir PROJECT_DIR                   Set the base directory to search for packages, modules, requirements.txt, etc.
    -n NAME, --name NAME                            Set package name.
    -v VERSION, --version VERSION                   Set package version [default: 0.1.0].
    -f FILE_NAME, --filename FILE_NAME              Set output filename e.g. my_package.setup.py [default: setup.py].
    -r, --requirements                              Set dependencies from PROJECT_DIR/requirements.txt file.
    -p PACKAGES, --packages packages                Set comma-separated list of directories to include on package
    -m MODULES, --modules modules                   Set comma-separated list of modules to include on package
    -d DEPENDENCIES, --dependencies DEPENDENCIES    Set list of dependencies, e.g. 'PyYAML,pandas==0.23.3,numpy>=1.14.5'

"""
import os
import re
import argparse
import distutils.sysconfig as sysconfig

SETUP_PY_TEMPLATE = """# -*- coding: utf-8 -*-
import os

from setuptools import setup, find_packages
from setuptools.command.sdist import sdist

class acs_sdist(sdist):
    def copy_file(self, infile, outfile, preserve_mode=1, preserve_times=1, link=None, level=1):
        if infile.endswith('.setup.py'):
            outfile = outfile.replace(infile, 'setup.py')
        super().copy_file(infile, outfile, preserve_mode, preserve_times, link, level)
    def run(self):
        cwd = os.getcwd()
        os.chdir('%(project_dir)s')
        super().run()
        os.chdir(cwd)

setup(
    name='%(name)s',
    version='%(version)s',
    py_modules=%(py_modules)s,
    packages=find_packages(include=%(py_packages)s),
    include_package_data=%(include_package_data)s,
    install_requires=%(install_requires)s,
    url="https://confluence.alma.cl/display/ICTACS/ICT+ALMA+Common+Software",
    author="ALMA Common Software",
    author_email="acs-discuss@eso.org",
    description="ACS Python Module %(name)s",
    long_description="ACS Python Module %(name)s",
    license="LGPL",
    cmdclass={
        'sdist': acs_sdist,
    }
)
"""

VERSION_RE = re.compile(r'^__version__\s=', re.M)

IMPORT_RES = [
    re.compile(r'^import\s+(?P<package>[\w\d_]+)'),
    re.compile(r'^from\s+(?P<package>[\w\d_]+)'),
]

STDLIB_MODULES = set()
stdlibpath = sysconfig.get_python_lib(standard_lib=True)
for top, dirs, files in os.walk(stdlibpath):
    for nm in files:
        if nm != '__init__.py' and nm[-3:] == '.py':
            STDLIB_MODULES.add(os.path.join(top, nm)[len(stdlibpath)+1:-3].replace('\\','.').split('.')[0])

def get_project_dir(args):
    project_dir = os.getcwd()
    if args.current_dir is not None:
        project_dir = args.current_dir
    return project_dir

def get_name(args):
    name = 'dummy'
    if args.name is not None:
        name = args.name
    return name

def get_version(args):
    version = '0.1.0'
    if args.version is not None:
        version = args.version
    return version

def get_dependencies_from_file(path, ignore):
    with open(path) as fobj:
        data = fobj.read()
    names = set()
    for regex in IMPORT_RES:
        names.update(regex.findall(data))
    return [name for name in names if name not in ignore]

def get_packages(args):
    project_dir = get_project_dir(args)
    if args.packages is not None and len(args.packages) > 0:
        pkgs = []
        for p in args.packages.split(','):
            if not os.path.isdir(os.path.join(project_dir, p)):
                print("Ignoring package '" + p + "' because directory doesn't exist")
                continue
            pkgs.append(p)
        return pkgs
    if args.modules is not None:
        return []
    return [get_name(args)]

def find_package_data(args):
    project_dir = get_project_dir(args)
    package_data = []
    for name in ['templates', 'locale', 'static']:
        for parent in get_packages(args):
            if os.path.exists(os.path.join(project_dir, parent, name)):
                package_data.append('recursive-include %s/%s *' % (parent, name))
    return '\n'.join(package_data)

def get_modules(args):
    project_dir = get_project_dir(args)
    if args.modules is not None and len(args.modules) > 0:
        mods = []
        for m in args.modules.split(','):
            if not os.path.isfile(os.path.join(project_dir, m + '.py')):
                print("Ignoring module '" + m + "' because file '" + m + ".py' doesn't exist")
                continue
            mods.append(m)
        return mods
    return []

def get_dependencies(args):
    project_dir = get_project_dir(args)
    if args.dependencies is not None:
        dependencies = args.dependencies
        if len(dependencies) == 0:
            return []
        dependencies = args.dependencies.split(',')
        return dependencies
    elif args.requirements is not None:
        path = project_dir + '/requirements.txt'
        with open(path) as fobj:
            dependencies = fobj.read().splitlines()
            return dependencies
    else:
        dependencies = set()
        base_ignore = get_packages(args) + get_modules(args)
        for pm in get_packages(args) + [m + '.py' for m in get_modules(args)]:
            for root, _, filenames in os.walk(os.path.join(project_dir, pm)):
                for filename in filenames:
                    if filename.endswith('.py'):
                        path = os.path.join(root, filename)
                        dependencies.update(get_dependencies_from_file(path, base_ignore + [filename[:-3] for filename in filenames if filename.endswith('.py')]))
        return [name for name in dependencies if name not in STDLIB_MODULES]


def main(args):
    project_dir = get_project_dir(args)
    if not os.path.exists(project_dir):
        print("No project found at %s" % project_dir)
        return
    package_data = find_package_data(args)
    context = {
        'name': get_name(args),
        'project_dir': project_dir,
        'version': get_version(args),
        'include_package_data': 'True' if package_data else 'False',
        'install_requires': get_dependencies(args),
        'py_packages': get_packages(args),
        'py_modules': get_modules(args)
    }
    if args.filename is not None:
        file_name = args.filename
    else:
        file_name = 'setup.py'
    if not os.path.isabs(file_name):
        file_name = os.path.join(project_dir, file_name)
    with open(file_name, 'w') as fobj:
        fobj.write(SETUP_PY_TEMPLATE % context)
    if package_data:
        with open('MANIFEST.in', 'w') as fobj:
            fobj.write(package_data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser("generate_setup.py")
    parser.add_argument("--current-dir", "-c", metavar="PROJECT_DIR", help="Set the base directory to search for packages, modules, requirements.txt, etc.", type=str, required=False)
    parser.add_argument("--name", "-n", help="Set package name.", type=str, required=False)
    parser.add_argument("--version", "-v", help="Set package version [default: 0.1.0].", type=str, required=True)
    parser.add_argument("--filename", "-f", help="Set output filename e.g. my_package.setup.py [default: setup.py].", type=str, required=False)
    parser.add_argument("--requirements", "-r", help="Set dependencies from PROJECT_DIR/requirements.txt file.", type=str, required=False)
    parser.add_argument("--packages", "-p", help="Set comma-separated list of directories to include on package", type=str, required=False)
    parser.add_argument("--modules", "-m", help="Set comma-separated list of modules to include on package", type=str, required=False)
    parser.add_argument("--dependencies", "-d", help="Set list of dependencies, e.g. 'PyYAML,pandas==0.23.3,numpy>=1.14.5'", type=str, required=False)
    args = parser.parse_args()
    main(args)
