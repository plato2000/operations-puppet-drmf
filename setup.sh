#!/bin/bash
sudo puppet agent -tv
source /etc/profile.d/alias-vagrant.sh
echo "shell -$SHELL" >> ~/.screenrc
sudo ln -s /srv/mediawiki-vagrant /vagrant
cd /vagrant
vagrant provision
cd /vagrant/puppet/
git clone https://github.com/DRMF/operations-puppet-drmf modules/drmf
ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.pp /vagrant/puppet/modules/role/manifests/drmf.pp
ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.yaml /vagrant/puppet/modules/role/settings/drmf.yaml
vagrant enable role drmf
vagrant provision