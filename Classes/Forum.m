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

-(NSInteger)getHFRID {
    
    if ([self.aURL isEqualToString:@"/hfr/Hardware/liste_sujet-1.htm"]) return 1;
    if ([self.aURL isEqualToString:@"/hfr/HardwarePeripheriques/liste_sujet-1.htm"]) return 16;
    if ([self.aURL isEqualToString:@"/hfr/OrdinateursPortables/liste_sujet-1.htm"]) return 15;
    if ([self.aURL isEqualToString:@"/hfr/gsmgpspda/liste_sujet-1.htm"]) return 23;
    if ([self.aURL isEqualToString:@"/hfr/OverclockingCoolingModding/liste_sujet-1.htm"]) return 2;
    if ([self.aURL isEqualToString:@"/hfr/electroniquedomotiquediy/liste_sujet-1.htm"]) return 30;
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
    
    if ([self.aURL isEqualToString:@"/hfr/Hardware/liste_sujet-1.htm"]) return [self getImageFromID:1];
    if ([self.aURL isEqualToString:@"/hfr/HardwarePeripheriques/liste_sujet-1.htm"]) return [self getImageFromID:16];
    if ([self.aURL isEqualToString:@"/hfr/OrdinateursPortables/liste_sujet-1.htm"]) return [self getImageFromID:15];
    if ([self.aURL isEqualToString:@"/hfr/gsmgpspda/liste_sujet-1.htm"]) return [self getImageFromID:23];
    if ([self.aURL isEqualToString:@"/hfr/OverclockingCoolingModding/liste_sujet-1.htm"]) return [self getImageFromID:2];
    if ([self.aURL isEqualToString:@"/hfr/electroniquedomotiquediy/liste_sujet-1.htm"]) return [self getImageFromID:30];
    if ([self.aURL isEqualToString:@"/hfr/apple/liste_sujet-1.htm"]) return [self getImageFromID:25];
    if ([self.aURL isEqualToString:@"/hfr/VideoSon/liste_sujet-1.htm"]) return [self getImageFromID:3];
    if ([self.aURL isEqualToString:@"/hfr/Photonumerique/liste_sujet-1.htm"]) return [self getImageFromID:14];
    if ([self.aURL isEqualToString:@"/hfr/JeuxVideo/liste_sujet-1.htm"]) return [self getImageFromID:5];
    if ([self.aURL isEqualToString:@"/hfr/WindowsSoftware/liste_sujet-1.htm"]) return [self getImageFromID:4];
    if ([self.aURL isEqualToString:@"/hfr/reseauxpersosoho/liste_sujet-1.htm"]) return [self getImageFromID:22];
    if ([self.aURL isEqualToString:@"/hfr/systemereseauxpro/liste_sujet-1.htm"]) return [self getImageFromID:21];
    if ([self.aURL isEqualToString:@"/hfr/OSAlternatifs/liste_sujet-1.htm"]) return [self getImageFromID:11];
    if ([self.aURL isEqualToString:@"/hfr/Programmation/liste_sujet-1.htm"]) return [self getImageFromID:10];
    if ([self.aURL isEqualToString:@"/hfr/Graphisme/liste_sujet-1.htm"]) return [self getImageFromID:12];
    if ([self.aURL isEqualToString:@"/hfr/AchatsVentes/liste_sujet-1.htm"]) return [self getImageFromID:6];
    if ([self.aURL isEqualToString:@"/hfr/EmploiEtudes/liste_sujet-1.htm"]) return [self getImageFromID:8];
    if ([self.aURL isEqualToString:@"/hfr/Setietprojetsdistribues/liste_sujet-1.htm"]) return [self getImageFromID:9];
    if ([self.aURL isEqualToString:@"/hfr/Discussions/liste_sujet-1.htm"]) return [self getImageFromID:13];
    if ([self.aURL isEqualToString:@"/hfr/Blabla-Divers-back-to-life/liste_sujet-1.htm"]) return [self getImageFromID:24];
    
    return [self getImageFromID:-1];
}


-(NSString *)getImageFromID {
    
    return [self getImageFromID:[self.aID integerValue]];
    
}

-(NSString *)getImageFromID:(NSInteger)idCat {
    
    switch (idCat) {
        case 1: return @"ProcessorFilled-40"; break;
        case 16: return @"KeyboardFilled-40"; break;
        case 15: return @"LaptopFilled-40"; break;
        case 23: return @"SmartphoneTabletFilled-40"; break;
        case 2: return @"SupportFilled-40"; break;
        case 30: return @"CircuitFilled-40"; break;
        case 25: return @"cat-apple"; break;
        case 3: return @"VideoCallFilled-40"; break;
        case 14: return @"CameraFilled-40"; break;
        case 5: return @"ControllerFilled-40"; break;
        case 4: return @"WindowsClientFilled-40"; break;
        case 22: return @"Wi-FiLogoFilled-40"; break;
        case 21: return @"VOIPGatewayFilled-40"; break;
        case 11: return @"Debian-40"; break;
        case 10: return @"SourceCodeFilled-40"; break;
        case 12: return @"DesignFilled-40"; break;
        case 6: return @"PriceTagUSDFilled-40"; break;
        case 8: return @"GraduationCapFilled-40"; break;
        case 9: return @"BroadcastingFilled-40"; break;
        case 13: return @"ChatFilled-40"; break;
        case 24: return @"ChatFilled-40"; break;
        default: return @"ShieldFilled-40";
            break;
    }
    
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"encodeWithCoder %@", self);
    
    [encoder encodeObject:aTitle forKey:@"aTitle"];
    [encoder encodeObject:aURL forKey:@"aURL"];
    [encoder encodeObject:aID forKey:@"aID"];
    
    [encoder encodeObject:subCats forKey:@"subCats"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        
        aTitle = [decoder decodeObjectForKey:@"aTitle"];
        aURL = [decoder decodeObjectForKey:@"aURL"];
        aID = [decoder decodeObjectForKey:@"aID"];
        
        subCats = [decoder decodeObjectForKey:@"subCats"];
        
        //NSLog(@"initWithCoder %@", self);
    }
    return self;
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


@end