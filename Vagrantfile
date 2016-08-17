# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'json'

root_path = File.expand_path(File.dirname(__FILE__))
vagrant_yaml_path = Dir.pwd + "/vagrant.yml"
vagrant_json_path = Dir.pwd + "/vagrant.json"

require "#{root_path}/scripts/machine.rb"

Vagrant.configure(2) do |config|
  Machine.configure(config, if File.exists?(vagrant_yaml_path) then
    YAML::load(File.read(vagrant_yaml_path))
  elsif File.exists?(vagrant_json_path) then
    JSON.parse(File.read(vagrant_json_path))
  else
    raise 'Cannot find vagrant.yml or vagrant.json.'
  end)
end # Vagrant.configure
