//
//  UIBarButtonItem+Extension.m
//  HFRplus
//
//  Created by Shasta on 16/06/13.
//
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (UIBarButtonItem*)barItemWithImageNamed:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *imageOff = [UIImage imageNamed:imageName];
    UIImage *imageOn = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on", imageName]];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, imageOff.size.width, imageOff.size.height);
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [button setImage:imageOff forState:UIControlStateNormal];
    [button setImage:imageOn forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateHighlighted];

    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return [barButtonItem autorelease];
}

@end
