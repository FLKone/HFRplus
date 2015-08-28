//
//  BlackList.h
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import <Foundation/Foundation.h>

@interface BlackList : NSObject
{
    NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;

+ (BlackList *)shared;
- (void)add:(NSString *)word;
- (void)addDictionnary:(NSDictionary *)dico;
- (bool)removeAt:(int)index;
- (bool)removeWord:(NSString*)index;
- (bool)isBL:(NSString*)word;
- (NSArray *)getAll;
@end
