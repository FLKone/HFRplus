//
//  Topic.m
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import "Topic.h"
#import "RangeOfCharacters.h"


@implementation Topic

@synthesize _aTitle;
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
        _aTitle = [NSString stringWithFormat:@""];
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

- (void)setATitle:(NSString *)n {
    [_aTitle release];
    _aTitle = [[n filterTU] retain];


}
//Getter method
- (NSString*) aTitle {
    //NSLog(@"Returning name: %@", _aTitle);
    return _aTitle;
}

-(void)dealloc {
	_aTitle	= nil;
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

