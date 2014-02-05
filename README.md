<img src="http://a252.phobos.apple.com/us/r1000/119/Purple/v4/d1/89/07/d18907cd-3fd2-a828-cbcd-1c9ffeb4e6d0/mza_7454098853510851857.170x170-75.png" alt="HFR+" title="HFR+" style="display:block; margin: 10px auto 30px auto;" class="center">

HFR+
=========================
Application iOS (iPhone, iPod Touch et iPad) pour le forum hardware.fr

<a href="https://itunes.apple.com/app/hfr/id384464712?mt=8" target="_blank"><img src="http://apps.flkone.com/hfrplus/appstore.svg" alt="AppStore" title="AppStore"></a>


Roadmap
-------------------------

<table>
  <tr>
    <th>Version</th><th>Type</th><th>Sortie</th>
  </tr>
<tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=16&page=1&sort=created&state=open">1.7.2</a></td><td>Fonctionnalités</td><td>early-2014</td>
  </tr>
<tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=17&page=1&sort=created&state=open">x.0</a></td><td>Fonctionnalités avancées</td><td>TBD</td>
  </tr>   
</table>


Utilisation
-------------------------

Un fichier config.h est nécessaire (dans le répertoire HFRplus) :

``` objective-c
//
//  config.h
//  HFRplus
//

#ifndef HFRplus_config_h
#define HFRplus_config_h

static NSString *const kTestFlightAPI = @"TestFlight API Key";
static NSString *const kTestFlightAPIRE = @"TestFlight API Key (used for REDFACE Edition)";
static NSString *const kGoogleCSEAPI = @"Google Custom Search Engine API Key";

#endif
```


Crédits
-------------------------

* [ASIHTTPRequest](https://github.com/pokeb/asi-http-request)
* [Objective-C-HMTL-Parser](https://github.com/zootreeves/Objective-C-HMTL-Parser)
* [InAppSettingKit](https://github.com/futuretap/InAppSettingsKit)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
* [MKStoreKit](https://github.com/MugunthKumar/MKStoreKit)
* [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser)
* [SDWebImage](https://github.com/rs/SDWebImage)
* [RegexKitLite](http://regexkit.sourceforge.net/RegexKitLite/)



Soutenir le développement
-------------------------

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4EBPMFBQ8M6HN" target="_blank"><img src="https://www.paypalobjects.com/fr_FR/FR/i/btn/btn_donate_LG.gif" alt="PayPal - la solution de paiement en ligne la plus simple et la plus sécurisée !"></a>
<span style="color:#bebebe; font-size:11px;">(commission Paypal: 3,4% + 0,25€)</span>