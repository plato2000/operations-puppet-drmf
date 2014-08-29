# Warning

This module is not work in progress and not guranteed to be stable.
Please do not use it at the moment.

# Description

Puppet module to install and configure the software components
relevant to the Digital Repository of Mathematical Formulae project.

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
```

and enable the newly created drmf role via
```
labs-vagrant enable-role drmf && labs-vagrant provision

```


(PS: The last step with the symbolic link is temporary workaround.)
