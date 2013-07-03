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

    UIImage *imageBase = [UIImage imageNamed:imageName];
    
//    UIColor *tintColor = [UIColor colorWithRed:242/255.f green:144/255.f blue:27/255.f alpha:1.0f];
    UIColor *tintColor = [UIColor lightGrayColor];
    
    UIGraphicsBeginImageContext(imageBase.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, imageBase.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, imageBase.size.width, imageBase.size.height);
    
    // image drawing code here
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, imageBase.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //NSLog(@"imageBase %@", NSStringFromCGSize(imageBase.size));
    //NSLog(@"coloredImage %@", NSStringFromCGSize(coloredImage.size));
    
    
    UIImage *imageOff = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on", imageName]];

    UIImage *imageOn = coloredImage;//[UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, imageOff.size.width, imageOff.size.height);
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [button setImage:imageOff forState:UIControlStateNormal];
    [button setImage:imageOn forState:UIControlStateHighlighted];
    [button setImage:imageOn forState:UIControlStateSelected];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"grey_dot_a"] forState:UIControlStateNormal];
  //  [button setBackgroundImage:[UIImage imageNamed:@"grey_dot_a"] forState:UIControlStateHighlighted];
//    [button setBackgroundImage:[UIImage imageNamed:@"grey_dot_a"] forState:UIControlStateSelected];

    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return [barButtonItem autorelease];
}

@end
