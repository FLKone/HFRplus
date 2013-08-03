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
        NSLog(@"HFRTableView %@", self);

        if (self.pagingEnabled) {
            NSLog(@"pagingEnabled YES");
            self.pagingEnabled = NO;
        }
        else
        {
            NSLog(@"pagingEnabled NO");
            self.disableLoadingMore = YES;
        }
        
        NSLog(@"self.disableLoadingMore %d", self.disableLoadingMore);
        
        [self setScrollIndicatorInsets:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 00)];
        [self setContentInset:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 00)];
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

- (BOOL) allowsHeaderViewsToFloat {
    //NSLog(@"allowsHeaderViewsToFloat");
    
    return NO;
}




@end
