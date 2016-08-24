# Warning

This module a work in progress and is not guranteed to be stable.
Please do not use it at the moment.

# Description

Puppet module to install and configure the software components
relevant to the Digital Repository of Mathematical Formulae project.
# Prerequisites

This role requires a vagrant or labs-vagrant instance.

## Creating a labs-vagrant instance

1. Add a new instance at

 https://wikitech.wikimedia.org/wiki/Special:NovaInstance
 by clicking [add instance](https://wikitech.wikimedia.org/w/index.php?title=Special:NovaInstance&action=create&project=math&region=eqiad).

2. Select the version with 2 CPUs and assign a name that begins with drmf.

3. Wait until the instance status is "ACTIVE" and puppet status is "OK". Now, click on configure and enable the puppet role `role::labs::mediawiki_vagrant`.

4. Log into the instance and force a puppet and labs vagrant run via
 ```
 sudo puppet agent -tv
 ```
 This might take some time. In the meantime you can perform the optional step.

5. (Optional) Add a web-proxy by visiting the Manage proxies page

  https://horizon.wikimedia.org/auth/login/?next=/

6. Log out and login again for convinience create a shortcut to the vagrant folder
 
 ```bash
 sudo ln -s /srv/mediawiki-vagrant/ /vagrant
 cd /vagrant
 vagrant up
 vagrant provision
 ```
Now, you are ready to enable the DRMF role. Follow the instructions below.

In case of problems visit 

https://wikitech.wikimedia.org/wiki/Labs-vagrant

# Installation

1. Clone (or copy) this repository into your puppet modules/drmf directory:
 
 ```bash
 git clone https://github.com/DRMF/operations-puppet-drmf modules/drmf
 ```
2. Or you could also use a git submodule:
 
 ```bash
 git submodule add git@github.com:DRMF/operations-puppet-drmf.git modules/drmf
 git commit -m 'Adding modules/drmf as a git submodule.'
 git submodule init && git submodule update
 ```
3. Create a link to to the puppet role:
 
 ```bash
 ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.pp /vagrant/puppet/modules/role/manifests/drmf.pp
 ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.yaml /vagrant/puppet/modules/role/settings/drmf.yaml
 ```
4. Run the MediaWiki `setup.sh` in the `/vagrant` directory.
 Enable the newly created drmf role via
 
 ```bash
 vagrant enable-role drmf && vagrant provision
 ```

NOTE: If you get an error such as 
```
The provider 'lxc' could not be found, but was requested to
back the machine 'default'. Please use a provider that exists.
```

Try logging out and logging back in. There seems to be an issue with aliases and the vagrant command.


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
* [/etc/default/tomcat7](templates/etc/default/tomcat7)
* [/etc/tomcat7/tomcat-users.xml](templates/tomcat-users.xml.erb)
* [/etc/tomcat7/server.xml](templates/server.xml.erb)
* [~/.m2/settings.xml](templates/settings.xml.erb)

Replace all <%= @XXX %> with appropriate values

See also
[MediaWiki-Vagrant in Labs](https://wikitech.wikimedia.org/wiki/Help:MediaWiki-Vagrant_in_Labs).
