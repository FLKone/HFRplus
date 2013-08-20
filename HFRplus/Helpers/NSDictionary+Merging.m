//
//  NSDictionary+Merging.m
//  HFRplus
//
//  Created by FLK on 06/07/12.
//

#import "NSDictionary+Merging.h"

@implementation NSDictionary (Merging)

- (NSMutableDictionary *)dictionaryByMergingAndAddingDictionary:(NSDictionary*)d {

    NSMutableDictionary* theResult = [[self mutableCopy] autorelease];
    
    NSEnumerator* e = [d keyEnumerator];
    
    id theKey = nil;
    while((theKey = [e nextObject]) != nil)
    {
        NSNumber *val;
        
        if ((val = [theResult valueForKey:theKey])) {

            
            [theResult setObject:[NSNumber numberWithInt:MAX([val intValue], [[d valueForKey:theKey] intValue])] forKey:theKey];
            
            if ([val intValue] != [[d valueForKey:theKey] intValue]) {
                NSLog(@"Existe sur l'ancien %@ => %@", theKey, val);
                NSLog(@"Version sur le nouveau %@ => %@", theKey, [d valueForKey:theKey]);
            }
        }
        else {
            id theObject = [d objectForKey:theKey];
            
            NSLog(@"New, on ajoute %@ %@", theKey, theObject);
            
            [theResult setObject:theObject forKey:theKey];
        }

    }
    
    //NSLog(@"NEW DIC %@", theResult);
    
    return theResult;
    
    
    /*
    NSMutableDictionary *mutDict = [[self mutableCopy] autorelease];
    [mutDict addEntriesFromDictionary:d];
    
    return mutDict;
    */
}

@end
