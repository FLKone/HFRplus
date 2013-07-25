//
//  UIImage+Resize.m
//  HFRplus
//
//  Created by FLK on 22/07/12.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage*)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);

    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return scaledImage;
}

- (UIImage*)offColor;
{
    
    UIImage *imageBase = self;
    
    //    UIColor *tintColor = [UIColor colorWithRed:242/255.f green:144/255.f blue:27/255.f alpha:1.0f];
    UIColor *tintColor = [UIColor blackColor];
    
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
    
    return coloredImage;
}

- (UIImage*)mergeWith:(UIImage *)mergeImage
{
    return self;
    
    //UIImage *image = upperImage;
    
    CGSize newSize = CGSizeMake(self.size.width, self.size.height);
    CGRect rect = CGRectMake(20, 0, 32, 32);
    
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Apply supplied opacity
    
    [mergeImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*) imageResizingModeTile
{
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if( iOSVersion >= 6.0f )
    {
        return [self resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    }
    else
    {
        return [self resizableImageWithCapInsets:UIEdgeInsetsZero];
    }
}

@end
