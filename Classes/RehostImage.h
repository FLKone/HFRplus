//
//  RehostImage.h
//  HFRplus
//
//  Created by Shasta on 15/12/2013.
//
//

#import <Foundation/Foundation.h>

@interface RehostImage : NSObject <NSCoding> {
    int version;
    
    NSString *link_full;
    NSString *link_miniature;
    NSString *link_preview;
    NSString *nolink_full;
    NSString *nolink_miniature;
    NSString *nolink_preview;
    NSDate *timeStamp;
    BOOL deleted;
}

@property (nonatomic, retain) NSString *link_full;
@property (nonatomic, retain) NSString *link_miniature;
@property (nonatomic, retain) NSString *link_preview;

@property (nonatomic, retain) NSString *nolink_full;
@property (nonatomic, retain) NSString *nolink_miniature;
@property (nonatomic, retain) NSString *nolink_preview;

@property (nonatomic, retain) NSDate *timeStamp;

@property int version;
@property BOOL deleted;

-(void)create;
-(void)upload:(UIImage *)picture;

@end