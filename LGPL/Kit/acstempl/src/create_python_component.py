import os
import subprocess
import logging, coloredlogs

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')


def create_python_component(yaml_data):
    """Creates component's directories and source code."""
    yaml_name = yaml_data.get('name')
    yaml_working_dir = yaml_data.get('working_dir')
    yaml_functions = yaml_data.get('functions')
    yaml_module = yaml_data.get('module')

    # create component's directories
    logger.info(f"Creating component's directories.")
    command = f'getTemplateForDirectory MODROOT_WS py{yaml_name}'
    p = subprocess.Popen(command, cwd=yaml_working_dir, shell=True)
    p.wait()
    working_dir = yaml_working_dir + f'/py{yaml_name}/src/{yaml_module}Impl'
    if os.path.exists(working_dir):
        logger.info(f'{working_dir} already exists.')
    else:
        os.makedirs(working_dir)
    with open(f'{working_dir}/__init__.py', 'w'): pass

    # create component's content
    logger.info(f"Creating component's content.")
    tab = '    '
    functions = ''
    for yaml_function in yaml_functions:
        function_name = yaml_function.split()[1].split('(')[0]
        yaml_params = yaml_function.split('(')[1].replace(')', '').split(',')
        if yaml_params != ['']:
            params = [p.split()[1] for p in yaml_params]
            params = ', '.join(params)
            functions += f'{tab}def {function_name}(self, {params}):\n{tab*2}raise NotImplementedError("This function should do something")\n\n'
        else:
            functions += f'{tab}def {function_name}(self):\n{tab*2}raise NotImplementedError("This function should do something")\n\n'
    functions = functions.strip('\n')
    
    component_content = COMPONENT_TEMPLATE.format(
        module=yaml_module,
        name=yaml_name,
        functions=functions,
    )
    logger.debug(f"Component's content: {component_content}")

    # create component's source code
    file_path = f'{working_dir}/{yaml_name}Impl.py'
    f = open(file_path, 'w+')
    f.write(component_content)
    f.close()

    # edit component's Makefile
    logger.info(f'Editing Makefile')
    file_path = yaml_working_dir + f'/py{yaml_name}/src/Makefile'
    with open(file_path, 'r') as f:
        makefile_content = f.read()
    makefile_content = makefile_content.replace(
        'PY_PACKAGES        =',
        f'PY_PACKAGES        = {yaml_module}Impl'
    )
    with open(file_path, 'w') as f:
        f.write(makefile_content)


COMPONENT_TEMPLATE = '''# Client stubs and definitions, such as structs, enums, etc.
import {module}
# Skeleton infrastructure for server implementation
import {module}__POA
   
# Base component implementation
from Acspy.Servants.ACSComponent import ACSComponent
# Services provided by the container to the component
from Acspy.Servants.ContainerServices import ContainerServices
# Basic component lifecycle (initialize, execute, cleanUp and aboutToAbort methods)
from Acspy.Servants.ComponentLifecycle import ComponentLifecycle


class {name}Impl({module}__POA.{name}, ACSComponent, ContainerServices, ComponentLifecycle):
    def __init__(self):
        ACSComponent.__init__(self)
        ContainerServices.__init__(self)
        self._logger = self.getLogger()
        
{functions}
'''
