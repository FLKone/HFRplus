//
//  TabBarController.h
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

@interface TabBarController : UITabBarController <UITabBarControllerDelegate> {

}

@property (nonatomic, strong) UIImageView *bgView;
-(void)popAllToRoot:(BOOL)includingSelectedIndex;
@end
