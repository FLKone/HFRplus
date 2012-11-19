//
//  Favorite.h
//  HFRplus
//
//  Created by FLK on 21/07/12.
//

#import <Foundation/Foundation.h>
@class Forum;
@class HTMLNode;

@interface Favorite : NSObject
{
    Forum *forum;
    NSMutableArray *topics;
}

@property (nonatomic, retain) Forum *forum;
@property (nonatomic, retain) NSMutableArray *topics;

-(void)parseNode:(HTMLNode *)node;
-(id)addTopicWithNode:(HTMLNode *)node;

@end
