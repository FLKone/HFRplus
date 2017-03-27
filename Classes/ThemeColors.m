//
//  ThemeColors.m
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import "ThemeColors.h"
#import "Constants.h"

@implementation ThemeColors

+ (UIColor *)tabBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)navBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:46.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)textColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}

+ (UIColor *)lightTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:186.0/255.0 green:186.0/255.0 blue:186.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}

+ (UIColor *)topicMsgTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
        case ThemeDark:
            return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
            default:
            return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
            
    }
}

+ (UIColor *)greyBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor groupTableViewBackgroundColor];
        case ThemeDark:
            return [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0];
        default:
            return [UIColor groupTableViewBackgroundColor];
            
    }
}

+ (UIColor *)addMessageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellHighlightBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellIconColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}

+ (UIColor *)cellTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor blackColor];
        case ThemeDark:
            return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:
            return [UIColor blackColor];
            
    }
}

+ (UIColor *)cellBorderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:68.0/255.0 green:70.0/255.0 blue:77.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)placeholderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor grayColor];
        case ThemeDark:
            return [UIColor colorWithRed:110.0/255.0 green:113.0/255.0 blue:125.0/255.0 alpha:1.0];
        default:
            return [UIColor grayColor];
            
    }
}

+ (UIColor *)headSectionBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
        case ThemeDark:
            return [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:0.85];
        default:
            return [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
    }
}

+ (UIColor *)headSectionTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1];
        case ThemeDark:
            return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1];
    }
}

+ (UITableViewCellSelectionStyle)cellSelectionStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UITableViewCellSelectionStyleDefault;
        case ThemeDark:
            return UITableViewCellSelectionStyleNone;
        default:
            return UITableViewCellSelectionStyleDefault;
            
    }
};

+ (UIColor *)tintColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:241.0/255.0 green:143.0/255.0 blue:24.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            
    }
}

+ (UIColor *)tintLightColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)tintWhiteColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor whiteColor];
        case ThemeDark:
            return [UIColor colorWithRed:241.0/255.0 green:143.0/255.0 blue:24.0/255.0 alpha:1.0];
            default:
            return [UIColor whiteColor];
            
    }
}

+ (UIColor *)overlayColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        case ThemeDark:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
            default:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
            
    }
}

+ (UIColor *)toolbarColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1.0];
            default:
            return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)toolbarPageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:38.0/255.0 green:40.0/255.0 blue:46.0/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
            
    }
}


+ (UIBarStyle)barStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIBarStyleDefault;
        case ThemeDark:
            return UIBarStyleBlack;
        default:
            return UIBarStyleDefault;
            
    }
}

+ (UIStatusBarStyle)statusBarStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIStatusBarStyleDefault;
        case ThemeDark:
            return UIStatusBarStyleLightContent;
        default:
            return UIStatusBarStyleDefault;
            
    }
}

+ (UIKeyboardAppearance)keyboardAppearance:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIKeyboardAppearanceDefault;
        case ThemeDark:
            return UIKeyboardAppearanceDark;
        default:
            return UIKeyboardAppearanceDefault;
            
    }
}


+ (NSString *)creditsCss:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"body{background:#efeff4;}.ios7 h1 {background:#efeff4;color: rgba(109, 109, 114, 1);}.ios7 ul {background:#fff;}.ios7 ul, .ios7 p {background:#fff;}";
        case ThemeDark:
            return @"body{background:rgba(30, 31, 33, 1);color: rgba(146, 147, 151, 1);} a{color: rgba(241, 143, 24, 1);} .ios7 h1 {background:rgba(36, 37, 41, 1);color: rgba(109, 109, 114, 1);}.ios7 ul, .ios7 p {background:rgba(30, 31, 33, 1);}";
        default:
            return @"body{background:#efeff4;}.ios7 h1 {background:#efeff4;color: rgba(109, 109, 114, 1);}.ios7 ul {background:#fff;}.ios7 ul, .ios7 p {background:#fff;}";
    }
}

+ (NSString *)smileysCss:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"body.ios7 {background:#bbc2c9;} body.ios7 .button { background-image : none !important; background-color : rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(136,138,142,1); }";
        case ThemeDark:
            return @"body.ios7 {background:rgba(30, 31, 33, 1);} body.ios7 .button { background-image : none !important; background-color : rgba(255, 255, 255,0.2); border-bottom:1px solid rgb(68,70,77); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255, 255, 255, 0.2); border-bottom:1px solid rgb(68,70,77); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(255,255,255,0.1); }";
        default:
            return @"body.ios7 {background:#bbc2c9;} body.ios7 .button { background-image : none !important; background-color : rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(136,138,142,1); }";
    }
}

+ (NSString *)messagesCssPath:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"style-liste.css";
        case ThemeDark:
            return @"style-liste-dark.css";
        default:
            return @"style-liste.css";
    }
}

+ (NSString *)messagesRetinaCssPath:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"style-liste-retina.css";
        case ThemeDark:
            return @"style-liste-retina-dark.css";
        default:
            return @"style-liste-retina.css";
    }
}

+ (NSString *)landscapePath:(Theme)theme{
    switch (theme) {
    case ThemeLight:
        return @"121-landscapebig.png";
    case ThemeDark:
        return @"121-landscapebig-white.png";
    default:
        return @"121-landscapebig.png";
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

+ (UIImage *)thorHammer:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIImage imageNamed:@"ThorHammerBlack-20"];
        case ThemeDark:
            return [UIImage imageNamed:@"ThorHammerGrey-20"];
        default:
            return [UIImage imageNamed:@"ThorHammerBlack-20"];
    }
}

+ (UIImage *)tintImage:(UIImage *)image withTheme:(Theme)theme{
    return [self tintImage:image withColor:[self tintColor:theme]];
}


+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color{
    
            UIImage *imageNormal = image;
            UIGraphicsBeginImageContextWithOptions(imageNormal.size, NO, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = (CGRect){ CGPointZero, imageNormal.size };
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            [imageNormal drawInRect:rect];
            
            CGContextSetBlendMode(context, kCGBlendModeSourceIn);
            [color setFill];
            CGContextFillRect(context, rect);
            
            UIImage *imageTinted  = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return imageTinted;
}


+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIActivityIndicatorViewStyleGray;
        case ThemeDark:
            return UIActivityIndicatorViewStyleWhite;
        default:
           return UIActivityIndicatorViewStyleGray;
    }
}
@end
