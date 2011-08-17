//
//  Topic.m
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import "Topic.h"


@implementation Topic

@synthesize aTitle;
@synthesize aURL;

@synthesize aRepCount;
@synthesize isViewed;

@synthesize aURLOfFlag;
@synthesize aTypeOfFlag;

@synthesize aURLOfLastPost;
@synthesize aURLOfLastPage;

@synthesize aDateOfLastPost;
@synthesize aAuthorOfLastPost;

@synthesize aAuthorOrInter;

@synthesize maxTopicPage, curTopicPage;

@synthesize postID, catID;

-(void)dealloc {
	self.aTitle	= nil;
	self.aURL	= nil;

	self.aURLOfFlag		= nil;
	self.aTypeOfFlag	= nil;
	
	self.aURLOfLastPost	= nil;
	self.aURLOfLastPage	= nil;
	
	self.aDateOfLastPost	= nil;
	self.aAuthorOfLastPost	= nil;	
	self.aAuthorOrInter	= nil;	
	
	[super dealloc];
}

@end

