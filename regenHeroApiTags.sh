#! /bin/bash

cd ~/development/dragon_api/src/aws_lambda/main/python/
ctags --python-kinds=-i -f .heroApiTags -R .
