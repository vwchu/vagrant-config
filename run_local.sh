#!/bin/bash
#-----------------------------------------------------------------
# run_local.sh
#
# This script provisions the environment specified
# by the `vagrant.yml` or `vagrant.json` locally
# on this host machine. 
#
# Usage:
#   ./run_local.sh [<machine-name>...]
#
# This script is an experimental feature. Not all provisioning
# mechanisms are currently implemented, only the file and
# shell provisioners. Only works on Linux based systems.
# The virtual machine's home directory is mapped to the current
# user's home directory. 
#
# Use at your own risk.
#-----------------------------------------------------------------

if ! which rvm >& /dev/null; then
  # Install the latest version of Ruby via RVM.
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable --ruby
fi

# Initialize RVM and ruby
source ~/.rvm/scripts/rvm
rvm use ruby

# Run local provisioning
$(dirname $0)/scripts/run_local.rb $@
