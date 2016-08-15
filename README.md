# Vagrant VM configuration tool

A small tool for specifying and configuring a multiple machine
environment using the virtual machine management and
automation tool, Vagrant, from a YAML or JSON file.

## Usage

To create or configure a single or multiple virtual machine
environment, create a `vagrant.yml` based on the documentation and example
provided in the [`vagrant.doc.yml`](vagrant.doc.yml) file. Once the YAML file
is configured, execute in the terminal the command:

```bash
vagrant up [vm]
```

To create a packaged virtual machine, once the YAML file is configured,
execute in the terminal the command:

```bash
bash vagrant_box.sh [vm]
```

Outputs the created box into the `boxes` directory.

**Note:** Not all Vagrant features are implemented, yet.

## Requirements

* [Oracle VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com/)
