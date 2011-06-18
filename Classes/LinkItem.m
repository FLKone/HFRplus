//
//  Favorite.m
//  HFR+
//
//  Created by Lace on 04/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LinkItem.h"
#import "RegexKitLite.h"
#import "HFRplusAppDelegate.h"

@implementation LinkItem

@synthesize postID, lastPageUrl, lastPostUrl, viewed, name, url, flagUrl, typeFlag, rep, dicoHTML, messageDate, imageUrl, imageUI, textViewMsg, messageNode, messageAuteur;
@synthesize urlQuote, urlEdit, addFlagUrl, quoteJS, MPUrl, isDel;

-(NSString *)toHTML:(int)index
{
	NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"templatev2" ofType:@"htm"] encoding:NSUTF8StringEncoding error:NULL];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	if([self isDel]){
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message del"];
	}

	if ([[self name] isEqualToString:@"Modération"]) {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message mode "];
	}

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_PSEUDO%%" withString:[self name]];
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%POSTID%%" withString:[self postID]];	
	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_DATE%%" withString:[[self messageDate] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

	//tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:@"bundle://avatar_male_gray_on_light_48x48.png"];

	if([self imageUrl] != nil)
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:[self imageUI]]; //avatar_male_gray_on_light_48x48.png //imageUrl
	else {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:@"avatar_male_gray_on_light_32x32.png"];
	}

	NSString *myRawContent = [[self dicoHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	//NSString *regExQuoteTitle = @"<a href=\"[^\"]+\" class=\"Topic\">([^<]+)</a>";			
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regExQuoteTitle
	//													  withString:@"$1"];
	
	
	//Custom Internal Images
	NSString *regEx2 = @"<img src=\"http://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx2
														withString:@"<img class=\"smileycustom\" src=\"http://forum-images.hardware.fr/$1\" />"]; //
	
	//Native Internal Images
	NSString *regEx0 = @"<img src=\"http://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx0
														  withString:@"|NATIVE-$1-98787687687697|"];
	
	//Replacing Links by HREF
	//NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\">[^<]+</a>";			
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
	//													  withString:@"$1"];			
	
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"|EXTERNAL-98787687687697|" withString:@"<img src='image.png' />"];
	
	
	//Toyonos Images http://hfr.toyonos.info/generateurs/rofl/?s=shay&v=4&t=5
	//NSString *regExToyo = @"<img src=\"http://hfr.toyonos.info/generateurs/([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" style=\"[^\"]+\">";			
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regExToyo
	//													  withString:@"<img src=\"http://hfr.toyonos.info/generateurs/$1\">"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *display = [defaults stringForKey:@"display_images"];
	
    //NSLog(@"display %@", display);
    
	if ([display isEqualToString:@"no"]) {
        
		//Replacing Links with IMG with custom IMG
		NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
															  withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"121-lanscape.png\" alt=\"$2\" longdesc=\"$1\">"];
		
		//External Images			
		NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
															  withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"121-lanscape.png\" alt=\"$1\" longdesc=\"\">"];	
		
		
	} else if ([display isEqualToString:@"yes"]) {
		NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
															  withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"$2\" alt=\"$2\" longdesc=\"$1\">"];
		
		//External Images			
		NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
															  withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"$1\" alt=\"$1\" longdesc=\"\">"];	
	} else if ([display isEqualToString:@"wifi"]) {
        
        NetworkStatus netStatus = [[[HFRplusAppDelegate sharedAppDelegate] internetReach] currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            case ReachableViaWWAN:
            {
                //NSLog( @"Reachable WWAN");
                //Replacing Links with IMG with custom IMG
                NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
                                                                      withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"121-lanscape.png\" alt=\"$2\" longdesc=\"$1\">"];
                
                //External Images			
                NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                                      withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"121-lanscape.png\" alt=\"$1\" longdesc=\"\">"];	                
                break;
            }
            case ReachableViaWiFi:
            {
               // NSLog( @"Reachable WiFi");
                NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
                                                                      withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"$2\" alt=\"$2\" longdesc=\"$1\">"];
                
                //External Images			
                NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                                      withString:@"<img class=\"hfrplusimg\" title=\"%%ID%%\" src=\"$1\" alt=\"$1\" longdesc=\"\">"];	
                
                break;
            }
        }

        
    }
	
	

	
	
	
	//Replace Internal Images with Bundle://
	NSString *regEx4 = @"\\|NATIVE-([^-]+)-98787687687697\\|";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx4
														  withString:@"<img src='$1' />"];
	
	
	//NSLog(@"--------------\n%@", myRawContent);
	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_CONTENT%%" withString:myRawContent];
	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%ID%%" withString:[NSString stringWithFormat:@"%d", index]];

	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];	
	//NSLog(@"%@", tempHTML);

	return tempHTML;
}

- (void)dealloc {
	//NSLog(@"dealloc linkitem %@", self.name);
	/*
	[name release];
	[url release];	
	[flagUrl release];	
	[typeFlag release];	

	[dicoHTML release];	
	[messageDate release];	
	[imageUrl release];	
	[imageUI release];	

	[textViewMsg release];	
	
	[messageNode release];	
	[messageAuteur release];	
	[urlQuote release];
	[lastPageUrl release];
	[lastPostUrl release];
*/
	self.name = nil;
	self.url = nil;
	self.flagUrl = nil;
	self.typeFlag = nil;
	
	self.dicoHTML = nil;	
	self.messageDate = nil;	
	self.imageUrl = nil;
	self.imageUI = nil;	
	
	self.textViewMsg = nil;	
	
	self.messageNode = nil;
	self.messageAuteur = nil;	
	
	self.urlQuote = nil;
	self.urlEdit = nil;
	
	self.lastPageUrl = nil;
	self.lastPostUrl = nil;
	self.postID = nil;
	
	self.addFlagUrl = nil;
	self.quoteJS = nil;
	self.MPUrl = nil;
	
	[super dealloc];
	
}
@end
