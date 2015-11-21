# Warning

This module a work in progress and is not guranteed to be stable.
Please do not use it at the moment.

# Description

Puppet module to install and configure the software components
relevant to the Digital Repository of Mathematical Formulae project.
# Prerequisites

This role requires a vagrant or labs-vagrant instance.

## Creating a labs-vagrant instance

Add a new instance at

 https://wikitech.wikimedia.org/wiki/Special:NovaInstance
 
 
by clicking [add instance](https://wikitech.wikimedia.org/w/index.php?title=Special:NovaInstance&action=create&project=math&region=eqiad).

Select the version with 2 CPUs and assign a name that begins with drmf.

Wait until the instance status is "ACTIVE" and puppet status is "OK".

Now, click on configure and enable the puppet role `role::labs::mediawiki_vagrant`.

Log into the instance and force a puppet and labs vagrant run via
```
sudo puppet agent -tv
```
This might take some time. In the meantime you can perform the optional step.

(Optional) Add a web-proxy by visiting the Manage proxies page

  https://wikitech.wikimedia.org/wiki/Special:NovaProxy
  
and clicking on [create proxy](https://wikitech.wikimedia.org/w/index.php?title=Special:NovaProxy&action=create&project=math&region=eqiad)

Now log out and login again for convinience create a shortcut to the vagrant folder
```
sudo ln -s /srv/mediawiki-vagrant/ /vagrant
cd /vagrant
vagrant provision
```
Now, you are ready to enable the DRMF role. Follow the instructions below.

In case of problebs visit 

https://wikitech.wikimedia.org/wiki/Labs-vagrant

# Installation

Clone (or copy) this repository into your puppet modules/drmf directory:

```bash
git clone https://github.com/DRMF/operations-puppet-drmf modules/drmf
```

Or you could also use a git submodule:

```bash
git submodule add git@github.com:DRMF/operations-puppet-drmf.git modules/drmf
git commit -m 'Adding modules/drmf as a git submodule.'
git submodule init && git submodule update
```

Create a link to to the puppet role:

```bash
ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.pp /vagrant/puppet/modules/role/manifests/drmf.pp
ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.yaml /vagrant/puppet/modules/role/settings/drmf.yaml
```

and enable the newly created drmf role via
```bash
vagrant enable-role drmf && vagrant provision
```


(PS: The last step with the symbolic link is temporary workaround.)
## Manual installation of mathosphere
```bash
git clone git@github.com:TU-Berlin/mathosphere.git /vagrant/srv/mathosphere --recursive
sudo chown mwvagrant mathosphere -R
cd /vagrant
vagrant ssh
sudo apt-get install maven tomcat7  tomcat7-admin openjdk-8-jdk -y
cd /vagrant/srv/mathosphere/
sudo update-alternatives --config java
export MAVEN_OPTS=-Xmx256m
mvn clean install -DskipTests
```
copy the following files:


See also
[MediaWiki-Vagrant in Labs](https://wikitech.wikimedia.org/wiki/Help:MediaWiki-Vagrant_in_Labs).
