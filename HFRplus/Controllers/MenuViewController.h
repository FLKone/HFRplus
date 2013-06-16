//
//  MenuViewController.h
//  HFRplus
//
//  Created by Shasta on 15/06/13.
//
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *btnCategories;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *popoverView;

- (IBAction)switchBtn:(id)sender forEvent:(UIEvent *)event;

@end
