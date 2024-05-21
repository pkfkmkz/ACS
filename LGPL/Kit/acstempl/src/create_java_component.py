import subprocess
import logging, coloredlogs

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')

def create_java_component(yaml_data):
    """Creates component's directories and source code."""
    yaml_name = yaml_data.get('name')
    yaml_working_dir = yaml_data.get('working_dir')
    yaml_functions = yaml_data.get('functions')
    yaml_prefix = yaml_data.get('prefix')
    yaml_module = yaml_data.get('module')

    # create component's directories
    logger.info('Creating component directory')
    command = f'getTemplateForDirectory MODROOT_WS java{yaml_name}'
    p = subprocess.Popen(command, cwd=yaml_working_dir, shell=True)
    p.wait()

    working_dir = yaml_working_dir + f'/java{yaml_name}/src'
    command = f'mkdir -p {yaml_prefix}/{yaml_module}/{yaml_name}Impl'
    p = subprocess.Popen(command, cwd=working_dir, shell=True)
    p.wait()

    # copy component's helper
    logger.info("Copying component's helper")
    command = f'cp idl{yaml_name}/src/{yaml_prefix}/{yaml_module}/{yaml_name}Impl/{yaml_name}ComponentHelper.java.tpl {working_dir}/{yaml_prefix}/{yaml_module}/{yaml_name}Impl/{yaml_name}ComponentHelper.java'
    p = subprocess.Popen(command, cwd=yaml_working_dir, shell=True)
    p.wait()

    # create component's content
    logger.info(f'Creating component content')
    tab = '    '
    functions = ''
    for yaml_function in yaml_functions:
        return_type = yaml_function.split(' ', 1)[0]
        function_name = yaml_function.split(' ', 1)[1].replace('in ', '')
        functions += f'{tab}public {return_type} {function_name} {{\n{tab*2}throw new org.omg.CORBA.NO_IMPLEMENT();\n{tab}}}\n\n'
    functions = functions.strip('\n')

    component_content = COMPONENT_TEMPLATE.format(
        prefix=yaml_prefix,
        module=yaml_module,
        name=yaml_name,
        functions=functions,
    )
    logger.debug(f'Component content: {component_content}')

    # create component's source code
    file_path = f'{working_dir}/{yaml_prefix}/{yaml_module}/{yaml_name}Impl/{yaml_name}Impl.java'
    f = open(file_path, 'w+')
    f.write(component_content)
    f.close()

    # edit component's Makefile
    logger.info(f'Editing Makefile')
    file_path = f'{working_dir}/Makefile'
    with open(file_path, 'r') as f:
        makefile_content = f.read()
    makefile_content = makefile_content.replace(
        'JARFILES= ',
        f'JARFILES={yaml_name}Impl\n{yaml_name}Impl_DIRS={yaml_prefix}'
    )
    with open(file_path, 'w') as f:
        f.write(makefile_content)


# component's template
COMPONENT_TEMPLATE = '''//Suggested: import alma.<Module>.<Interface>Impl; //But anything, really
package {prefix}.{module}.{name}Impl;
   
//Base component implementation, including container services and component lifecycle infrastructure
import alma.acs.component.ComponentImplBase;
   
//Skeleton interface for server implementation
import {prefix}.{module}.{name}Operations;
  
  
//ClassName usually is <Interface>Impl, but can be anything
public class {name}Impl extends ComponentImplBase implements {name}Operations {{
    public {name}Impl() {{}}

{functions}
}}'''
