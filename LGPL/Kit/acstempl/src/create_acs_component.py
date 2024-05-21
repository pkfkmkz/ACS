#!/usr/bin/env python3
# coding=UTF-8

# if you get encoding errors run the following in your terminal:
# export LC_ALL=en_US.utf-8
# export LANG=en_US.utf-8

import os
import subprocess
import traceback
import logging, coloredlogs
import click
import yaml
from create_python_component import create_python_component
from create_cpp_component import create_cpp_component
from create_java_component import create_java_component

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')


@click.version_option(version='1.0.0')
@click.command()
@click.argument('component_yaml_path')
@click.option('-l', '--language', default='python', show_default=True,
              type=click.Choice(['python', 'cpp', 'java'], case_sensitive=False),
              help="Component's implementation language.")
def create_component(component_yaml_path, language):
    """Creates an ACS component from a YAML definition."""
    try:
        yaml_data = load_yaml_data(component_yaml_path)
        create_idl(yaml_data)
        add_component_to_cdb(yaml_data, language)
        if language == 'python':
            create_python_component(yaml_data)  
        elif language == 'cpp':
            create_cpp_component(yaml_data)
        elif language == 'java':
            create_java_component(yaml_data)
    except Exception as e:
        logger.error(e)
        traceback.print_exc()


def load_yaml_data(component_yaml_path):
    """Returns a dictionary with the component's data."""
    logger.info("Loading component's YAML definition.")
    with open(component_yaml_path, "r") as stream:
        try:
            component_definition = yaml.safe_load(stream)
            logger.debug(f"Component's definition: {component_definition}")
        except yaml.YAMLError as e:
            logger.error(e)
    
    working_dir = component_definition.get('working_dir')
    name = component_definition.get('component_name')
    prefix = component_definition.get('prefix')
    module = component_definition.get('module')
    functions = component_definition.get('functions')
    properties = component_definition.get('properties')

    yaml_data = {
        'working_dir': working_dir,
        'name': name,
        'prefix': prefix,
        'module': module,
        'functions': functions,
        'properties': properties,
    }

    return yaml_data


def create_idl(yaml_data):
    """Creates IDL's directories and source code."""

    yaml_working_dir = yaml_data.get('working_dir')
    yaml_prefix = yaml_data.get('prefix')
    yaml_module = yaml_data.get('module')
    yaml_name = yaml_data.get('name')
    yaml_functions = yaml_data.get('functions')
    yaml_properties = yaml_data.get('properties')
    
    # create IDL directory
    logger.info("Creating IDL's directories")
    command = f'getTemplateForDirectory MODROOT_WS idl{yaml_name}'
    p = subprocess.Popen(command, cwd=yaml_working_dir, shell=True)
    p.wait()

    # create IDL content
    logger.info("Creating IDL's content")
    tab = '    '
    functions = ''
    for function in yaml_functions:
        functions += f'{tab*2}{function};\n'
    functions = functions.strip('\n')

    properties = ''
    for property in yaml_properties:
        properties += f'{tab*2}{property};\n'
    properties = properties.strip('\n')

    name_upper = yaml_name.upper()
    idl_content = IDL_TEMPLATE.format(
        prefix=yaml_prefix,
        module=yaml_module,
        name=yaml_name,
        name_upper=name_upper,
        functions=functions,
        properties=properties,
    )
    logger.debug(f"IDL's content: {idl_content}")

    # create IDL source code 
    file_path = yaml_working_dir + f'/idl{yaml_name}/idl/{yaml_name}.idl'
    f = open(file_path, 'w+')
    f.write(idl_content)
    f.close()

    # edit IDL Makefile
    logger.info('Editing Makefile')
    file_path = yaml_working_dir + f'/idl{yaml_name}/src/Makefile'
    with open(file_path, 'r') as f:
        makefile_content = f.read()
    makefile_content = makefile_content.replace(
        'IDL_FILES =',
        f'IDL_FILES = {yaml_name}\n{yaml_name}Stubs_LIBS = acscomponentStubs'
    )
    makefile_content = makefile_content.replace(
        'COMPONENT_HELPERS=',
        'COMPONENT_HELPERS=on'
    )
    with open(file_path, 'w') as f:
        f.write(makefile_content)


def add_component_to_cdb(yaml_data, language):
    """Creates CDB's XML entry for the component."""
    yaml_name = yaml_data.get('name')
    yaml_prefix = yaml_data.get('prefix')
    yaml_module = yaml_data.get('module')

    logger.info('Adding component to CDB')
    ACS_CDB = os.environ.get('ACS_CDB')
    cdb_path = f'{ACS_CDB}/CDB/MACI/Components/Components.xml'
    with open(cdb_path, 'r') as f:
        cdb_content = f.read()
        
    if language == 'python':
        XML_TEMPLATE = XML_PYTHON_TEMPLATE
    elif language == 'cpp':
        XML_TEMPLATE = XML_CPP_TEMPLATE
    elif language == 'java':
        XML_TEMPLATE = XML_JAVA_TEMPLATE

    element_content = XML_TEMPLATE.format(
        prefix=yaml_prefix,
        module=yaml_module,
        name=yaml_name
    )

    if element_content not in cdb_content:
        cdb_content = cdb_content.replace(
            '</Components>',
            f'{element_content}</Components>'
        )
        logger.debug(f"CDB's content: {cdb_content}")
        with open(cdb_path, 'w') as f:
            f.write(cdb_content)
    else:
        logger.info(f'Component already in CDB. Nothing to add.')



IDL_TEMPLATE = '''#ifndef _{name_upper}_IDL_
#define _{name_upper}_IDL_
 
#pragma prefix "{prefix}"
 
#include <acscomponent.idl>
 
module {module} {{
    interface {name} : ACS::ACSComponent {{
{functions}
{properties}
    }};
}};

#endif
'''

XML_PYTHON_TEMPLATE = '''      <e Name="{name}Python" 	
         Code="{module}Impl.{name}Impl" 
         Type="IDL:{prefix}/{module}/{name}:1.0"
         Container="aragornContainer" ImplLang="py" />
'''

XML_CPP_TEMPLATE = '''      <e Name="{name}CPP" 	
         Code="{name}Impl" 
         Type="IDL:{prefix}/{module}/{name}:1.0"
         Container="bilboContainer" ImplLang="cpp" />
'''

XML_JAVA_TEMPLATE = '''      <e Name="{name}Java" 	
         Code="{prefix}.{module}.{name}Impl.{name}ComponentHelper" 
         Type="IDL:{prefix}/{module}/{name}:1.0"
         Container="frodoContainer" ImplLang="java" />
'''

if __name__ == '__main__':
    create_component()
