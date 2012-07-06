//
//  NSDictionary+Merging.h
//  HFRplus
//
//  Created by FLK on 06/07/12.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Merging)

- (NSMutableDictionary *)dictionaryByMergingAndAddingDictionary:(NSDictionary *)d;

@end
