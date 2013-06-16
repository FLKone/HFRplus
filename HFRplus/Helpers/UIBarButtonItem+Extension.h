//
//  UIBarButtonItem+Extension.h
//  HFRplus
//
//  Created by Shasta on 16/06/13.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

+ (UIBarButtonItem*)barItemWithImageNamed:(NSString*)image title:(NSString*)title target:(id)target action:(SEL)action;

@end
