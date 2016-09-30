# ORIS Development Environment

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
- Put any websites that you want hosted into `~/Sites`. These will automatically be mapped to `/var/www` in the VM (using 2-way NFS)
- Install the environment

```bash
mkdir Vagrant
cd Vagrant
git clone git@github.com:wunc/localvm.git localvm
```

- Configure as needed
	- *modify or add components:* All of the configuration is set in one file: `puphpet/config.yaml`. One thing you may want to change: find the `chosen_provider` and set it appropriately (either to vmware_fusion or virtualbox).
	- *customize your environment:* If you want to change any dot-files, they are located in `puphpet/files/dot`; edit them prior to starting the vm and they will be copied over to the vm on boot. If you want to override any of the default settings, create a file called `puphpet/config-custom.yaml`. Use the same style as the default `config.yaml` and change (or add) the desired setting.
- Load the environment

```bash
cd localvm
vagrant up
```

The last command will take a while to complete (the first time you run it), as it has to download the image, install it, run it, and install all of the included software.

- Edit your `hosts` file:

```bash
sudo nano /etc/hosts
```

- Add the following to the bottom of your `hosts` file:

```
192.168.57.101	local.dev
192.168.57.101  www.local.dev
192.168.57.101  localvm.dev
```

along with any other dev domains that you would like to set up

### Usage

- Local editing:
	- put your websites in subfolders of `~/Sites`.
	- any local edits to files in that directory will quickly auto-sync to the VM.
	- example: you might create `~/Sites/wordpress`. You can then access it at `http://local.dev/wordpress`.
- Vagrant commands (must be run while in the `localvm` folder)
	- `vagrant up` # start the VM
	- `vagrant halt` # shut down the VM
	- `vagrant ssh` # ssh into the VM
	- `vagrant suspend` # suspend the VM
	- `vagrant resume` # resume a suspended VM
	- `vagrant provision` # read the config.yaml file and apply any changes to the VM
- Web server:
	- [http://192.168.57.101](http://192.168.57.101)
	- [http://local.dev](http://local.dev)
- MySQL server:
	- mysql username: `root`, password: `123`
	- extra mysql username: `dbuser`, password: `123`
	- Sequel Pro or MySQL Workbench: use SSH tunnel to SSH Host `192.168.57.101` with username `vagrant` and ssh-key `Vagrant/localvm/puphpet/files/dot/ssh/id_rsa`. MySQL Host `127.0.0.1` with username `root` and password `123`. 
- Adminer (replaces PHPMyAdmin; see [below](#adminer))
	- [http://local.dev/html/adminer](http://local.dev/html/adminer)
- MailHog (replaces Mailcatcher)
	- [http://192.168.57.101:8025](http://192.168.57.101:8025)
	- [http://local.dev:8025](http://local.dev:8025)

### Optional Nice Stuff

#### Dynamic Virtualhosts

The Apache web server is configured to accept certain virtual hostname patterns and properly set the VirtualDocumentRoot for them. This way, you don't have to edit the `config-custom.yaml` and re-provision the VM every time you want to add a new vhost.

- Bedrock-style WordPress
	- `*.wp.dev` uses `/var/www/*/web` (~/Sites/*/web on your computer) as its DocumentRoot
- Laravel
	- `*.lvl.dev` uses `/var/www/*/public` (~/Sites/*/web on your computer) as its DocumentRoot
- General
	- `*.dev` uses `/var/www/*` (`~/Sites/*` on your computer) as its DocumentRoot

In order for this to work, your computer must have it's DNS set up to also dynamically point to the Vagrant VM. For Macs, you can install dnsmasq via Homebrew:

```bash
# Update Homebrew
brew update
# Install dnsmasq
brew install dnsmasq
# Create the dnsmasq.conf file
mkdir -pv $(brew --prefix)/etc/
echo 'address=/.dev/192.168.57.101' > $(brew --prefix)/etc/dnsmasq.conf
echo 'listen-address=127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
# Add dnsmasq to the list of DNS resolvers
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'
# Start the dnsmasq service
sudo brew services start dnsmasq
```

After installation, you will probably have to reboot for it to take effect.

#### Passwordless Vagrant Up

There are two components that require "sudo" passwords in this vagrant setup: [NFS](https://www.vagrantup.com/docs/synced-folders/nfs.html) and [Vagrant Host Manager](https://github.com/devopsgroup-io/vagrant-hostmanager). They will often prompt you for your password whenever you do a `vagrant up`. To bypass this, edit the sodoers file:

```bash
sudo visudo
```

and add the following lines (these are OS X specific, replace `<username>` with your home folder name):

```ini
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp /Users/<username>/.vagrant.d/tmp/hosts.local /etc/hosts
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e * d -ibak /etc/exports
%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE, VAGRANT_HOSTMANAGER_UPDATE
```

You can change %admin to your own username or `%staff` if you are not a local admin.

#### Adminer:

I recommend using a dedicated database tool, like [MySQL Workbench](http://www.mysql.com/products/workbench/) or [Sequel Pro](https://www.sequelpro.com/). The VM does come with Adminer, but it may be overwritten if you are upgrading from a previous version. Adminer is a single PHP file, and therefore is very easy to re-install: just [download it](https://www.adminer.org/) (I recommend the English-only MySQL version), save it as `~/Sites/adminer/index.php`. Then, you should be able to access it at `http://local.dev/adminer`.

#### Set the VM system timezone

If your system timezone is incorrect, run the following command to set it

```bash
timedatectl set-timezone America/Chicago
```

#### Install a nice GUI

There is a free menubar app called [Vagrant Manager](http://vagrantmanager.com/) that will help you manage this dev environment. If you prefer that over the command line, install it from the link.

#### Auto-update /etc/hosts

The plugin [Vagrant Host Manager](https://github.com/smdahlen/vagrant-hostmanager) will automatically update the host machine's `/etc/hosts` file with the defined Apache vhosts in the guest VM. Nice! In you host machine type:

```bash
vagrant plugin install vagrant-hostmanager
```

#### SSH-Agent forwarding

The environment is configured to forward your host computer's SSH keys into the VM, so that you can, for example, commit to Github or do Capistrano deployments from within the VM. You need to have your host computer configured properly for this to work, however.  To do so, use [Github's guide to using SSH agent forwarding](https://developer.github.com/guides/using-ssh-agent-forwarding/).

Note: on macOS 10.12 (Sierra), saved ssh keys are not automatically reloaded into the agent upon reboot. A fix is available [here](https://github.com/jirsbek/SSH-keys-in-macOS-Sierra-keychain).

### Updating

*First a note:* Try not to make any manual changes to Linux inside your VM. Doing so removes the ability to reusably recreate it should the need arise. Keeping all of your customizations centralized in the `config.yaml` file is the best practice. Better yet, submit any customizations as a pull request to this repository, so everyone on the team can benefit.

To update to the latest version (from the localvm folder):

```bash
git pull
vagrant up # if not already running
vagrant provision
```

#### Upgrading from version 1.0

```bash
# first backup any databases that you would like to keep!
vagrant destroy # destroy the old VM
git pull # get the latest version
vagrant up # this should also provision because it's a new VM
```

Happy developing!

