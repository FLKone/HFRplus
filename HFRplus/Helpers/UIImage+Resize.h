//
//  UIImage+Resize.h
//  HFRplus
//
//  Created by FLK on 22/07/12.
//



@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
@end
