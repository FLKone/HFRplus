//
//  MessageWebView.m
//  HFRplus
//
//  Created by Shasta on 02/05/13.
//
//

#import "MessageWebView.h"

@implementation MessageWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    NSLog(@"MWV %@ %d", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count);

    int nbCustom = [UIMenuController sharedMenuController].menuItems.count;
    
    if (nbCustom) {
        NSLog(@"NO");
        return NO;
    }

    //NSLog(@"MWV %@ %d %@", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count, sender);
    BOOL returnB = [super canPerformAction:action withSender:sender];
    NSLog(@"MWV returnB %d", returnB);
    return returnB;
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
