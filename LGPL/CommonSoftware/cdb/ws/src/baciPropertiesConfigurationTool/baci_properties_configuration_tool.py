from lxml import etree
import re
import logging
import yaml
import subprocess
import time
import argparse
import os


def list_files_in_directory(directory):
    file_list = os.listdir(directory)
    sorted_file_list = sorted(file_list)
    absolute_paths = [os.path.join(directory, file) for file in sorted_file_list]

    return absolute_paths


def parse_cdb():
    """
    Read CDB XML string content and returns a CDB XML tree.
    """
    # read CDB
    cmd = 'cdbRead alma --raw'
    logger.debug(f'Executing command: {cmd}')
    cmd_output = subprocess.check_output(cmd, shell=True).decode('utf-8')

    # get XML tree
    xml_str = cmd_output.split('INFO [DALRead] Curl data:')[1].strip()
    b_xml = bytes(xml_str, 'utf-8')
    root = etree.fromstring(b_xml)

    return root


def get_element_xpath(element):
    """
    Recursively builds the XPath of an element by traversing its ancestors.
    """
    xpath = ''
    while element is not None:
        tag = element.tag
        name = element.get('Name')
        xpath = f'/{tag}' + xpath
        element = element.getparent()

    return xpath


def get_components_xpaths(root):
    """
    Returns the XPath of every component node.
    """
    # Get all nodes that define an IDL type in the xmlns attribute, i.e. get all nodes that are components.
    component_nodes = root.xpath("//*[namespace-uri()!='' and namespace-uri() = namespace-uri(child::*) and namespace-uri() != namespace-uri(parent::*) and not(contains(name(), ':'))]")

    logger.debug('{} components found.'.format(len(component_nodes)))

    xpaths = []
    for component_node in component_nodes:
        # Get the component's XPath
        xpath = get_element_xpath(component_node)
        xpaths.append(xpath)
    
    return xpaths


def search_components_by_type(xpaths, component_type):
    """
    Match components of certain type and clean the XPath as to be used by cdbWrite.
    """
    return [remove_curly_braces(xpath.replace('/alma/', '')) for xpath in xpaths if component_type in xpath]


def remove_curly_braces(string):
    # Use regular expression to match and remove everything between curly braces
    pattern = r'\{.*?\}'
    result = re.sub(pattern, '', string)
    return result


def set_baci_property(component, property, field, value):
    """
    Set a BACI property field's value using cdbWrite.
    """
    cmd = 'cdbWrite alma/{} {}/{} {}'.format(component, property, field, value)
    logger.debug(f'Executing command: {cmd}')
    return subprocess.check_output(cmd, shell=True)


def set_by_name(yaml_data):
    """
    Sets BACI properties values by component name according to the YAML template.
    """
    logger.debug('Setting BACI properties values by component name...')

    # Retrieve the component list
    components = yaml_data.get('components_by_name')
    if not components:
        logger.debug('No components by name definition were found.')
        return

    # Iterate each component
    for component in components:
        component_name = component.get('name')
        properties = component.get('properties')

        # Iterate each BACI property
        for property in properties:
            property_name = property.get('name')
            fields = property.get('fields')

            # Set each field and value in the CDB
            for field in fields:
                field_name = field.get('name')
                field_value = field.get('value')
                output_message = set_baci_property(component_name, property_name, field_name, field_value)
                logger.debug('Response: {}'.format(output_message.decode('utf-8')))


def set_by_type(yaml_data):
    """
    Sets BACI properties values by the components IDL type according to the YAML template.
    """
    logger.debug('Setting BACI properties values by component IDL type...')

    # Retrieve the component list
    components = yaml_data.get('components_by_type')
    if not components:
        logger.debug(f'No components by IDL definition were found.')
        return

    # Get components xpaths
    root = parse_cdb()
    xpaths = get_components_xpaths(root)

    # Iterate each component
    for component in components:
        component_type = component.get('type')
        properties = component.get('properties')

        # Get component names from type
        logger.debug(f'Searching components of type: {component_type}')
        component_names = search_components_by_type(xpaths, component_type)
        logger.debug('{} components found: {}'.format(len(component_names), component_names))

        for component_name in component_names:
            # Iterate each BACI property
            for property in properties:
                property_name = property.get('name')
                fields = property.get('fields')

                # Set each field and value in the CDB
                for field in fields:
                    field_name = field.get('name')
                    field_value = field.get('value')
                    output_message = set_baci_property(component_name, property_name, field_name, field_value)
                    logger.debug('Response: {}'.format(output_message.decode('utf-8')))


# Parse command line arguments
parser = argparse.ArgumentParser(description="Set BACI properties values for multiple components using a YAML definition.",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("yaml_files_directory", help="Directory containing the YAML file or files.")
args = parser.parse_args()

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger('BACI Properties Configuration Tool')


def main():
    start = time.time()

    # Get parameters
    yaml_files_directory = args.yaml_files_directory
    yaml_list = list_files_in_directory(yaml_files_directory)

    for yaml_file_path in yaml_list:
        # Load the YAML file into a Python object
        logger.debug(f'Reading YAML file {yaml_file_path}')
        with open(yaml_file_path, "r") as f:
            yaml_data = yaml.safe_load(f)

        # Set BACI properties by component name in YAML file
        set_by_name(yaml_data)

        # Set BACI properties by component type in YAML file
        set_by_type(yaml_data)

    elapsed_time = time.time() - start
    print(f'Elapsed time: {int(elapsed_time)} seconds.')


if __name__ == "__main__":
    main()
