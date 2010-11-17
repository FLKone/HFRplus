//
//  Forum.m
//  HFRplus
//
//  Created by Lace on 19/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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