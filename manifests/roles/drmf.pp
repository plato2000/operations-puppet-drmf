# == Class: role::drmf ==
class role::drmf {
  include role::mathsearch

  mediawiki::settings { 'drmf math':
    priority => 30,
    values   => {
      'wgMathDisableTexFilter' => true,
      'wgUseMathJax'           => true, # enabeling MathJax as rendering option
      'wgDefaultUserOptions[\'mathJax\']' => true, #setting MathJax as default rendering option (optional)
      'wgLaTeXMLServer'       => 'http://gw125.iu.xsede.org:8888',
      'wgMathDefaultLaTeXMLSetting[\'preload\'][]' => 'DLMFmath.sty',
      'wgCapitalLinks' => false,
      'wgHooks[\'MathFormulaPostRender\']' => [ 'wfOnMathFormulaRendered' ],
      'wgMetaNamespace' => 'Project',
      'wgSitename' => 'DRMF'
    },
  }

  mediawiki::settings { 'drmf security':
    values => {
      'wgGroupPermissions[\'*\'][\'edit\']' => false,
      'wgGroupPermissions[\'*\'][\'createaccount\']' => false,
    },
  }
  mediawiki::settings { 'drmf remove texvc':
    values   => ['$wgMathDefaultLaTeXMLSetting[\'preload\'] = array_diff( $wgMathDefaultLaTeXMLSetting[\'preload\'], [\'texvc\'] )'],
    priority => 20
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
function wfOnMathFormulaRendered( MathRenderer $Renderer, &$Result = null, $pid = 0, $eid = 0 ) {
    $id = $Renderer->getID();
    if ( $id ) {
        $url = Title::newFromText( \'Formula:\' . $id )->getLocalURL();
        $Result = preg_replace ("#</semantics>#", "<annotation encoding=\"OpenMath\" >" . $Renderer->getUserInputTex() . "</annotation>\n</semantics>", $Result );
        $Result = \'<a href="\' . $url . \'" id="\' . $id . \'" style="color:inherit;">\' . $Result . \'</a>\';
    }
    return true;
}

        $smwgNamespacesWithSemanticLinks[NS_FORMULA] = true;
        $smwgNamespacesWithSemanticLinks[NS_CD] = true;'],
    priority => 5
  }
  mediawiki::extension { 'Lockdown':
    settings => {
      'wgNamespacePermissionLockdown[NS_SOURCE][\'read\']'=> ['user'],
      'wgNamespacePermissionLockdown[NS_CD][\'read\']'    => ['user'],
    }
  }
  mediawiki::extension { 'FlaggedRevs':
    settings => {
      wgFlaggedRevsStatsAge => false,
      'wgGroupPermissions[\'sysop\'][\'review\']' => true, #allow administrators to review revisions
    }
  }

  file { '/srv/vagrant/settings.d/DrmfUserWhitelist.txt':
    content => template( '/vagrant/puppet/modules/drmf/templates/DrmfUserWhitelist.txt.erb' ),
  }

  mediawiki::extension{ 'SemanticMediaWiki':
    composer     => true,
    needs_update => true,
  }


  mediawiki::extension{ 'Nuke': }

  mediawiki::extension{ 'BlockAndNuke':
    entrypoint => 'BlockandNuke.php',
    settings   => {
      wgWhitelist => '/srv/vagrant/settings.d/DrmfUserWhitelist.txt'
    },
    require    =>  File[ '/srv/vagrant/settings.d/DrmfUserWhitelist.txt' ],
  }
  mediawiki::extension{ 'ParserFunctions': }
  mediawiki::extension{ 'DataTransfer': }
#  mediawiki::extension { 'SemanticResultFormats': } (Seems to be broken at the moment)
#mediawiki::extension{ 'DynamicPageList': }
#mediawiki::extension{ 'NukeDPL':
#  require      => Mediawiki::Extension['DynamicPageList'],
#}

## BASEX Backend
  package { [
    'openjdk-7-jdk',
    'maven',
  ]:
  }
  git::clone { 'basex-backend':
    remote    => 'https://github.com/TU-Berlin/mathosphere',
    directory => '/vagrant/mathosphere',
  }
  exec { 'build basex-backend':
    command => '/usr/bin/mvn install -Dgpg.skip=true',
    cwd     => '/vagrant/mathosphere',
    require => Git::Clone['basex-backend'],
    creates => '/vagrant/mathosphere/target'
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
#TODO: Write startup script for basex
#  exec { 'start basex formulae':
 #   command => '/usr/bin/mvn package  exec:java -Dpath=/srv/mathsearch/mws-dump/',
#    cwd     => '/vagrant/mathosphere/restd',
 #   require => [ Exec['build basex-backend'], Exec['index formulae'] ]
  #}
}
