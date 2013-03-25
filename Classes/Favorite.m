//
//  Favorite.m
//  HFRplus
//
//  Created by FLK on 21/07/12.
//

#import "Favorite.h"
#import "Forum.h"
#import "Topic.h"
#import "HTMLNode.h"
#import "RangeOfCharacters.h"
#import "RegexKitLite.h"

@implementation Favorite

@synthesize forum, topics;

- (id)init {
	self = [super init];
	if (self) {
        Forum *aForum = [[Forum alloc] init];
		[self setForum:aForum];
        [aForum release];
        
		self.topics = [NSMutableArray array];        
	}
	return self;
}

-(void)parseNode:(HTMLNode *)node {
    
    HTMLNode *forumNode = [node findChildWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO];
    
    NSString *forumURL = [NSString stringWithString:[forumNode getAttributeNamed:@"href"]];

    NSString *forumID = [NSString stringWithString:[[forumNode getAttributeNamed:@"href"] wordAfterString:@"cat="]];

    NSString *forumTitle = [NSString stringWithString:[forumNode contents]];
    
    Forum *aForum = [[Forum alloc] init];
    [aForum setAURL:forumURL];
    [aForum setAID:forumID];
    [aForum setATitle:forumTitle];

    self.forum = aForum;
    [aForum release];    
}

-(id)addTopicWithNode:(HTMLNode *)node;
{

	NSDate *nowTopic = [[NSDate alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd-MM-yyyy"];
	NSString *theDate = [dateFormat stringFromDate:nowTopic];
    [nowTopic release];
    [dateFormat release];
    
    HTMLNode *topicNode = node;

    
    Topic *aTopic = [[Topic alloc] init];
    
    //POSTID/CATID
    HTMLNode * catIDNode = [topicNode findChildWithAttribute:@"name" matchingName:@"valuecat" allowPartial:YES];
    [aTopic setCatID:[[catIDNode getAttributeNamed:@"value"] intValue]];
    
    HTMLNode * postIDNode = [topicNode findChildWithAttribute:@"name" matchingName:@"topic" allowPartial:YES];
    [aTopic setPostID:[[postIDNode getAttributeNamed:@"value"] intValue]];
    
    //Title
    HTMLNode * topicTitleNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase3" allowPartial:NO];
    NSString *aTopicAffix = [[NSString alloc] init];
    NSString *aTopicSuffix = [[NSString alloc] init];
    
    if ([[topicNode className] rangeOfString:@"ligne_sticky"].location != NSNotFound) {
        aTopicAffix = [aTopicAffix stringByAppendingString:@""];//➫ ➥▶✚
    }
    if ([topicTitleNode findChildWithAttribute:@"alt" matchingName:@"closed" allowPartial:NO]) {
        aTopicAffix = [aTopicAffix stringByAppendingString:@""];
    }
    
    if (aTopicAffix.length > 0) {
        aTopicAffix = [aTopicAffix stringByAppendingString:@" "];
    }		
    
    NSString *aTopicTitle = [[NSString alloc] initWithFormat:@"%@%@%@", aTopicAffix, [[topicTitleNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], aTopicSuffix];
    
    [aTopic setATitle:aTopicTitle];
    [aTopicTitle release];
    
    NSString *aTopicURL = [[NSString alloc] initWithString:[[topicTitleNode findChildTag:@"a"] getAttributeNamed:@"href"]];
    [aTopic setAURLOfFirstPage:aTopicURL];
    [aTopicURL release];

    
    //Answer Count
    HTMLNode * numRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase7" allowPartial:NO];
    [aTopic setARepCount:[[numRepNode contents] intValue]];
    
    //Author & Url of Last Post & Date
    HTMLNode * lastRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase9" allowPartial:YES];		
    HTMLNode * linkLastRepNode = [lastRepNode firstChild];
    NSString *aAuthorOfLastPost = [[NSString alloc] initWithString:[[linkLastRepNode findChildTag:@"b"] contents]];
    [aTopic setAAuthorOfLastPost:aAuthorOfLastPost];
    [aAuthorOfLastPost release];
    
    NSString *aURLOfLastPost = [[NSString alloc] initWithString:[linkLastRepNode getAttributeNamed:@"href"]];
    [aTopic setAURLOfLastPost:aURLOfLastPost];
    [aURLOfLastPost release];
    
    NSString *maDate = [linkLastRepNode contents];
    if ([theDate isEqual:[maDate substringToIndex:10]]) {
        [aTopic setADateOfLastPost:[maDate substringFromIndex:13]];
    }
    else {
        [aTopic setADateOfLastPost:[NSString stringWithFormat:@"%@/%@/%@", [maDate substringWithRange:NSMakeRange(0, 2)]
                                    , [maDate substringWithRange:NSMakeRange(3, 2)]
                                    , [maDate substringWithRange:NSMakeRange(8, 2)]]];
    }
    
    //URL of Last Page
    HTMLNode * topicLastPageNode = [[topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase4" allowPartial:NO] findChildTag:@"a"];
    if (topicLastPageNode) {
        NSString *aURLOfLastPage = [[NSString alloc] initWithString:[topicLastPageNode getAttributeNamed:@"href"]];
        [aTopic setAURLOfLastPage:aURLOfLastPage];
        [aURLOfLastPage release];
        [aTopic setMaxTopicPage:[[topicLastPageNode contents] intValue]];            
    }
    else {
        [aTopic setAURLOfLastPage:[aTopic aURL]];
        [aTopic setMaxTopicPage:1];            
    }
    
    //URL
    HTMLNode * topicFlagNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase5" allowPartial:NO];
    HTMLNode * topicFlagLinkNode = [topicFlagNode findChildTag:@"a"];
    
    if (!topicFlagLinkNode) {
        // Si pas de dernier topic = url = last page
        NSString *aTopicURL = [[NSString alloc] initWithString:[linkLastRepNode getAttributeNamed:@"href"]];
        [aTopic setAURL:aTopicURL];
        [aTopicURL release];
        
        [aTopic setIsViewed:YES];
    }
    else
    {
        NSString *aTopicURL = [[NSString alloc] initWithString:[topicFlagLinkNode getAttributeNamed:@"href"]];
        [aTopic setAURL:aTopicURL];
        [aTopicURL release];
    }

    
    //Current page if flag
    int pageNumber;
    NSString *regexString  = @".*page=([^&]+).*";
    NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
    NSRange   searchRange = NSMakeRange(0, aTopic.aURL.length);
    NSError  *error2        = NULL;
    
    matchedRange = [aTopic.aURL rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
    
    if (matchedRange.location == NSNotFound) {
        NSRange rangeNumPage =  [aTopic.aURL rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
        pageNumber = [[aTopic.aURL substringWithRange:rangeNumPage] intValue];
    }
    else {
        pageNumber = [[aTopic.aURL substringWithRange:matchedRange] intValue];
        
    }
    
    [aTopic setCurTopicPage:pageNumber];            
    //NSLog(@"pageNumber %d/%d", aTopic.curTopicPage, aTopic.maxTopicPage);
    
    //--- Current page if flag
    
    [self.topics addObject:aTopic];

    //NSLog(@"aTopic %@", aTopic);
    //NSLog(@"aTopic %@", self);
    
    [aTopic release];
    return nil;
}

-(NSString *)description {

    return [NSString stringWithFormat:@"Forum : %@\nTopic : %@", self.forum, self.topics];
}

-(void)dealloc {
    
	self.forum	= nil;
	[self.topics removeAllObjects];
    self.topics = nil;
	
	[super dealloc];
}


@end
