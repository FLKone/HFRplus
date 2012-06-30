//
//  UIImageViewCustom.h
//  HFRplus
//
//  Created by FLK on 17/09/10.
//
@class ImageScrollView;


@interface UIImageViewCustom : UIImageView {
	ImageScrollView *parent;
}

@property (nonatomic, assign) ImageScrollView *parent;

-(void)configureCustom;
-(void)configureFail;

@end
