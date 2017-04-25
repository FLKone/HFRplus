//
//  parseMessagesOperation.h
//  HFRplus
//
//  Created by FLK on 06/08/10.
//

@class LinkItem;
@class HTMLParser;
@protocol ParseMessagesOperationDelegate;


@interface ParseMessagesOperation : NSOperation
{
@private
    id <ParseMessagesOperationDelegate> __weak delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray		*workingArray;
    LinkItem		*workingEntry;
    BOOL            reverse;
	int				index;

    NSOperationQueue		*queue;
}

-(id)initWithData:(NSData *)data index:(int)theIndex reverse:(BOOL)isReverse delegate:(id <ParseMessagesOperationDelegate>)theDelegate;
-(void)parseData:(HTMLParser*)myParser;

@end

@protocol ParseMessagesOperationDelegate
- (void)didFinishParsing:(NSArray *)appList;
- (void)didStartParsing:(HTMLParser *)myParser;
@end