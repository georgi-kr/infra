#!/bin/bash
#
# List all terraform resources for a given path/paths.
# Usful to help with moving resources into modules
# For `terraform state mv`

grep -hor "resource \"[A-z0-9_]*\" \"[A-z0-9\-_]*\"" ${@:1} | sed -re "s/resource \"([A-z0-9_]*)\" \"([A-z0-9\-_]*)\"/\1.\2/"
