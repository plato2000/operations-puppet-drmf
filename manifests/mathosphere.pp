# == Class: drmf::mathosphere==
class drmf::mathosphere {
## BASEX Backend
  package { [
    'openjdk-8-jdk',
    'maven',
    'tomcat7'
  ]:
  }
  git::clone { 'mathosphere':
    remote    => 'https://github.com/TU-Berlin/mathosphere',
    directory => '/vagrant/srv/mathosphere',
  }
  exec { 'build mathosphere':
    command => '/usr/bin/mvn clean install -Dgpg.skip=true',
    timeout => 1800,
    cwd     => '/vagrant/srv/mathosphere',
    require => Git::Clone['mathosphere'],
    creates => '/vagrant/srv/mathosphere/target'
  }

}