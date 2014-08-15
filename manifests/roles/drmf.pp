# == Class: role::drmf ==
class role::drmf {
    include role::mathsearch

    mediawiki::settings { 'drmf math':
        priority => 30,
        values => {
        'wgMathDisableTexFilter' => true,
        'wgUseMathJax'           => true, # enabeling MathJax as rendering option
        'wgDefaultUserOptions[\'mathJax\']' => true, #setting MathJax as default rendering option (optional)
        'wgLaTeXMLServer'       => 'http://gw125.iu.xsede.org:8888',
        'wgMathDefaultLaTeXMLSetting[\'preload\'][]' => 'DLMFmath.sty',
        },
    }

    mediawiki::settings { 'drmf remove texvc':
        values => ['$wgMathDefaultLaTeXMLSetting[\'preload\'] = array_diff( $wgMathDefaultLaTeXMLSetting[\'preload\'], [\'texvc\'] )'],
        priority => 20
    }

    mediawiki::settings { 'drmf Namspaces':
        values => ['define("NS_SOURCE", 100);
        define("NS_SOURCE_TALK", 101);
        define("NS_FORMULA", 102);
        define("NS_FORMULA_TALK", 103);

        $wgExtraNamespaces =
            array(100 => "Source",
                  101 => "Source_talk",
                  102 => "FormulaH",
                  103 => "Formula_talk",
            );'],
        priority => 20
    }
    mediawiki::extension { 'Lockdown':
        settings => {
        'wgNamespacePermissionLockdown[NS_SOURCE][\'read\']' => ['user'],
        }
    }
    mediawiki::extension { 'FlaggedRevs':
        settings => {
        wgFlaggedRevsStatsAge => false,
        'wgGroupPermissions[\'sysop\'][\'review\']' => true, #allow administrators to review revisions
        }
    }

}
