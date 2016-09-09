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
    NSDate * now = [NSDate date];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"LLL d, yyyy - HH:mm:ss zzz";
    NSDate *testedDate = [fmt dateFromString:@"September 13, 2016 - 00:00:01 UTC"];
    
    if ([testedDate timeIntervalSinceDate:now] > 0) {
        NSLog(@"Proxy");
        return @"https://hfr.sideload.it";
        
    }
    NSLog(@"Noxy");
    return @"http://forum.hardware.fr";

}

+ (NSString *)RealForumURL
{
    return @"http://forum.hardware.fr";
}


@end
