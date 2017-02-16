//
//  ThemeColors.h
//  HFRplus
//
//  Created by aynolor
//
//

#import <Foundation/Foundation.h>

@interface ThemeColors : NSObject
+ (UIColor *)tabBackgroundColor:(NSString *)theme;
+ (UIColor *)navBackgroundColor:(NSString *)theme;
+ (UIColor *)greyBackgroundColor:(NSString *)theme;
+ (UIColor *)cellBackgroundColor:(NSString *)theme;
+ (UIColor *)cellHighlightBackgroundColor:(NSString *)theme;
+ (UITableViewCellSelectionStyle *)cellSelectionStyle:(NSString *)theme;
+ (UIColor *)cellIconColor:(NSString *)theme;
+ (UIColor *)cellTextColor:(NSString *)theme;
+ (UIColor *)cellBorderColor:(NSString *)theme;
+ (UIColor *)textColor:(NSString *)theme;
+ (UIColor *)tintColor:(NSString *)theme;
+ (NSString *)creditsCss:(NSString *)theme;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIBarStyle *)barStyle:(NSString *)theme;
+ (UIImage *)thorHammer:(NSString *)theme;
@end
