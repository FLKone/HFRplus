<img src="http://a252.phobos.apple.com/us/r1000/119/Purple/v4/d1/89/07/d18907cd-3fd2-a828-cbcd-1c9ffeb4e6d0/mza_7454098853510851857.170x170-75.png" alt="HFR+" title="HFR+" style="display:block; margin: 10px auto 30px auto;" class="center">

HFR+
=========================
Application iOS (iPhone, iPod Touch et iPad) pour le forum hardware.fr


Roadmap
-------------------------

<table>
  <tr>
    <th>Version</th><th>Type</th><th>Sortie</th>
  </tr>
  <tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=4&page=1&sort=created&state=open">1.5.5</a></td><td>Fonctionnalités</td><td>Été 2012</td>
  </tr>
  <tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=1&page=1&sort=created&state=open">1.5.6</a></td><td>UI</td><td>Été 2012</td>
  </tr>
 <tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=3&page=1&sort=created&state=open">1.6</a></td><td>Compatibilité</td><td>Automne 2012</td>
  </tr>
<tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=7&page=1&sort=created&state=open">1.6.1</a></td><td>Fonctionnalités</td><td>Fin 2012</td>
  </tr>
<tr>
    <td><a href="https://github.com/FLKone/HFRplus/issues?milestone=9&page=1&sort=created&state=open">1.6.2</a></td><td>Fonctionnalités avancées</td><td>tbd</td>
  </tr>
</table>


Utilisation
-------------------------

Pour pouvoir compiler la branche Update, il est nécessaire de créer le fichier suivant :

``` objective-c
//
//  Config.h
//

#define kTestFlightAPI                  @"TestFlight API Key"
#define kGoogleAnalyticsAPI             @"Google Analytics API Key"
```