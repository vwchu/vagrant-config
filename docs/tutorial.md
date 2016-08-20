# <a name="top"></a> Tutorial

[Back to Main](../README.md)

This is a guided tutorial for using this tool.

* [Example Environment](#example)
* [Configuring the Environment](#configure)
* [Modularize the Configuration](#modularize)
* [Modifying Machines: Boost CPU and Memory](#boost)
* [Modifying Machines: Add Synced Folders](#synced_folders)

## <a name="example"></a> Example Environment

We want to create an example environment with the following machines and requirements: 

* `homestead` based on `laravel/homestead` and requires:
  * a Bridged public network with a DHCP assigned IP address
* `webdev` based on `ubuntu/trusty64` and requires:
  * a private network with IP: `192.168.56.101`
  * Ruby using `rvm` with: `bundler` and `rake` gems
  * Node using `node`
* `lamp-server` based on `ubuntu/trusty64` and requires:
  * same as `webdev` machine
  * `lamp-server` package
* `jekyll` based on `ubuntu/trusty64` and requires:
  * same as `webdev` machine
  * Ruby using `rvm` with additional: `jekyll` gems

## <a name="configure"></a> Configuring the Environment

We can create the specified environment as follows:

```yaml
# vagrant.yml
project: example
machines:

  base:
    box: ubuntu/trusty64
    abstract: true
    ssh: {shell: bash -c 'BASH_ENV=/etc/profile exec bash'}
    providers: 
      virtualbox: {
        cpus: 1, memory: 1024, customize: {groups: /_vagrant}
      }

  laravel: 
    box: laravel/homestead
    inherit: base
    networks:
      - kind: public_network
        ip: dynamic
    provisions:
      - kind: shell
        name: composer
        privileged: false
        inline: |
          composer global require "laravel/installer"
          echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc

  webdev:
    inherit: base
    networks: [{kind: private_network, ip: '192.168.56.101'}]
    provisions:

      - kind: shell
        name: basics
        privileged: true
        inline: |
          apt-get update
          apt-get install -y git gnupg

      - kind: shell
        name: ruby
        privileged: false
        args: [bundler, rake]
        inline: |
          get_gpg_key() { gpg --keyserver hkp://keys.gnupg.net --recv-keys $1 || (curl -sSL https://rvm.io/mpapis.asc | gpg --import - ); }
          install_ruby() { curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=$(echo "$@" | tr '[:blank:]' ','); }
          get_gpg_key '409B6B1796C275462A1703113804BB82D39DC0E3' && install_ruby "$@"

      - kind: shell
        name: node
        privileged: false
        inline: |
          config_environ() {
            echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
            echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bashrc
          }
          export NVM_DIR="$HOME/.nvm" && (
            git clone https://github.com/creationix/nvm.git "$NVM_DIR"
            cd "$NVM_DIR"
            git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
          ) && . "$NVM_DIR/nvm.sh" && nvm install node && config_environ

  lamp-server:
    inherit: webdev
    provisions:
      - kind: shell
        name: lamp-server
        privileged: true
        inline: |
          apt-get update
          apt-get install -y lamp-server

  jekyll:
    inherit: webdev
    provisions:
      - kind: shell
        name: jekyll
        privileged: false
        inline: 'rvm use ruby && gem install $@'
        args: [jekyll]
```

### Running the Machines

To run all of them at the same time:

```bash
bash vagrant.sh up
```

To run a specific one, for instance `jekyll`:

```bash
bash vagrant.sh up jekyll
```

## <a name="modularize"></a> Modularize the Configuration

We can modularize the configurations into multiple smaller files,
so that we can reuse components and composite the configurations to
our liking.

```yaml
# vagrant.yml
includes:
  - base
  - laravel
  - webdev
  - lamp-server
  - jekyll

# base.yml
project: example
machines:
  base:
    box: ubuntu/trusty64
    abstract: true
    ssh: {shell: bash -c 'BASH_ENV=/etc/profile exec bash'}
    providers: 
      virtualbox: {
        cpus: 1, memory: 1024, customize: {groups: /_vagrant}
      }

# laravel.yml
machines:
  laravel: 
    box: laravel/homestead
    inherit: base
    networks:
      - kind: public_network
        ip: dynamic
    provisions:
      - kind: shell
        name: composer
        privileged: false
        inline: |
          composer global require "laravel/installer"
          echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc

# webdev.yml
machines:
  webdev:
    inherit: base
    networks: [{kind: private_network, ip: '192.168.56.101'}]
    provisions:

      - kind: shell
        name: basics
        privileged: true
        inline: |
          apt-get update
          apt-get install -y git gnupg

      - kind: shell
        name: ruby
        privileged: false
        args: [bundler, rake]
        inline: |
          get_gpg_key() { gpg --keyserver hkp://keys.gnupg.net --recv-keys $1 || (curl -sSL https://rvm.io/mpapis.asc | gpg --import - ); }
          install_ruby() { curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=$(echo "$@" | tr '[:blank:]' ','); }
          get_gpg_key '409B6B1796C275462A1703113804BB82D39DC0E3' && install_ruby "$@"

      - kind: shell
        name: node
        privileged: false
        inline: |
          config_environ() {
            echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
            echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.bashrc
          }
          export NVM_DIR="$HOME/.nvm" && (
            git clone https://github.com/creationix/nvm.git "$NVM_DIR"
            cd "$NVM_DIR"
            git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
          ) && . "$NVM_DIR/nvm.sh" && nvm install node && config_environ

# lamp-server.yml
machines:
  lamp-server:
    inherit: webdev
    provisions:
      - kind: shell
        name: lamp-server
        privileged: true
        inline: |
          apt-get update
          apt-get install -y lamp-server

# jekyll.yml
machines:
  jekyll:
    inherit: webdev
    provisions:
      - kind: shell
        name: jekyll
        privileged: false
        inline: 'rvm use ruby && gem install $@'
        args: [jekyll]
```

### <a name="boost"></a> Modifying Machines: Boost CPU and Memory

Boost the CPU and memory for the machines in the environment
from 1 CPU to 2 and from 1 GB of memory to 4 GB:

```yaml
# boost.yml
machines:
  base:
    providers: 
      virtualbox: {
        cpus: 2, memory: 4096
      }
```

To add `boost` for a specific run of the `laravel` machine:

```bash
bash vagrant.sh --configs=vagrant,boost up laravel
```

To add `boost` permanently for all machines, edit `vagrant.yml` as follows:

```yaml
# vagrant.yml
includes:
  - base
  - laravel
  - webdev
  - lamp-server
  - jekyll
  - boost
```

### <a name="synced_folders"></a> Modifying Machines: Add Synced Folders

Add synced folders for the machines in the environment.
Specifically, add:

* The current working directory
* The installation directory of this project

Add:

```erb
# synced_folders.yml.erb
machines:
  base:
    synced_folders:
      - host: '.'
        guest: /home/vagrant/vagrant_root
        create: true
      - host: <%= ENV['VAGRANT_VAGRANTFILE_DIRPATH'] %>
        guest: /home/vagrant/.setup
        create: true
```

To add `synced_folders` for a specific run of the `webdev` machine:

```bash
bash vagrant.sh --configs=vagrant,synced_folders.yml.erb up webdev
```

To add `synced_folders` permanently for all machines, edit `vagrant.yml` as follows:

```yaml
# vagrant.yml
includes:
  - base
  - laravel
  - webdev
  - lamp-server
  - jekyll
  - synced_folders.yml.erb
```

**Note**: For ERB configurations, the file extension must be included
in the `includes` property or the `--configs` option.

[Back to Top](#top)
