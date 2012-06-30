//
//  UIImageViewCustom.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "UIImageViewCustom.h"
#import "ImageScrollView.h"


@implementation UIImageViewCustom
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
/*
#pragma mark -
#pragma mark UIImageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage*)image {
	NSLog(@"setImage");
	self.contentMode = UIViewContentModeScaleAspectFill;

	[super setImage:image];
	
	
	if (image != _defaultImage || !_photo || self.urlPath != [_photo URLForVersion:TTPhotoVersionLarge]) {
		if (image == _defaultImage) {
			self.contentMode = UIViewContentModeCenter;
			
		} else {
			self.contentMode = UIViewContentModeScaleAspectFill;
		}
		
		[super setImage:image];
	}
	 
}

#pragma mark -
#pragma mark UIView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
	NSLog(@"layoutSubviews");
}
*/

-(void)configureCustom {
	//NSLog(@"======= configureCustom");
	self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
	[self.parent configureForImageSize:self.image.size];
	[self.parent setIsOK:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"imageDownloadedPhotos" object:[NSNumber numberWithInt:[self.parent index]]];

	//[self.parent configureForImageSize:self.image.size];
}

-(void)configureFail {
	//NSLog(@"======= configureCustom");
	self.image = [UIImage imageNamed:@"photoDefaultfail.png"];
	[self.parent setIsOK:NO];
	//[self.parent configureForImageSize:self.image.size];
}


- (void)dealloc {
    [super dealloc];
	
	self.parent = nil;
}


@end
