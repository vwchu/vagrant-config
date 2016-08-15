#--------------------------------------------------
# provision.rb
#
# Provisions each environment locally, using the specified
# virtual machine and the associated machine configurations
# and the virtual machine provisioner settings.
#
# This is an experimental feature. Not all provisioning
# mechanisms are currently implemented, only the file and
# shell provisioners.
#
# Use at your own risk.
#--------------------------------------------------

require_relative "./colorize.rb"

class Provision

  # Given a list of all the machines and the given arguments,
  # returns the only a list of machines that will be executed.
  def Provision.machine_list(machines, arguments)
    machine_list = []
    if arguments.empty? then
      machine_list = machines.select {|m| m.machine[:autostart]}
      if machine_list.empty? then
        abort ("No machines to bring up. This is usually because all machines are\n" +
               "set to `autostart: false`, which means you have to explicitly specify\n" +
               "the name of the machine to bring up.").red
      end
    else
      arguments.each do |machine_name|
        mach = machines.select {|m| m.machine[:name] == machine_name}
        if mach.empty? then
          abort ("The machine with the name '#{machine_name}' was not found\n" +
                 "configured for this environment.").red
        else
          machine_list.push(mach.first)
        end
      end
    end
    return machine_list
  end

  # Configures symbolic links to mimic the shared synced folders
  # between the host and guest machines. Returns a list of the
  # symbolic links that were created, for deletion later on cleanup.
  def Provision.configure_synced_folders(synced_folders)
    symlinks = []
    synced_folders.each do |sf|
      unless sf.has_key?(:host)  then error 'synced folder' "missing 'host' parameter" end
      unless sf.has_key?(:guest) then error 'synced folder' "missing 'guest' parameter" end

      target = File.expand_path(sf[:host])
      unless File.exists?(target)    then error 'synced folder' "host directory '#{target}' does not exist" end
      unless File.directory?(target) then error 'synced folder' "host '#{target}' is not a directory" end

      symlink = File.expand_path(sf[:guest].gsub(/\/home\/vagrant/, '~'))
      if File.exists?(symlink) and File.realpath(symlink) != File.realpath(target) then 
        error 'synced folder' "guest '#{guest}' conflicts with existing file, aborting"
      elsif system('ln', '-sv', File.expand_path(target), File.expand_path(symlink)) then
        symlinks.push(symlink)
      end
    end
    return symlinks
  end

  # Runs provisioning for the given machines that
  # matches the given arguments.
  def Provision.run_provisions(machines, arguments)
    Provision.machine_list(machines, arguments).each do |machine|
      symlinks = Provision.configure_synced_folders(machine.machine[:synced_folders])
      machine.machine[:provisions].each do |p|
        unless Provision.new.run_provision(p) then
          abort "Provision exited with non-zero status.".red
        end
      end
      symlinks.each do |symlink|
        system('rm', '-v', File.expand_path(symlink))
      end
    end
  end

  ## Instance Methods

  # Executes the provisioner with the given provisioning data.
  # Only the file and shell provisioners are implemented.
  def run_provision(provision)
    case provision[:kind]
      when 'shell' then shell_provision(provision)
      when 'file'  then file_provision(provision)
      else abort "Unrecognized provision '#{provision[:kind]}'.".red
    end
  end

  # Executes the file provisioner with the given provisioning data.
  def file_provision(provision)
    if provision.has_key?(:target) and not provision.has_key?(:destination) then
      provision[:destination] = provision.delete(:target) + '/' + File.basename(provision[:source])
    end
    unless provision.has_key?(:source) then error provision[:kind], "missing attribute 'source'." end
    unless provision.has_key?(:destination) then error provision[:kind], "missing attribute 'destination'." end
    unless File.exists?(provision[:source]) then error provision[:kind], "source '#{provision[:source]}' does not exist." end
    echo provision[:kind], "#{provision[:name]}"
    destination = File.expand_path(provision[:destination])
    if system('mkdir', '-pv', File.dirname(destination)) then
      return system('cp', '-v', File.expand_path(provision[:source]), destination)
    else
      error provision[:kind], "unable to access destination."
    end
  end

  # Executes the shell provisioner with the given provisioning data.
  def shell_provision(provision) 
    unless provision.has_key?(:inline) or provision.has_key?(:path) then
      error provision[:kind], "missing attribute 'inline' or 'path'."
    else
      upload_path = shell_upload_path(provision)
      if provision.has_key?(:inline) then
        echo provision[:kind], "#{provision[:name]}, inline script"
        File.open(upload_path, 'w') {|f| f.write("#!/bin/bash\n" + provision[:inline])}
      else
        echo provision[:kind], "#{provision[:name]}, path #{provision[:path]}"
        system('cp', '-v', File.expand_path(provision[:path]), upload_path)        
      end
      unless File.exists?(upload_path) then
        error provision[:kind], "script not accessible."
      else
        return_value = system('chmod', '+x', upload_path) and run_command(provision, upload_path)
        system('rm', '-v', File.expand_path(upload_path))
        return return_value
      end
    end
  end

  # Quote and escape strings for shell execution, thanks to Capistrano.
  def quote_and_escape(text, quote = '"')
    "#{quote}#{text.gsub(/#{quote}/) { |m| "#{m}\\#{m}#{m}" }}#{quote}"
  end

  # Returns the upload path for the shell script.
  def shell_upload_path(provision)
    if provision.has_key?(:upload_path) then
      provision[:upload_path]
    else
      "/tmp/shell_#{(0..16).to_a.map {|a| rand(16).to_s(16)}.join}"
    end
  end

  # Executes the given command with the given provisioning data.
  def run_command(provision, command)
    sudo = (not provision.has_key?(:privileged) or provision[:privileged])
    system(process_env(provision), "#{'sudo ' if sudo}#{command} #{process_args(provision)}")
  end

  # Processes the arguments for the shell script.
  def process_args(provision)
    if provision[:args].is_a?(String) then
      provision[:args]
    elsif provision[:args].is_a?(Array) then
      provision[:args].map {|a| quote_and_escape(a)}.join(' ')
    else
      ""
    end
  end

  # Processes the environment variables for the shell script.
  def process_env(provision)
    provision[:env] ||= {}
  end

  # Raise the given message with the given step label as an error.
  def error(step, message)
    abort "#{step.upcase}: #{message}".red
  end

  # Prints the given message with the given step label 
  # to the standard output.
  def echo(step, message)
    puts "#{step.upcase}: #{message}".green
  end

end
