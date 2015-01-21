#!/bin/bash
cd ~/remotes/ventnorTfeilerReason/
find . -name "*.php" -exec grep -li "$1" {} \;
cd -
