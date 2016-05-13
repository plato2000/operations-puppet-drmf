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
     'make'
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
    creates => '/vagrant/srv/latexml/LaTeXML/Makefile',
    require => [
		Package["apache2"],
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
    creates => '/vagrant/srv/latexml/ltxpsgi/Makefile',
    require => [
		Package["apache2"],
		Git::Clone['ltxpsgi'],
		Exec['install latexml']
	       ]
  }

  exec { 'install search':
    command => 'perl Makefile.PL && make && make install',
    timeout => 10000,
    cwd     => '/vagrant/srv/latexml/search',
    creates => '/vagrant/srv/latexml/search/Makefile',
    require => [
		Package["apache2"],
		Git::Clone['search'],
		Exec['install ltxpsgi']
	       ]
  }

  file { "/etc/apache2/sites-available/latexml.conf":
    notify  => Service['apache2'],
    ensure  => present,
    content => template('drmf/latexml.conf.erb'),
    require => Exec['install search'],
  }


  exec { 'deploy latexml':
    command => 'a2ensite latexml && service apache2 restart',
    timeout => 1800,
    cwd     => '/vagrant/srv/latexml',
    require => [
      File["/etc/apache2/sites-available/latexml.conf"],
      Exec['install search']
    ],
  }

}
