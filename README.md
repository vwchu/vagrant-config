# Vagrant VM configuration tool

A small tool for specifying and configuring a multiple machine
environment using the virtual machine management and
automation tool, Vagrant, from a YAML or JSON file or a ERB 
templating file that generates a YAML or JSON output. Multiple
configuration files can also be cascaded and merged together
dynamically to composite machines using the `includes` property or
the `--configs` option.

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
bash vagrant.sh up [vm]
```

**Note:** Not all Vagrant features are implemented, yet.

For more detailed examples and a tutorial, see [here](docs/tutorial.md)

## Requirements

* [Oracle VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com/)
