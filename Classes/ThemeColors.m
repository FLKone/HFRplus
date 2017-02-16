//
//  k.m
//  HFRplus
//
//  Created by FLK on 09/09/2016.
//
//

#import "ThemeColors.h"

@implementation ThemeColors

+ (UIColor *)tabBackgroundColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)navBackgroundColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:46.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)textColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)greyBackgroundColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor groupTableViewBackgroundColor];
    }else{
        return [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)cellBackgroundColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)cellHighlightBackgroundColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)cellIconColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)cellTextColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor blackColor];
    }else{
        return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)cellBorderColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:68.0/255.0 green:70.0/255.0 blue:77.0/255.0 alpha:1.0];
    }
}

+ (UITableViewCellSelectionStyle *)cellSelectionStyle:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return UITableViewCellSelectionStyleDefault;
    }else{
        return UITableViewCellSelectionStyleNone;
    }
};

+ (UIColor *)tintColor:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:241.0/255.0 green:143.0/255.0 blue:24.0/255.0 alpha:1.0];
    }
}

+ (UIBarStyle *)barStyle:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return UIBarStyleDefault;
    }else{
        return UIBarStyleBlack;
    }
}


+ (NSString *)creditsCss:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return @"body{background:#efeff4;}.ios7 h1 {background:#efeff4;color: rgba(109, 109, 114, 1);}.ios7 ul {background:#fff;}.ios7 ul, .ios7 p {background:#fff;}";
    }else{
        return @"body{background:rgba(30, 31, 33, 1);color: rgba(146, 147, 151, 1);} a{color: rgba(241, 143, 24, 1);} .ios7 h1 {background:rgba(36, 37, 41, 1);color: rgba(109, 109, 114, 1);}.ios7 ul, .ios7 p {background:rgba(30, 31, 33, 1);}";
    }
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)thorHammer:(NSString *)theme{
    if([theme isEqualToString:@"0"]){
        return [UIImage imageNamed:@"ThorHammerBlack-20"];
    }else{
        return [UIImage imageNamed:@"ThorHammerGrey-20"];
    }
}


@end
