# == Class: drmf::mathosphere==
class drmf::mathosphere(
  $M2_HOME = '/usr/share/maven',
  $tomcatPort = 10043,
  $tomcatUser = 'vagrant',
  $tomcatPassword = 'vagrant',
  $openjdk_path = '/usr/lib/jvm/java-8-openjdk-amd64/'
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
    environment => ['MAVEN_OPTS=-Xmx256m'],
    cwd     => '/vagrant/srv/mathosphere',
    require => Git::Clone['mathosphere'],
    creates => '/vagrant/srv/mathosphere/target'
  }

  file { "$M2_HOME/conf/settings.xml":
    ensure  => present,
    content => template('drmf/settings.xml.erb'),
    require => Package['maven'],
  }

  file { "/etc/default/tomcat7":
    ensure  => present,
    content => template('drmf/tomcat7.erb'),
    require => Package['openjdk-8-jdk']
  }

  file { "/etc/tomcat7/tomcat-users.xml":
    ensure  => present,
    content => template('drmf/tomcat-users.xml.erb'),
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
    creates => '/var/lib/tomcat7/webapps/restd.war',
    require => [
      File["/etc/tomcat7/tomcat-users.xml"],
      File["/etc/tomcat7/server.xml"],
      File["$M2_HOME/conf/settings.xml"],
      File["/etc/default/tomcat7"],
      Exec['build mathosphere']
    ],
  }

}
