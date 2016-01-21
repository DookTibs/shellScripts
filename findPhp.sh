#!/bin/bash
# cd ~/remotes/ventnorTfeilerReason/
cd ~/development/carleton/carleton.edu
find . -name "*.php*" -exec grep -li "$1" {} \;
cd -
