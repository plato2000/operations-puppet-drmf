# == Class: drmf::latexml==
class drmf::latexml(
   $latexmlPort = 9999,
   $customInputs = '/semantic-macros/DRMF',
)  {
  package { [
     'libarchive-zip-perl',
     'libfile-which-perl',
     'libimage-size-perl',
     'libio-string-perl',
     'libjson-xs-perl',
     'libwww-perl',
     'libparse-recdescent-perl',
     'liburi-perl',
     'libxml2',
     'libxml-libxml-perl',
     'libxslt1.1',
     'libxml-libxslt-perl',
     'perlmagick',
     'make',
     'libplack-perl',
     'libapache2-mod-perl2'
  ]:
  }
  file { '/vagrant/srv/latexml':
    ensure => 'directory',
  }
  git::clone { 'latexml':
    remote    => 'https://github.com/brucemiller/LaTeXML.git',
    directory => '/vagrant/srv/latexml/LaTeXML',
    require   => File['/vagrant/srv/latexml/']
  }
  git::clone { 'ltxpsgi':
    remote    => 'https://github.com/dginev/LaTeXML-Plugin-ltxpsgi.git',
    directory => '/vagrant/srv/latexml/ltxpsgi',
  }
  git::clone { 'search':
    remote    => 'https://github.com/KWARC/LaTeXML-Plugin-MathWebSearch.git',
    directory => '/vagrant/srv/latexml/search',
  }
 
  exec { 'install latexml':
    command => 'perl Makefile.PL && make && make install',
    timeout => 10000,
    cwd     => '/vagrant/srv/latexml/LaTeXML',
    creates => '/usr/local/bin/latexml',
    require => [
		Package['apache2'],
	        Package['libarchive-zip-perl'],
	        Package['libfile-which-perl'],
   	        Package['libimage-size-perl'],
	        Package['libio-string-perl'],
	        Package['libjson-xs-perl'],
	        Package['libwww-perl'],
	        Package['libparse-recdescent-perl'],
	        Package['liburi-perl'],
	        Package['libxml2'],
	        Package['libxml-libxml-perl'],
	        Package['libxslt1.1'],
	        Package['libxml-libxslt-perl'],
	        Package['texlive'],
	        Package['imagemagick'],
	        Package['perlmagick'],
	        Package['make'],
		Git::Clone['latexml'],
	       ]
  }
  exec { 'install ltxpsgi':
    command => 'perl Makefile.PL && make && make install',
    timeout => 10000,
    cwd     => '/vagrant/srv/latexml/ltxpsgi',
    creates => '/usr/local/bin/ltxpsgi',
    require => [
		Package['apache2'],
		Git::Clone['ltxpsgi'],
		Exec['install latexml']
	       ]
  }

  exec { 'install search':
    command => 'perl Makefile.PL && make && make install',
    timeout => 10000,
    cwd     => '/vagrant/srv/latexml/search',
    creates => '/usr/local/share/perl/5.18.2/LaTeXML/resources/XSLT/MWSquery.xsl',
    require => [
		Package['apache2'],
		Git::Clone['search'],
		Exec['install ltxpsgi']
	       ]
  }

  apache::conf { 'latexml':
    conf_type => 'sites',
    ensure  => present,
    content => template('drmf/latexml.conf.erb'),
    require => Exec['install search'],
  }


  exec { 'deploy latexml':
    notify  => Service['apache2'],
    command => 'a2ensite 50-latexml',
    timeout => 1800,
    cwd     => '/vagrant/srv/latexml',
    require => [
      Apache::Conf['latexml'],
      Exec['install search']
    ],
  }

}
