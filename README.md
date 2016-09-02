# Vagrant VM configuration tool

A small tool for specifying and configuring a multiple machine
environment using the virtual machine management and
automation tool, Vagrant, from a YAML or JSON file or a ERB
templating file that generates a YAML or JSON output. Multiple
configuration files can also be cascaded and merged together
dynamically to composite machines using the `includes` property or
the `--configs` option.

## Getting Started

### Global Installation

1. Install [VirtualBox](https://www.virtualbox.org)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Clone this repository
4. Add the `bin` directory to your `PATH` environment variable
5. Create your configuration files in a location of your choice,
   see [Configuring the Environment](#config).

   **Note:** You must have the root configuration file as `vagrant.yml`
   or `vagrant.json` in the current working directory.

6. Run the command:

   ```bash
   bash vagrant.sh [options] up [vm]
   ```

### Embedded Installation

1. Install [VirtualBox](https://www.virtualbox.org)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Add this repository to your project as a submodule:

   ```bash
   git submodule add https://github.com/vwchu/vagrant-configurator.git .vagrant/configurator
   ```

   Or as a subtree:

   ```bash
   git subtree add --prefix .vagrant/configurator https://github.com/vwchu/vagrant-configurator.git master --squash
   ```

4. Create the directory: `.vagrant/configurations` and add your configurations
   files here, see [Configuring the Environment](#config).

   **Note:** You must have the root configuration file as `vagrant.yml`
   or `vagrant.json` in the `.vagrant/configurations` directory.

5. Add the following `Vagrantfile` file to root directory of your project:

   ```ruby
   ENV["VAGRANT_PROJECT_NAME"] = "your_project_name"
   ENV['VAGRANT_VAGRANTFILE'] = File.expand_path(__FILE__)
   ENV['VAGRANT_CONFIGS'] = ".vagrant/configurations/vagrant"

   load ".vagrant/configurator/Vagrantfile"
   ```

6. Add `.vagrant/machine` to your `.gitignore`.
7. Add the `Vagrantfile` and configuration files to your project's git.
8. Use Vagrant like normal (i.e.: `vagrant up`).

## <a name="config"></a> Configuring the Environment

To create or configure a single or multiple virtual machine
environment, create a `vagrant.yml` based on the documentation and example
provided in [`vagrant.doc.yml`](docs/vagrant.doc.yml) file or use the sample
provided in [`vagrant.sample.yml`](docs/vagrant.sample.yml).

**Note:** Not all Vagrant features are implemented, yet.

For more detailed examples and a tutorial, see [here](docs/tutorial.md).

## Requirements

* [Oracle VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com/)
