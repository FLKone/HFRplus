//
//  Forum.m
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import "Forum.h"


@implementation Forum

@synthesize aTitle;
@synthesize aURL, aID;
@synthesize subCats;
/*
-(NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.aID, self.aTitle];
}
*/
- (id)init {
	self = [super init];
	if (self) {
        self.aTitle = [NSString string];
        self.aURL = [NSString string];
        self.aID = [NSString string];

        self.subCats = [NSMutableArray array];
        
	}
	return self;
}

-(int)getHFRID {
    
    if ([self.aURL isEqualToString:@"/hfr/Hardware/liste_sujet-1.htm"]) return 1;
    if ([self.aURL isEqualToString:@"/hfr/HardwarePeripheriques/liste_sujet-1.htm"]) return 16;
    if ([self.aURL isEqualToString:@"/hfr/OrdinateursPortables/liste_sujet-1.htm"]) return 15;
    if ([self.aURL isEqualToString:@"/hfr/gsmgpspda/liste_sujet-1.htm"]) return 23;
    if ([self.aURL isEqualToString:@"/hfr/OverclockingCoolingModding/liste_sujet-1.htm"]) return 2;
    if ([self.aURL isEqualToString:@"/hfr/apple/liste_sujet-1.htm"]) return 25;
    if ([self.aURL isEqualToString:@"/hfr/VideoSon/liste_sujet-1.htm"]) return 3;
    if ([self.aURL isEqualToString:@"/hfr/Photonumerique/liste_sujet-1.htm"]) return 14;
    if ([self.aURL isEqualToString:@"/hfr/JeuxVideo/liste_sujet-1.htm"]) return 5;
    if ([self.aURL isEqualToString:@"/hfr/WindowsSoftware/liste_sujet-1.htm"]) return 4;
    if ([self.aURL isEqualToString:@"/hfr/reseauxpersosoho/liste_sujet-1.htm"]) return 22;
    if ([self.aURL isEqualToString:@"/hfr/systemereseauxpro/liste_sujet-1.htm"]) return 21;
    if ([self.aURL isEqualToString:@"/hfr/OSAlternatifs/liste_sujet-1.htm"]) return 11;
    if ([self.aURL isEqualToString:@"/hfr/Programmation/liste_sujet-1.htm"]) return 10;
    if ([self.aURL isEqualToString:@"/hfr/Graphisme/liste_sujet-1.htm"]) return 12;
    if ([self.aURL isEqualToString:@"/hfr/AchatsVentes/liste_sujet-1.htm"]) return 6;
    if ([self.aURL isEqualToString:@"/hfr/EmploiEtudes/liste_sujet-1.htm"]) return 8;
    if ([self.aURL isEqualToString:@"/hfr/Setietprojetsdistribues/liste_sujet-1.htm"]) return 9;
    if ([self.aURL isEqualToString:@"/hfr/Discussions/liste_sujet-1.htm"]) return 13;
    if ([self.aURL isEqualToString:@"/hfr/Blabla-Divers-back-to-life/liste_sujet-1.htm"]) return 24;
    
    return 0;
}

-(NSString *)getImage {
    
    if ([self.aURL isEqualToString:@"/hfr/Hardware/liste_sujet-1.htm"]) return @"ProcessorFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/HardwarePeripheriques/liste_sujet-1.htm"]) return @"KeyboardFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/OrdinateursPortables/liste_sujet-1.htm"]) return @"LaptopFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/gsmgpspda/liste_sujet-1.htm"]) return @"SmartphoneTabletFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/OverclockingCoolingModding/liste_sujet-1.htm"]) return @"SupportFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/apple/liste_sujet-1.htm"]) return @"cat-apple";
    if ([self.aURL isEqualToString:@"/hfr/VideoSon/liste_sujet-1.htm"]) return @"VideoCallFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/Photonumerique/liste_sujet-1.htm"]) return @"CameraFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/JeuxVideo/liste_sujet-1.htm"]) return @"ControllerFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/WindowsSoftware/liste_sujet-1.htm"]) return @"WindowsClientFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/reseauxpersosoho/liste_sujet-1.htm"]) return @"Wi-FiLogoFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/systemereseauxpro/liste_sujet-1.htm"]) return @"VOIPGatewayFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/OSAlternatifs/liste_sujet-1.htm"]) return @"Debian-40";
    if ([self.aURL isEqualToString:@"/hfr/Programmation/liste_sujet-1.htm"]) return @"SourceCodeFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/Graphisme/liste_sujet-1.htm"]) return @"DesignFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/AchatsVentes/liste_sujet-1.htm"]) return @"PriceTagUSDFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/EmploiEtudes/liste_sujet-1.htm"]) return @"GraduationCapFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/Setietprojetsdistribues/liste_sujet-1.htm"]) return @"BroadcastingFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/Discussions/liste_sujet-1.htm"]) return @"ChatFilled-40";
    if ([self.aURL isEqualToString:@"/hfr/Blabla-Divers-back-to-life/liste_sujet-1.htm"]) return @"ChatFilled-40";
    
    return @"ShieldFilled-40";
}


-(NSString *)URLforType:(FLAGTYPE)type {
    
    NSString *tmpURL = kCatTemplateURL;
    tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$1" withString:[NSString stringWithFormat:@"%d", self.getHFRID]];
    tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$2" withString:@""];
    
    switch (type) {
        case kFav:
            tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$3" withString:@"3"];
            break;
        case kFlag:
            tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$3" withString:@"1"];
            break;
        case kRed:
            tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$3" withString:@"2"];
            break;
        case kALL:
        default:
            tmpURL = [tmpURL stringByReplacingOccurrencesOfString:@"$3" withString:@"0"];
            break;
    }
    return tmpURL;
}

-(void)dealloc {
	self.aTitle	= nil;
	self.aURL	= nil;
	self.subCats = nil;
    self.aID	= nil;
    
	[super dealloc];
}

@end