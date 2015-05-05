# UTD ORIS Development Environment

### Introduction

A common problem in website development is working with code created and edited in different environments by team-members. If you want to invite a new developer to work on a project, it is often a hassle getting them all of the necessary tools that the project requires.

This project provides a solution: a virtual machine that provides a common pre-configured development environment with all of the tools necessary for working on projects in the UTD ORIS team.

### Features

- LAMP (Linux, Apache, MySQL, PHP)
- Dependency Managers (composer, npm, bower)
- Others (git, gulp, xdebug, wp-cli, ruby, sass, capistrano, mailcatcher)

### Requirements

- [git](http://git-scm.com/)
- [Virtual Box](https://www.virtualbox.org/), [VMWare Fusion](http://www.vmware.com/products/fusion), or VMWare Workstation
	- note: if you choose VMWare, you will also need a [Vagrant provider license](https://www.vagrantup.com/vmware) for it
- [Vagrant](https://www.vagrantup.com/)

### Installation

- Install the requirements listed above
- Install the environment

```
$ mkdir Vagrant
$ cd Vagrant
$ git clone <clone-url> localvm
```

- Configure as needed
	- All of the configuration is set in one file: `puphpet/config.yaml`. One thing you may want to change: find the `chosen_provider` and set it appropriately (either to vmware_fusion or virtualbox).
	- If you want to change any dot-files, they are located in `puphpet/files/dot`; edit them prior to starting the vm and they will be copied over to the vm on boot. If you want to override any of the default settings, create a file called `puphpet/config-custom.yaml`. Use the same style as the default `config.yaml` and change (or add) the desired setting.
- Load the environment

```
$ cd localvm
$ vagrant up
```

The last command will take a while to complete (the first time you run it), as it has to download the image, install it, run it, and install all of the included software.

### Usage

- Web server:
	- `http://192.168.57.101`
- MySQL server:
	- mysql username: `root`, password: `123`
	- extra mysql username: `dbuser`, password: `123`
	- use SSH tunnel to `192.168.57.101` with username `vagrant` and ssh-key `Vagrant/localvm/puphpet/files/dot/ssh/id_rsa`

### Nice Stuff

Configure phpmyadmin:

```
/usr/sbin/pma-configure
```
