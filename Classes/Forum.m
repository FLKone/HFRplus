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

-(void)dealloc {
	self.aTitle	= nil;
	self.aURL	= nil;
	self.aID	= nil;
	self.subCats = nil;
	
	[super dealloc];
}

@end