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

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        //hack to enable "Load More" cell at bottom using pagingEnabled prop.
        if (self.pagingEnabled) {
            self.pagingEnabled = NO;
        }
        else
        {
            self.disableLoadingMore = YES;
        }
        
        [self orientationChanged:NULL];

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

extern float kTableViewContentInsetTop;
extern float kTableViewContentInsetBottom;

- (void)orientationChanged:(NSNotification *) notif {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSLog(@"%f %f", kTableViewContentInsetTop, kTableViewContentInsetBottom);
    
    NSLog(@"BEFORE ======== ");
    NSLog(@"scroll %@", NSStringFromUIEdgeInsets(self.scrollIndicatorInsets));
    NSLog(@"conten %@", NSStringFromUIEdgeInsets(self.contentInset));
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        NSLog(@"PORTRAIT");
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            kTableViewContentInsetTop = 64.0f;
            kTableViewScrollInsetTop = 64.0f;
            kTableViewContentInsetBottom = 42.0f;
            
            if (self.scrollIndicatorInsets.top == 0) {
                kTableViewScrollInsetTop = 0;
            }
        }
        else
        {
            kTableViewContentInsetTop = 44.0f;
            kTableViewScrollInsetTop = 44.0f;
            kTableViewContentInsetBottom = 42.0f;
        }

        if (SYSTEM_VERSION_LESS_THAN(@"7")) {
            //if (self.scrollIndicatorInsets.top != kTableViewContentInsetTop) {
                [self setScrollIndicatorInsets:UIEdgeInsetsMake(kTableViewScrollInsetTop, 0, kTableViewContentInsetBottom, 0)];
                [self setContentInset:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 0)];
            //}
        }
        else
        {
            if (self.scrollIndicatorInsets.top != kTableViewContentInsetTop) {
                [self setScrollIndicatorInsets:UIEdgeInsetsMake(kTableViewScrollInsetTop, 0, kTableViewContentInsetBottom, 0)];
                [self setContentInset:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 0)];
            }
        }
    }
    else
    {
        NSLog(@"LANDSCAPE");
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            kTableViewContentInsetTop = 53.0f;
            kTableViewContentInsetBottom = 32.0f;
            
            if (self.scrollIndicatorInsets.top == 0) {
                kTableViewScrollInsetTop = 0;
            }
        }
        else
        {
            kTableViewContentInsetTop = 32.0f;
            kTableViewContentInsetBottom = 32.0f;
        }

        
        if (SYSTEM_VERSION_LESS_THAN(@"7")) {
            if (self.scrollIndicatorInsets.top != kTableViewContentInsetTop) {
                [self setScrollIndicatorInsets:UIEdgeInsetsMake(kTableViewScrollInsetTop, 0, kTableViewContentInsetBottom, 0)];
                [self setContentInset:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 0)];
            }
        }
        else
        {
            if (self.scrollIndicatorInsets.top != kTableViewContentInsetTop) {
                [self setScrollIndicatorInsets:UIEdgeInsetsMake(kTableViewScrollInsetTop, 0, kTableViewContentInsetBottom, 0)];
                [self setContentInset:UIEdgeInsetsMake(kTableViewContentInsetTop, 0, kTableViewContentInsetBottom, 0)];
            }
        }
    }
    NSLog(@"END ======== ");
    NSLog(@"scroll %@", NSStringFromUIEdgeInsets(self.scrollIndicatorInsets));
    NSLog(@"conten %@", NSStringFromUIEdgeInsets(self.contentInset));
    
    //44 //32
    //43 //32
    
   // NSLog(@"notif %@", notif);
}

- (BOOL) allowsHeaderViewsToFloat {
    //NSLog(@"allowsHeaderViewsToFloat");
    
    return NO;
}


@end
