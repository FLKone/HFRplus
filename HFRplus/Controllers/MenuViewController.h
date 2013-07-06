//
//  MenuViewController.h
//  HFRplus
//
//  Created by Shasta on 15/06/13.
//
//

#import <UIKit/UIKit.h>
@class MenuButton;
@class WEPopoverController;

@interface MenuViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UINavigationController *activeController;
@property (strong, nonatomic) MenuButton *activeMenu;
@property (strong, nonatomic) UINavigationController *navigationTab1Controller;

@property (strong, nonatomic) UINavigationController *forumsController;
@property (strong, nonatomic) UINavigationController *favoritesController;
@property (strong, nonatomic) UINavigationController *searchController;
@property (strong, nonatomic) UINavigationController *messagesController;

@property (strong, nonatomic) IBOutlet MenuButton *btnCategories;
@property (strong, nonatomic) IBOutlet MenuButton *btnFavoris;
@property (strong, nonatomic) IBOutlet MenuButton *btnSearch;
@property (strong, nonatomic) IBOutlet MenuButton *btnTabs;
@property (strong, nonatomic) IBOutlet MenuButton *btnMessages;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSMutableArray *tabsViews;

@property (nonatomic) BOOL isAnimating;


@property (strong, nonatomic) IBOutlet UIView *popoverView;

//@property (strong, nonatomic) WEPopoverController *popoverView;

- (IBAction)switchBtn:(id)sender forEvent:(UIEvent *)event;

- (void)loadTab:(id)viewController;

@end