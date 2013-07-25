//
//  UIImage+Resize.h
//  HFRplus
//
//  Created by FLK on 22/07/12.
//



@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)offColor;
- (UIImage*)mergeWith:(UIImage *)mergeImage;
-(UIImage*) imageResizingModeTile;
@end
