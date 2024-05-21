#!/usr/bin/env python
"""Finds a python module's dependencies and writes them into a rules.mk file.

Usage:
    find_dependencies.py PYTHON_MODULE_PATH [-r RULESMK_PATH] [-h]

Options:
    PYTHON_MODULE_PATH              Python module directory path.
    -r, --rules_path RULESMK_PATH   rules.mk file path [default: rules.mk].
    -h, --help                      Show this screen.
"""

import argparse

from subprocess import Popen, PIPE, STDOUT, CalledProcessError

def get_dependencies(module_path):
    # Run command
    command = f"""sfood {module_path} --external |grep -v "'$(python2-config --prefix)/lib/python2.7'" |grep -v "'$(python2-config --prefix)/lib/python2.7/site-packages'" |grep -v lib-dynload |grep -v omniORB |grep -v CosNaming |grep -v CORBA |grep -v 'tkinter' |grep -v 'builtins' |sed "s/.*'\([^']*\)'.*/\\1/" |sort -u"""
    result = Popen(command, shell=True, stdout=PIPE, stderr=STDOUT)
    ret = result.wait()
    if ret:
        print(result.stdout.read())
        raise CalledProcessError(cmd=command, returncode=ret)

    # Parse output
    pkgs = []
    for line in result.stdout.readlines():
        if line == b'Traceback (most recent call last):\n':
            break
        if b'WARNING' not in line and line != b'\x01\n':
            pkgs.append(line.decode().replace('\n', ''))

    # Return packages
    return pkgs


def get_ext_dependencies(module_path):
    # Run command
    command = f"""pip-module-scanner -p {module_path}"""
    result = Popen(command, shell=True, stdout=PIPE, stderr=STDOUT)
    ret = result.wait()
    if ret:
        print(result.stdout.read())
        raise CalledProcessError(cmd=command, returncode=ret)

    # Parse output
    ext_pkgs = []
    for line in result.stdout.readlines():
        ext_pkgs.append(line.decode().replace('\n', ''))

    # Return packages
    return ext_pkgs


def set_dependencies(rulesmk_path, module_name, pkgs, ext_pkgs):
    with open(rulesmk_path, 'r') as file:
        text = file.read()

    new_line = ''
    with open(rulesmk_path, 'r') as file:
        for line in file:
            if 'PY_PACKAGES =' in line or 'PY_PACKAGES:=' in line:
                pkgs = ' '.join(pkgs)
                ext_pkgs = ' '.join(ext_pkgs)
                new_line = line + f'\n{module_name}_PKGS = {pkgs}\n{module_name}_EXT_PKGS = {ext_pkgs}\n\n'
                text = text.replace(line, new_line)

    with open(rulesmk_path, 'w') as file:
        file.write(text)


def main(args):
    module_path = args.get('PYTHON_MODULE_PATH')
    module_name = module_path.strip('/').split('/')[-1]
    rulesmk_path = args.get('--rules_path')

    pkgs = get_dependencies(module_path)
    ext_pkgs = get_ext_dependencies(module_path)
    set_dependencies(rulesmk_path, module_name, pkgs, ext_pkgs)

if __name__ == '__main__':
    parser = argparse.ArgumentParser("find_dependencies.py")
    parser.add_argument("PYTHON_MODULE_PATH", metavar="PYTHON_MODULE_PATH", help="rules.mk file path [default: rules.mk].", type=str, required=True)
    parser.add_argument("--rules_path", "-r", help="rules.mk file path [default: rules.mk].", type=str, required=False)
    args = parser.parse_args()
    print(args)
    main(args)
