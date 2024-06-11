#!/Users/tfeiler/.virtualenvs/tjf_python_shellscripts/bin/python

import json, os, sys, yaml

def usage():
    print(f"Usage: yamlToJson.py <path_to_yaml>")
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()
    else:
        yaml_file = sys.argv[1]

        if not yaml_file.endswith(".yml") and not yaml_file.endswith("yaml"):
            usage()
        else:
            if os.path.isfile(yaml_file):
                # thx https://stackoverflow.com/questions/50846431/converting-a-yaml-file-to-json-object-in-python
                with open(yaml_file, 'r') as yaml_in:
                    yaml_object = yaml.safe_load(yaml_in) # yaml_object will be a list or a dict
                    print(json.dumps(yaml_object, indent=2))
            else:
                usage()
