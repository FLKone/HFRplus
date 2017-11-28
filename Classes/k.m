//
//  k.m
//  HFRplus
//
//  Created by FLK on 09/09/2016.
//
//

#import "k.h"

@implementation k

+ (NSString *)ForumURL
{
    return [self RealForumURL];
    /*
     
     Plus nécessaire, bug IPv6 corrigé
     ======
     
    NSDate * now = [NSDate date];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"dd-MM-yyyy HH:mm:ss zzz";
    NSDate *testedDate = [fmt dateFromString:@"13-09-2016 00:00:01 UTC"];
    
    NSLog(@"tested %@ == now %@ || int: %f", testedDate, now, [testedDate timeIntervalSinceDate:now]);
    
    if (testedDate && [testedDate timeIntervalSinceDate:now] > 0) {
        NSLog(@"Proxy");
        return @"https://hfr";
        
    }
    NSLog(@"Noxy");
    return @"http://forum.hardware.fr";
    */
}

+ (NSString *)RealForumURL
{
    return @"https://forum.hardware.fr";
}


@end
