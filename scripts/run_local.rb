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

def resolve_config(reference)
  if reference.end_with?('.yml') and File.exists?(reference) then
    YAML::load(File.read(reference))
  elsif reference.end_with?('.json') and File.exists?(reference) then
    JSON.parse(File.read(reference))
  elsif File.exists?("#{reference}.yml") then
    YAML::load(File.read("#{reference}.yml"))
  elsif File.exists?("#{reference}.json") then
    JSON.parse(File.read("#{reference}.json"))
  else
    raise "Cannot resolve #{reference}.yml or #{reference}.json."
  end
end

Provision.run_provisions(Machine.create_machines(if ENV.has_key?('VAGRANT_CONFIGS') then
  vagrant_configs = {}
  ENV['VAGRANT_CONFIGS'].split(',').each do |config|
    vagrant_configs = vagrant_configs.deep_merge(resolve_config("#{config.strip}"))
  end
  vagrant_configs
else
  resolve_config("./vagrant")
end), ARGV)
