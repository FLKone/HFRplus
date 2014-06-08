//
//  PullToRefreshErrorViewController.h
//  HFRplus
//
//  Created by Shasta on 25/05/2014.
//
//

#import <UIKit/UIKit.h>

@interface PullToRefreshErrorViewController : UIViewController {
    
    UIImageView *image;
    UILabel *label;

    NSDictionary *dico;

}

@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSDictionary *dico;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDico:(NSDictionary*) dic;
-(void)sizeToFit;

@end
