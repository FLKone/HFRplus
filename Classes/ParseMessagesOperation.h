//
//  parseMessagesOperation.h
//  HFR+
//
//  Created by Lace on 06/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class LinkItem;
@class HTMLParser;

@protocol ParseMessagesOperationDelegate;

@interface ParseMessagesOperation : NSOperation
{
@private
    id <ParseMessagesOperationDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray		*workingArray;
    LinkItem		*workingEntry;
    BOOL            reverse;
	int				index;
}

-(id)initWithData:(NSData *)data index:(int)theIndex reverse:(BOOL)isReverse delegate:(id <ParseMessagesOperationDelegate>)theDelegate;
-(void)parseData:(HTMLParser*)myParser;

@end

@protocol ParseMessagesOperationDelegate
- (void)didFinishParsing:(NSArray *)appList;
- (void)didStartParsing:(HTMLParser *)myParser;
@end