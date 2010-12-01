//
//  Forum.m
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import "Forum.h"


@implementation Forum

@synthesize aTitle;
@synthesize aURL;
@synthesize aID;
@synthesize subCats;

-(void)dealloc {
	self.aTitle	= nil;
	self.aURL	= nil;
	self.aID	= nil;
	self.subCats = nil;
	
	[super dealloc];
}

@end