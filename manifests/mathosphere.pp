# == Class: drmf::mathosphere==
class drmf::mathosphere(
  $M2_HOME = '/usr/bin/maven'
)  {
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

  file { "$M2_HOME/conf/settings.xml":
    ensure => present,
    source => 'puppet:///modules/drmf/settngs.xml',
    require => Package['maven'],
  }

  file { "/etc/tomcat7/tomcat-users.xml":
    ensure => present,
    source => 'puppet:///modules/drmf/tomcat-users.xml',
    require => Package['tomcat7'],
  }
}