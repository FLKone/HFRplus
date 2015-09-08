//
//  MessageWebView.m
//  HFRplus
//
//  Created by Shasta on 02/05/13.
//
//

#import "MessageWebView.h"
#import "MessagesTableViewController.h"

@implementation MessageWebView
@synthesize controll;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    //NSLog(@"MWV %@ %lu", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count);

    int nbCustom = [UIMenuController sharedMenuController].menuItems.count;
    
    if (nbCustom > 2) {
        //NSLog(@"NO");
        return NO;
    }

    //NSLog(@"MWV %@ %lu %@", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count, sender);
    //NSLog(@"super %@", [super class]);
    if ([NSStringFromSelector(action) isEqualToString:@"textQuote:"] || [NSStringFromSelector(action) isEqualToString:@"textQuoteBold:"]) {
        return YES;
    }
    BOOL returnB = [super canPerformAction:action withSender:sender];
    //NSLog(@"MWV returnB %d", returnB);
    return returnB;
}

-(void)textQuote:(id)sender {
    [self.controll textQuote:sender];
}

-(void)textQuoteBold:(id)sender {
    [self.controll textQuoteBold:sender];
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
