# Vagrant VM configuration tool

A small tool for specifying and configuring a multiple machine
environment using the virtual machine management and
automation tool, Vagrant, from a YAML or JSON file.

## Getting Started

1. Install [VirtualBox](https://www.virtualbox.org)
2. Install [Vagrant](https://www.vagrantup.com/)
3. Clone this repository
4. Add the `bin` directory to your `PATH` environment variable

## Usage

To create or configure a single or multiple virtual machine
environment, create a `vagrant.yml` based on the documentation and example
provided in [`vagrant.doc.yml`](docs/vagrant.doc.yml) file or use the sample
provided in [`vagrant.sample.yml`](docs/vagrant.sample.yml). Once the YAML file
is configured, place in a location of your choice and execute in the terminal 
the following command:

```bash
vagrant.sh up [vm]
```

To create a packaged virtual machine, once the YAML file is configured,
execute in the terminal the command:

```bash
vagrant_box.sh [vm]
```

Outputs the created box into a `boxes` directory
in the current working directory.

**Note:** Not all Vagrant features are implemented, yet.

## Requirements

* [Oracle VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com/)
