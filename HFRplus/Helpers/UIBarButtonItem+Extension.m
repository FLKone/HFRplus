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
    
    UIColor *tintColor = [UIColor whiteColor];
    
    UIGraphicsBeginImageContext(imageOff.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, imageOff.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, imageOff.size.width, imageOff.size.height);
    
    // image drawing code here
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, imageOff.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    
    UIImage *imageOn = coloredImage;//[UIImage imageNamed:[NSString stringWithFormat:@"%@_on", imageName]];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, imageOff.size.width, imageOff.size.height);
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [button setImage:imageOff forState:UIControlStateNormal];
    [button setImage:imageOn forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:[UIImage imageNamed:@"orangedark_dot"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"orangedark_dot"] forState:UIControlStateHighlighted];

    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return [barButtonItem autorelease];
}

@end
