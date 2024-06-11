#!/Users/tfeiler/.virtualenvs/tjf_python_shellscripts/bin/python

import json, os, sys, yaml

def usage():
    print(f"Usage: jsonToYaml.py <path_to_json>")
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()

        """
        combo = ""
        for line in sys.stdin:
            combo += line

        converted = yaml.dump(combo, default_flow_style=False)
        print(converted)
        """
    else:
        json_file = sys.argv[1]

        if not json_file.endswith(".json"):
            usage()
        else:
            if os.path.isfile(json_file):
                # thx https://stackoverflow.com/questions/50846431/converting-a-yaml-file-to-json-object-in-python
                with open(json_file, 'r') as json_in:
                    loaded = json.load(json_in)
                    converted = yaml.dump(loaded, default_flow_style=False)
                    print(converted)
            else:
                usage()
