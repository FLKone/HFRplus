//
//  UIImageViewCustom.h
//  HFRplus
//
//  Created by Shasta on 17/09/10.
//  Copyright 2010 FLK. All rights reserved.
//
@class ImageScrollView;


@interface UIImageViewCustom : UIImageView {
	ImageScrollView *parent;
}

@property (nonatomic, assign) ImageScrollView *parent;

-(void)configureCustom;
-(void)configureFail;

@end
