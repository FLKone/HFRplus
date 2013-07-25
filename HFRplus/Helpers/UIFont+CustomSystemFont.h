//
//  UIFont+CustomSystemFont.h
//  HFRplus
//
//  Created by Shasta on 22/07/13.
//
//

#import <UIKit/UIKit.h>

@interface UIFont (CustomSystemFont)

+(UIFont *)_systemFontOfSize:(CGFloat)fontSize;
+(UIFont *)_boldSystemFontOfSize:(CGFloat)fontSize;
+(UIFont *)_italicSystemFontOfSize:(CGFloat)fontSize;

@end
