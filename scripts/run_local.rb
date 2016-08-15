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
require_relative "./machine.rb"
require_relative "./provision.rb"

root_path = File.expand_path(File.dirname(__FILE__) + '/..')
vagrant_yaml_path = "#{root_path}/vagrant.yml"
vagrant_json_path = "#{root_path}/vagrant.json"

Provision.run_provisions(Machine.create_machines(if File.exists?(vagrant_yaml_path) then
  YAML::load(File.read(vagrant_yaml_path))
elsif File.exists?(vagrant_json_path) then
  JSON.parse(File.read(vagrant_json_path))
else
  raise 'Cannot find vagrant.yml or vagrant.json.'
end), ARGV)
