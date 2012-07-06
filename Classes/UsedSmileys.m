//
//  UsedSmileys.m
//  HFRplus
//
//  Created by FLK on 06/07/12.
//

#import "UsedSmileys.h"

@implementation UsedSmileys

@synthesize usedSmileys;

-(void)notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"docsModified" object:self];
}

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName 
                   error:(NSError **)outError
{
    
    //NSLog(@"loadFromContents");
    
    NSData *data = [[NSMutableData alloc] initWithBytes:[contents bytes] length:[contents length] ];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.usedSmileys = [unarchiver decodeObjectForKey: @"usedSmileys"];
    
    //NSLog(@"usedSmileys %@", usedSmileys);
    
    [unarchiver finishDecoding];
    [unarchiver release];
    [data release];

    [self notify];
    
    return YES;    
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError 
{
    //NSLog(@"contentsForType");
    
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeObject:self.usedSmileys forKey:@"usedSmileys"];
    [archiver finishEncoding];
    
    return data;
    
}

@end