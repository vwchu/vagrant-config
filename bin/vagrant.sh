#!/bin/bash
#-----------------------------------------------------------------
# vagrant.sh
#
# This script is a wrapper for Vagrant, allows the 
# Vagrantfile to be call for anywhere in the system
# with a `vagrant.yml` or `vagrant.json` locate in the
# current working directory. 
#
# Usage:
#   ./vagrant.sh [<vagrant_args>...]
#
#-----------------------------------------------------------------

VAGRANT_VAGRANTFILE=$(dirname $0)/../Vagrantfile vagrant "$@"
