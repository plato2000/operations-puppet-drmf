# == Class: drmf::mathosphere==
class drmf::mathosphere(
  $M2_HOME = '/usr/share/maven',
  $tomcatPort = 8081
)  {
  package { [
    'openjdk-8-jdk',
    'maven',
    'tomcat7',
    'tomcat7-admin'
  ]:
  }
  git::clone { 'mathosphere':
    remote    => 'https://github.com/TU-Berlin/mathosphere',
    directory => '/vagrant/srv/mathosphere',
  }
  exec { 'build mathosphere':
    command => '/usr/bin/mvn clean install -Dgpg.skip=true -DskipTests=true -Dmaven.javadoc.skip=true -B -V',
    timeout => 1800,
    cwd     => '/vagrant/srv/mathosphere',
    require => Git::Clone['mathosphere'],
    creates => '/vagrant/srv/mathosphere/target'
  }

  file { "$M2_HOME/conf/settings.xml":
    ensure  => present,
    content => template('drmf/settings.xml.erb'),
    require => Package['maven'],
  }

  file { "/etc/tomcat7/tomcat-users.xml":
    ensure  => present,
    content => 'puppet:///modules/drmf/tomcat-users.xml',
    require => Package['tomcat7'],
    notify  =>  Service['tomcat7']
  }

  file { "/etc/tomcat7/server.xml":
    ensure  => present,
    content => template('drmf/server.xml.erb'),
    require => Package['tomcat7'],
    notify  =>  Service['tomcat7']
  }

  service { 'tomcat7':
    ensure  => "running",
    enable  => "true",
    require => Package["tomcat7"],
  }

  exec { 'deploy mathosphere':
    command => '/usr/bin/mvn clean install tomcat7:redeploy -Dgpg.skip=true ',
    timeout => 1800,
    cwd     => '/vagrant/srv/mathosphere/restd',
    require => [
      File["/etc/tomcat7/tomcat-users.xml"],
      File["/etc/tomcat7/server.xml"],
      File["$M2_HOME/conf/settings.xml"],
      Exec['build mathosphere']
    ],
  }
}