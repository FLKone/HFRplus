<img src="http://a252.phobos.apple.com/us/r1000/119/Purple/v4/d1/89/07/d18907cd-3fd2-a828-cbcd-1c9ffeb4e6d0/mza_7454098853510851857.170x170-75.png" alt="HFR+" title="HFR+" style="display:block; margin: 10px auto 30px auto;" class="center">

HFR+ v1 - Compatible iOS 5 - 8
=========================
Application iOS (iPhone, iPod Touch et iPad) pour le forum hardware.fr


Roadmap
-------------------------

<table>
  <tr>
    <th>Version</th><th>Type</th><th>Sortie</th>
  </tr>
<tr>
<td>1.9</td><td>Compatibilité iOS9 + :o</td><td>late-2015</td>
  </tr>
<tr>
    <td><a href="https://github.com/FLKone/HFRplus/tree/devel">2.0</a></td><td>Nouvelle version. <a href="https://github.com/FLKone/HFRplus/tree/devel">cf ~devel</a></td><td>TBD</td>
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
* [UIMenuItem+CXAImageSupport](https://github.com/cxa/UIMenuItem-CXAImageSupport)
* Icônes/Picto [icons8](https://icons8.com/)