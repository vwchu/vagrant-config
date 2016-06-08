#--------------------------------------------------
# machine.rb
#
# Represents each virtual machine and the
# associated machine configurations and the
# virtual machine provisioner settings.
#--------------------------------------------------
class Machine

  ## Class methods

  # Recursively, convert hash keys from string keys
  # to symbol keys. Returns the newly transformed
  # object.
  def Machine.key_to_sym(value)
    if value.is_a?(Array) then
      value.map {|v| Machine.key_to_sym(v)}
    elsif value.is_a?(Hash) then
      value.inject({}) {|memo, (k, v)| memo[k.to_sym] = Machine.key_to_sym(v); memo}
    else
      value
    end
  end

  # Merges given base with the derived properties, fields and values.
  # Returns merged object with derived properties, fields and values.
  def Machine.inherit(base, derived)
    base.merge(derived) do |key, oldval, newval|
      if oldval.is_a? Hash then
        Machine.inherit(oldval, newval)
      elsif oldval.is_a? Array then
        oldval + newval
      else
        newval
      end
    end
  end

  # Resolves each machines with its inherited properties and fields
  # from its inherited machines with its derived values.
  def Machine.resolve_dependency(settings)
    r = [], d = []
    settings[:machines].each {|m| (d if m.has_key?(:inherit) else r).push(m)}
    until d.empty? then
      old_count = d.count
      d.delete_if do |dep|
        machines = r.select {|m| m[:name] == dep[:inherit]}
        if machines.empty? then
          return false
        else
          r.push(Machine.inherit(machines.first, dep))
          return true
        end
      end
      if d.count == old_count then # no progress
        raise "cannot resolve dependencies for all machines"
      end
    end
    return r
  end

  # Configures the machines with the given settings
  def Machine.configure(config, settings)
    settings = Machine.key_to_sym(settings)
    unless settings.nil? then
      settings[:machines] = Machine.resolve_dependency(settings[:machines])
      settings[:machines].each do |machine|
        config.vm.define machine[:name] do |cnf|
          m = Machine.new(cnf, machine, settings)
          ['box', 'ssh', 'providers', 'network', 'synced_folders', 'provision'].each do |key|
            m.send("config_#{key}")
          end
        end
      end
    end
  end

  ## Instance methods

  # Constructs and initializes a new Machine
  # instance with the given VM configuration,
  # machine data and provisioning settings
  def initialize(config, machine, settings)
    @name     = "#{settings[:project]}-#{machine[:name]}"
    @config   = config
    @machine  = machine
    @settings = settings
  end

  # Configures supported fields for base box
  # for which the machine will be based on and
  # inherit from.
  def config_box()
    [:box, :box_url, :box_version].each do |k|
      @config.vm.send("#{k.to_s}=", @machine[k]) if @machine.has_key?(k)
    end
  end

  # Configures the SSH properties for how
  # Vagrant will access your machine over SSH.
  def config_ssh()
    [:username, :password, :shell, :private_key_path, :insert_key].each do |k|
      @config.ssh.send("#{k.to_s}=", @machine[:ssh][k]) if @machine[:ssh].has_key?(k)
    end
  end

  ## Provider Configurations

  # Configures the machine for each specified provider.
  # Current supported providers: virtualbox, vmware_fusion,
  # vmware_workstation and parallels.
  def config_providers()
    @machine[:providers].each do |name, config|
      config[:name] ||= @name
      @config.vm.provider name do |vm|
        case name
          when :virtualbox then config_virtualbox(vm, config)
          when :vmware_fusion, :vmware_workstation then config_vmware(vm, config)
          when :parallels then config_parallels(vm, config)
          else raise "Unrecognized provider: #{name.to_s}"
        end
      end
    end
  end

  # Configures the machine for the virtualbox provider.
  def config_virtualbox(vb, config)
    config.each do |key, value|
      case key
        when :name, :gui, :linked_clone, :cpus, :memory then vb.send("#{key.to_s}=", value)
        when :customize then value.each {|k, v| vb.customize(['modifyvm', :id, "--#{k.to_s}", v]) }
        when :vbmanage  then value.each {|v|    vb.customize(v.map {|arg| :id if arg == ':id' else arg }) }
        else raise "Bad Virtualbox '#{key.to_s}' configuration."
      end
    end
  end

  # Configures the machine for the vmware provider.
  def config_vmware(vmware, config)
    config.each do |k, v|
      vmware.vmx[case k
        when :name   then 'displayName'
        when :memory then 'memsize'
        when :cpus   then 'numvcpus'
        when :ostype then 'guestOS'
        else k.to_s
      end] = (case k
        when k == :ostype then v.gsub(/_/, '-')
        else v
      end)
    end
  end

  # Configures the machine for the parallels provider.
  def config_parallels(para, config)
    config.each do |k, v|
      para.send("#{k.to_s}=", v)
    end
  end

  ## Network Configurations

  # Configures the various metworks the machine
  # should be able to connect to.
  def config_network()
    @machine[:networks].each do |net|
      @config.vm.network net[:kind], (case net.delete(:kind)
        when 'forwarded_port'  then config_net_fwport(net)
        when 'private_network' then config_net_private(net)
        when 'public_network'  then config_net_public(net)
      end)
    end
  end

  # Configures the port forwarding for the machine.
  def config_net_fwport(net)
    return net
  end

  # Configures the private network for the machine.
  def config_net_private(net)
    if net[:ip] == 'dynamic' then
      net.delete(:ip)
      net[:type] = 'dhcp'
    end
    return net
  end

  # Configures the public network for the machine.
  def config_net_public(net)
    net.delete(:ip) if net[:ip] == 'dynamic'
    return net
  end

  # Configures synced folders that enable Vagrant to sync a folder
  # on the host machine to the guest machine, allowing you to
  # continue working on your project's files on your host machine,
  # but use the resources in the guest machine to compile or run
  # your project.
  def config_synced_folders()
    @machine[:synced_folders].each do |sf|
      @config.vm.synced_folder sf[:host], sf[:guest] do |config|
        [:create, :group, :owner, :mount_options].each do |key|
          config.send("#{key.to_s}=", sf[key]) if sf.has_key?(key)
        end
      end
    end
  end

  # Configures and executes the specified provisioning
  # rules and routines that specialize the machine.
  # Current provisioner supported: file, shell
  def config_provision()
    @machine[:provisions].each do |config|
      kind = config.delete(:kind)
      config[:run] = 'once' unless config.has_key?(:run)
      case kind
        when 'shell' then # do nothing
        when 'file'  then
          next unless File.exists?(config[:source])
          if config.has_key?(:target) and not config.has_key?(:destination) then
            config[:destination] = config.delete(:target) + '/' + File.basename(config[:source])
          end
        else raise "Unrecognized provision '#{kind}'."
      end
      @config.vm.provision config[:name], type: kind, run: config[:run] do |p|
        case kind
          when 'file'  then config_provision_file(p, config)
          when 'shell' then config_provision_shell(p, config)
        end
      end
    end
  end

  # Configures file provisioning with the given configs
  def config_provision_file(p, config)
    [:source, :destination].each do |key|
      p.send("#{key.to_s}=", config[key]) if config.has_key?(key)
    end
  end

  # Configures shell provisioning with the given configs
  def config_provision_shell(p, config)
    [:inline, :path, :privileged, :args, :env, :upload_path, :binary].each do |key|
      p.send("#{key.to_s}=", config[key]) if config.has_key?(key)
    end
  end

end # Machine
