#!/usr/bin/env ruby
#-----------------------------------------------------------------
# run_local.rb
#
# This script provisions the environment specified
# by the `vagrant.yml` or `vagrant.json` locally
# on this host machine. 
#
# Usage:
#   ./run_local.rb [<machine-name>...]
#
# Environment Variables:
#   VAGRANT_CONFIGS
#       Comma-separated list of paths to cascading config
#       files in order of cascade; if path does not 
#       include file extension, will try .yml and .json
#       in that order. Default: ./vagrant
#
# This script is an experimental feature. Not all provisioning
# mechanisms are currently implemented, only the file and
# shell provisioners. Only works on Linux based systems.
# The virtual machine's home directory is mapped to the current
# user's home directory.
#
# Use at your own risk.
#-----------------------------------------------------------------

require 'yaml'
require 'json'
require_relative "./shared.rb"
require_relative "./machine.rb"
require_relative "./provision.rb"

Provision.run_provisions(Machine.create_machines(Config.resolve_dependencies(
  if ENV.has_key?('VAGRANT_CONFIGS') then
    ENV['VAGRANT_CONFIGS'].split(',').map {|s| s.strip}
  else
    ['./vagrant']
  end)), ARGV)
