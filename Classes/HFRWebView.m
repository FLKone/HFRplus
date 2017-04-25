//
//  HFRWebView.m
//  HFRplus
//
//  Created by FLK on 20/09/2015.
//
//

#import "HFRWebView.h"

@implementation HFRWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL) canBecomeFirstResponder {
    //NSLog(@"===== WV canBecomeFirstResponder");
    
    return YES;//[super canBecomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    //NSLog(@"===== WW canPerformAction %@ nbS=%@", NSStringFromSelector(action), sender);

    if ([NSStringFromSelector(action) isEqualToString:@"selectAll:"]) return NO;
    if ([NSStringFromSelector(action) isEqualToString:@"_define:"]) return NO;
    if ([NSStringFromSelector(action) isEqualToString:@"_share:"]) return NO;
    
    return [super canPerformAction:action withSender:sender];
}

- (id)targetForAction:(SEL)action withSender:(id)sender {
    
    //NSLog(@"===== WW targetForAction %@ nbS=%@", NSStringFromSelector(action), sender);

    return [super targetForAction:action withSender:sender];
}

@end
