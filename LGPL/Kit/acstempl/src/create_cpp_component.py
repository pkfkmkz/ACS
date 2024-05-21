import subprocess
import logging, coloredlogs

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')

def create_cpp_component(yaml_data):
    """Creates component's directories and source code."""

    yaml_working_dir = yaml_data.get('working_dir')
    yaml_module = yaml_data.get('module')
    yaml_name = yaml_data.get('name')  
    yaml_functions = yaml_data.get('functions')
    yaml_properties = yaml_data.get('properties')
    
    # create component's directories
    logger.info(f'Creating component directory')
    command = f'getTemplateForDirectory MODROOT_WS cpp{yaml_name}'
    p = subprocess.Popen(command, cwd=yaml_working_dir, shell=True)
    p.wait()
    working_dir = yaml_working_dir + f'/cpp{yaml_name}'
    with open(f'{working_dir}/include/{yaml_name}Impl.h', 'w'): pass
    with open(f'{working_dir}/src/{yaml_name}Impl.cpp', 'w'): pass

    # create header's content
    logger.info(f"Creating component's header content")
    tab = '    '
    functions = ''
    for yaml_function in yaml_functions:
        functions += f'{tab*2}{yaml_function};\n'
    functions = functions.strip('\n')

    properties = ''
    for yaml_property in yaml_properties:
        property = ' '.join(yaml_property.split()[-2:])
        properties += f'{tab*2}{property};\n'
    properties = properties.strip('\n')
    
    name_upper = yaml_name.upper()
    header_content = HEADER_TEMPLATE.format(
        module=yaml_module,
        name=yaml_name,
        name_upper=name_upper,
        functions=functions,
        properties=properties,
    )
    logger.debug(f'Component header: {header_content}')

    # create header's source code
    file_path = f'{working_dir}/include/{yaml_name}Impl.h'
    f = open(file_path, 'w+')
    f.write(header_content)
    f.close()

    # create component's content
    logger.info(f"Creating component's content")
    functions = ''
    for yaml_function in yaml_functions:
        return_type = yaml_function.split()[0]
        function_signature = ' '.join(yaml_function.split()[1:])
        functions += f'{return_type} {yaml_name}Impl::{function_signature} {{\n{tab}throw CORBA::NO_IMPLEMENT();\n}}\n\n'
    functions = functions.strip('\n')

    component_content = COMPONENT_TEMPLATE.format(
        name=yaml_name,
        functions=functions,
    )
    logger.debug(f'Component content: {component_content}')

    # create component's source code
    file_path = f'{working_dir}/src/{yaml_name}Impl.cpp'
    f = open(file_path, 'w+')
    f.write(component_content)
    f.close()

    # edit component's Makefile
    logger.info(f'Editing Makefile')
    file_path = yaml_working_dir + f'/cpp{yaml_name}/src/Makefile'
    with open(file_path, 'r') as f:
        makefile_content = f.read()
    makefile_content = makefile_content.replace(
        'INCLUDES        =',
        f'INCLUDES        = {yaml_name}Impl.h'
    )
    makefile_content = makefile_content.replace(
        'LIBRARIES       =',
        f'LIBRARIES       = {yaml_name}Impl\n{yaml_name}Impl_OBJECTS = {yaml_name}Impl\n{yaml_name}Impl_LIBS = {yaml_name}Stubs acscomponent' 
    )
    with open(file_path, 'w') as f:
        f.write(makefile_content)

    logger.info(f'Done.')


# header's template
HEADER_TEMPLATE = '''#ifndef _{name_upper}_IMPL_H
#define _{name_upper}_IMPL_H
  
#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif
  
// Base component implementation, including container services and component lifecycle infrastructure
#include <acscomponentImpl.h>
  
// Skeleton interface for server implementation
#include <{name}S.h>
  
// Error definitions for catching and raising exceptions
class {name}Impl : public virtual acscomponent::ACSComponentImpl, public virtual POA_{module}::{name} {{
    public:
        {name}Impl(const ACE_CString& name, maci::ContainerServices* containerServices);
        virtual ~{name}Impl();

{functions}

    private:
{properties}
}};
  
#endif'''

# component's template
COMPONENT_TEMPLATE = '''#include <{name}Impl.h>

#include <stdexcept>
  
{name}Impl::{name}Impl(const ACE_CString& name, maci::ContainerServices* containerServices) : ACSComponentImpl(name, containerServices) {{
}}
  
{name}Impl::~{name}Impl() {{
}}

{functions}
  
/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS({name}Impl)
/* ----------------------------------------------------------------*/'''
