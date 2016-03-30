# == Class: role::drmf ==
class role::drmf {
  include role::mathoid
  include role::mathsearch
  include role::parserfunctions
  include drmf::mathosphere

  mediawiki::settings { 'drmf math':
    priority => 30,
     values   => ['
      $wgMathDisableTexFilter = \'always\';
      $wgLaTeXMLServer        = \'http://gw125.iu.xsede.org:8888\';
      $wgMathDefaultLaTeXMLSetting = array( \'format\' => \'xhtml\', \'whatsin\' => \'math\', \'whatsout\' => \'math\', \'pmml\',  \'cmml\',  \'mathtex\',  \'nodefaultresources\',  \'preload\' => array( \'LaTeX.pool\', \'article.cls\', \'amsmath.sty\', \'amsthm.sty\', \'amstext.sty\', \'amssymb.sty\', \'eucal.sty\', \'[dvipsnames]xcolor.sty\', \'url.sty\', \'hyperref.sty\', \'[ids]latexml.sty\', \'DLMFmath.sty\' ), \'linelength\' => 90 );
      $wgCapitalLinks = false;
      $wgHooks[\'MathFormulaPostRender\'] = array( \'wfOnMathFormulaRendered\');
      $wgMetaNamespace = \'Project\';
      $wgSitename = \'DRMF\';
      $wgDefaultUserOptions[\'math\'] = \'latexml\';'
    ],
  }

  mediawiki::settings { 'drmf security':
    values => {
      'wgGroupPermissions[\'*\'][\'edit\']' => false,
      'wgGroupPermissions[\'*\'][\'createaccount\']' => false,
    },
  }

  mediawiki::settings { 'wikibase settings':
    values => {
#    TODO: Add import of the default Properties
      'wgWBRepoSettings[\'formatterUrlProperty\']' => 'P24'
    },
  }

  mediawiki::settings { 'drmf Namespaces':
    values   => ['
        // See https://www.mediawiki.org/wiki/Extension_default_namespaces
        define("NS_SOURCE", 130);
        define("NS_SOURCE_TALK", 131);
        define("NS_FORMULA", 132);
        define("NS_FORMULA_TALK", 133);
        define("NS_CD", 134);
        define("NS_CD_TALK", 135);
        define("NS_DEFINITION", 136);
        define("NS_DEFINITION_TALK", 137);

        $wgExtraNamespaces =
            array(NS_SOURCE => "Source",
                  NS_SOURCE_TALK => "Source_talk",
                  NS_FORMULA => "Formula", 
                  NS_FORMULA_TALK => "Formula_talk",
                  NS_CD => "CD",
                  NS_CD_TALK => "CD_talk",
                  NS_DEFINITION => "Definition",
                  NS_DEFINITION_TALK => "Definition_talk",
            );
/**
 * Callback function that is called after a formula was rendered
 * @param MathRenderer $Renderer
 * @param string|null $Result reference to the rendering result
 * @param int $pid
 * @param int $eid
 * @return bool
 */
function wfOnMathFormulaRendered( Parser $parser, MathRenderer $renderer, &$Result = null ) {
    $id = $renderer->getID();
    if ( $id ) {
        $url = Title::newFromText( \'Formula:\' . $id )->getLocalURL();
        $Result = preg_replace ("#</semantics>#", "<annotation encoding=\"OpenMath\" >" . $renderer->getUserInputTex() . "</annotation>\n</semantics>", $Result );
        $Result = \'<a href="\' . $url . \'" id="\' . $id . \'" style="color:inherit;">\' . $Result . \'</a>\';
    }
    return true;
}

        $smwgNamespacesWithSemanticLinks[NS_FORMULA] = true;
        $smwgNamespacesWithSemanticLinks[NS_CD] = true;'],
    priority => 5
  }
#  mediawiki::extension { 'Lockdown':
#    settings => {
#      'wgNamespacePermissionLockdown[NS_SOURCE][\'read\']'=> ['user'],
#      'wgNamespacePermissionLockdown[NS_CD][\'read\']'    => ['user'],
#    }
#  }
  mediawiki::extension { 'FlaggedRevs':
    settings => {
      wgFlaggedRevsStatsAge => false,
      'wgGroupPermissions[\'sysop\'][\'review\']' => true, #allow administrators to review revisions
    },
    wiki => 'devwiki',
  }

  file { '/vagrant/settings.d/DrmfUserWhitelist.txt':
    content => template( '/vagrant/puppet/modules/drmf/templates/DrmfUserWhitelist.txt.erb' ),
  }

  mediawiki::extension{ 'SemanticMediaWiki':
    composer     => true,
    needs_update => true,
    wiki => 'devwiki'
  }


  mediawiki::extension{ 'Nuke': }

  mediawiki::extension{ 'BlockAndNuke':
    entrypoint => 'BlockandNuke.php',
    settings   => {
      wgWhitelist => '/vagrant/settings.d/DrmfUserWhitelist.txt'
    },
    require    =>  File[ '/vagrant/settings.d/DrmfUserWhitelist.txt' ],
  }
  mediawiki::extension{ 'DataTransfer': 
      wiki => 'devwiki'
  }

  apt::ppa { 'radu-hambasan/math-web-search': }
  package { [
    'mws'
  ]:
  }
  file { ['/srv/mathsearch/','/srv/mathsearch/mws-dump']:
    ensure => directory }
  
  exec { 'index formulae':
    command => '/usr/bin/mws-config create -p 9090 -i /srv/mathsearch/mws-dump/ drmf -e xml && /usr/bin/mws-config enable drmf',
    require => [ Package['mws'], File['/srv/mathsearch/mws-dump'] ],
    creates => '/etc/init.d/mwsd_drmf'
  }

  mediawiki::import::text { 'DRMF':
    source => 'puppet:///modules/drmf/drmf.wiki',
  }

  mediawiki::import::text { 'MediaWiki:Mainpage':
    source => 'puppet:///modules/drmf/mainpage.wiki',
  }

  mediawiki::import::text { 'GitHub':
    source => 'puppet:///modules/drmf/github.wiki',
  }
  
  mediawiki::import::dump { 'import templates':
    xml_dump           => '/vagrant/puppet/modules/drmf/files/drmf-templates.xml',
    dump_sentinel_page => 'Template:headSection'
  }
  
  file { "${::mediawiki::apache::docroot}/drmf_mediawiki_logo.png":
    ensure => present,
    source => '/vagrant/puppet/modules/drmf/files/DRMF-LOGO.png'
  }

  mediawiki::settings { 'drmf-vagrant logo':
    values => {
      wgLogo          => '/drmf_mediawiki_logo.png',
    },
    priority => 60,
  }
#TODO: Write startup script for basex
#  exec { 'start basex formulae':
 #   command => '/usr/bin/mvn package  exec:java -Dpath=/srv/mathsearch/mws-dump/',
#    cwd     => '/vagrant/mathosphere/restd',
 #   require => [ Exec['build basex-backend'], Exec['index formulae'] ]
  #}
}
