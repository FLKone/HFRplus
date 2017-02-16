//
//  UIWebView+Tools.m
//  HFRplus
//
//  Created by Shasta on 24/03/13.
//
//

#import "UIWebView+Tools.h"

@implementation UIWebView (Tools)

- (void) hideGradientBackground
{
    self.backgroundColor = [UIColor redColor];
    for (UIView* subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView* subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

@end
