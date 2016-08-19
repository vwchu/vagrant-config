#--------------------------------------------------
# shared.rb
#
# Shared common functions used 
# throughout the application.
#--------------------------------------------------

require_relative "./colorize.rb"

class Hash

  # Merges the hash with the given other hash's fields and values.
  # Returns merged hash with other's properties, fields and values.
  def deep_merge(other)
    self.merge(other) do |key, oldval, newval|
      if oldval.is_a? Hash then
        oldval.deep_merge(newval)
      elsif oldval.is_a? Array then
        oldval + newval
      else
        newval
      end
    end
  end

end # Hash

class Config

  # Resolves the given path for the configuration file.
  def Config.resolve_path(path)
    if path.end_with?('.yml') and File.exists?(path) then
      File.expand_path(path)
    elsif path.end_with?('.json') and File.exists?(path) then
      File.expand_path(path)
    elsif File.exists?("#{path}.yml") then
      File.expand_path("#{path}.yml")
    elsif File.exists?("#{path}.json") then
      File.expand_path("#{path}.json")
    else
      raise "Cannot resolve #{path}.yml or #{path}.json."
    end
  end

  # Loads and parses the configuration file at the given path.
  def Config.load(path)
    if path.end_with?('.yml') and File.exists?(path) then
      YAML::load(File.read(path))
    elsif path.end_with?('.json') and File.exists?(path) then
      JSON.parse(File.read(path))
    else
      raise "Cannot resolve #{path}.yml or #{path}.json."
    end
  end

  # Loads and parses the given list of configuration
  # files. Sets the given hash file paths map to file contents.
  # Returns the merge order of the files.
  def Config.batch_load(includes, configs, cwd)
    loads = []
    includes.map {|inc| Config.resolve_path("#{cwd}/#{inc}")}.each do |inc| 
      next if configs.has_key?(inc)
      configs[inc] = config = Config.load(inc)
      if config.has_key?('includes') then
        loads = loads + Config.batch_load(config.delete('includes'), configs, File.dirname(inc))
      end
      loads.push(inc)
    end
    return loads
  end

  # Given a array of configuration source paths,
  # returns the merged configuration hash.
  def Config.resolve_dependencies(includes)
    resolved = {}
    puts "Merging VM configuration:".cyan
    Config.batch_load(includes, configs = {}, Dir.pwd).each do |inc|
      puts " >> Resolving #{inc}...".cyan
      resolved = resolved.deep_merge(configs[inc])
    end
    puts "Configurations ready.".cyan
    return resolved
  end

end # Config
