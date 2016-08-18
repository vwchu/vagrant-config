# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'json'
require_relative "scripts/shared.rb"
require_relative "scripts/machine.rb"

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

Vagrant.configure(2) do |config|
  Machine.configure(config, if ENV.has_key?('VAGRANT_CONFIGS') then
    vagrant_configs = {}
    ENV['VAGRANT_CONFIGS'].split(/,/).each do |config|
      vagrant_configs = vagrant_configs.deep_merge(resolve_config("#{config.strip}"))
    end
    vagrant_configs
  else
    resolve_config("./vagrant")
  end)
end # Vagrant.configure
