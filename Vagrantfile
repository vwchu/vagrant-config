# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

vagrant_cfg = File.expand_path(File.dirname(__FILE__)) + '/vagrant.yml'
vagrant = YAML.load_file(vagrant_cfg)
project = vagrant['project']

Vagrant.configure(2) do |config|
  vagrant['machines'].each do |machine|
    config.vm.define machine['name'] do |vmconfig|

      # Configures supported fields for base box
      # for which the machine will be based on and
      # inherit from.

      ['box', 'box_url', 'box_version'].each do |key|
        vmconfig.vm.send(key + '=', machine[key]) if machine.has_key?(key)
      end # box

      # Configures the machine for each specified provider.
      # Current supported providers: virtualbox.

      machine['providers'].each do |provider, data|
        data['name'] = project + '-' + machine['name'] unless data.has_key?('name')
        vmconfig.vm.provider provider do |vm|
          case provider
            when 'virtualbox' then
              ['name', 'gui', 'linked_clone', 'cpus', 'memory', 'customize'].each do |key|
                if data.has_key?(key) then
                  unless key == 'customize' then
                    vm.send(key + '=', data[key])
                  else # special customization
                    data[key].each do |key, value|
                      vm.customize ['modifyvm', :id, '--' + key, value]
                    end
                  end
                end
              end # each key
          end # case provider
        end # vmconfig.vm.provider
      end # providers

      # Configures the SSH properties for how
      # Vagrant will access your machine over SSH.

      ['username', 'password', 'shell', 'private_key_path', 'insert_key'].each do |key|
        if machine['ssh'].has_key?(key) then
          vmconfig.ssh.send(key + '=', machine['ssh'][key])
        end
      end # ssh

      # Configures the various metworks the machine
      # should be able to connect to.

      machine['networks'].each do |net|
        net = net.inject({}) {|memo, (k, v)| memo[k.to_sym] = v; memo}
        case net[:kind]
          when 'forwarded_port' then
            # do nothing
          when 'private_network' then
            if net[:ip] == 'dynamic' then
              net.delete(:ip)
              net[:type] = 'dhcp'
            end
          when 'public_network' then
            net.delete(:ip) if net[:ip] == 'dynamic'
        end
        vmconfig.vm.network net.delete(:kind), net
      end # networks

      # Configures synced folders that enable Vagrant to sync a folder
      # on the host machine to the guest machine, allowing you to
      # continue working on your project's files on your host machine,
      # but use the resources in the guest machine to compile or run
      # your project.

      machine['synced_folders'].each do |sf|
        vmconfig.vm.synced_folder sf['host'], sf['guest'] do |sfconfig|
          ['create', 'group', 'owner', 'mount_options'].each do |key|
            sfconfig.send(key + '=', sf[key]) if sf.has_key?(key)
          end
        end # vmconfig.vm.synced_folder
      end # synced_folders

      # Configures and executes the specified provisioning
      # rules and routines that specialize the machine.
      # Current provisioner supported: file, shell

      machine['provisions'].each do |p|
        p['run'] = 'once' unless p.has_key?('run')
        if p['kind'] == 'file' then
          if not File.exists?(p['source']) then
            next # does not exist, exit
          end
          if p.has_key?('target') and not p.has_key?('destination') then
            p['destination'] = p.delete('target') + '/' + File.basename(p['source'])
          end
        end
        vmconfig.vm.provision p['name'], type: p['kind'], run: p['run'] do |pconfig|
          case p['kind']
            when 'file' then
              ['source', 'destination']
            when 'shell' then
              ['inline', 'path', 'privileged', 'args', 'env', 'upload_path', 'binary']
            else
              []
          end.each do |key|
            if p.has_key?(key) then
              pconfig.send(key + '=', p[key])
            end
          end
        end # vmconfig.vm.provision
      end # provisions

    end # config.vm.define
  end # machines
end # Vagrant.configure
