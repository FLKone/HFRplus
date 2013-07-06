//
//  HFRTableView.m
//  HFRplus
//
//  Created by Shasta on 04/07/13.
//
//

#import "HFRTableView.h"

@implementation HFRTableView

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Initialization code
        NSLog(@"initWithCoder");
        [self setScrollIndicatorInsets:UIEdgeInsetsMake(44.0f, 0, 39.0f, 00)];
        [self setContentInset:UIEdgeInsetsMake(44.0f, 0, 39.0f, 00)];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
