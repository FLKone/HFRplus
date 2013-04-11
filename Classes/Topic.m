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

@synthesize maxTopicPage, curTopicPage, aURLOfFirstPage;

@synthesize postID, catID;


- (id)init {
	self = [super init];
	if (self) {
        self.aTitle = [NSString string];
        self.aURL = [NSString string];

        self.aURLOfFirstPage = [NSString string];
        
        self.aURLOfFlag = [NSString string];
        self.aTypeOfFlag = [NSString string];
        
        self.aURLOfLastPost = [NSString string];
        self.aURLOfLastPage = [NSString string];
        
        self.aDateOfLastPost = [NSString string];
        self.aAuthorOfLastPost = [NSString string];
        
        self.aAuthorOrInter = [NSString string];

	}
	return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%d %@", self.postID, self.aTitle];
}

-(void)dealloc {
	self.aTitle	= nil;
	self.aURL	= nil;

    self.aURLOfFirstPage		= nil;

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

