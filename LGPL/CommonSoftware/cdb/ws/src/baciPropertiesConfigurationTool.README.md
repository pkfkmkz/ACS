# BACI Properties Configuration Tool

A Python script that writes BACI properties values into the CDB from a YAML configuration file.

## Description

This script aims to provide a tool for setting BACI properties values into the CDB for components using their name or IDL type, as defined in a YAML file.

## Getting Started

### Dependencies

* lxml
* re
* logging
* yaml
* subprocess
* time
* argparse
* os

### Installing

* Provided with the ALMA Software project. No installation needed.

### Executing program

* Run as a typical Python 3 script.
```
python -m baciPropertiesConfigurationTool.baci_properties_configuration_tool /path/to/yaml_files_directory
```


## Help
```
> python -m baciPropertiesConfigurationTool.baci_properties_configuration_tool --help
usage: baci_properties_configuration_tool.py [-h] yaml_files_directory

Set BACI properties values for multiple components using a YAML definition.

positional arguments:
  yaml_files_directory  Directory containing the YAML file or files.

optional arguments:
  -h, --help            show this help message and exit
```

## Version History

* 0.1
    * Initial Release