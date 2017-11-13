//
//  TabBarController.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "TabBarController.h"
#import "HFRplusAppDelegate.h"
#import "FavoritesTableViewController.h"
#import "HFRMPViewController.h"
#import "ForumsTableViewController.h"
#import "ThemeColors.h"
#import "ThemeManager.h"



@implementation TabBarController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	//NSLog(@"TBC viewDidLoad %@", self.tabBar);
    self.title = @"Menu";

    
    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        [tabBarItem1 setImage:[UIImage imageNamed:@"44-shoebox"]];
        [tabBarItem2 setImage:[UIImage imageNamed:@"28-star"]];
        [tabBarItem3 setImage:[UIImage imageNamed:@"18-envelope.png"]];
        [tabBarItem4 setImage:[UIImage imageNamed:@"19-gear.png"]];
        
    } else {
        //NSLog(@"////// %@", self.tabBar.items);
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"categories_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.image = [[UIImage imageNamed:@"categories"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.title = @"Catégories";
        //tabBarItem1.titlePositionAdjustment = UIOffsetMake(0.f, 50.f);
        //tabBarItem1.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"favorites_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.image = [[UIImage imageNamed:@"favorites"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.title = @"Vos Sujets";
        //tabBarItem2.titlePositionAdjustment = UIOffsetMake(0.f, 50.f);
        //tabBarItem2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"mp_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.image = [[UIImage imageNamed:@"mp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.title = @"Messages";
        //tabBarItem3.titlePositionAdjustment = UIOffsetMake(0.f, 50.f);
        //tabBarItem3.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"dots_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.image = [[UIImage imageNamed:@"dots"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.title = @"Réglages";
        //tabBarItem4.titlePositionAdjustment = UIOffsetMake(0.f, 50.f);
        //tabBarItem4.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        //tabBarItem4.selectedImage = [[UIImage imageNamed:@"search_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        //tabBarItem4.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tab = [defaults stringForKey:@"default_tab"];
    
    if (tab) {
        [self setSelectedIndex:[tab intValue]];
    }
    
}


-(void)setThemeFromNotification:(NSNotification *)notification{
    [self setTheme:[[ThemeManager sharedManager] theme]];
}

-(void)setTheme:(Theme)theme{
    if ([[UITabBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
        [[UITabBar appearance] setTranslucent:YES];
    }

    if(!self.bgView){
        self.bgView = [[UIImageView alloc] initWithImage:[ThemeColors imageFromColor:[UIColor redColor]]];
        self.bgView.frame = CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
        [self.bgView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.tabBar addSubview:self.bgView];
        [self.tabBar sendSubviewToBack:self.bgView];

    }
    
    self.bgView.image =[ThemeColors imageFromColor:[ThemeColors tabBackgroundColor:theme]];
    self.tabBar.tintColor = [ThemeColors tintColor:theme];
    
    if([self.childViewControllers count] > 0){
        for (int i=0; i<[self.childViewControllers count]; i++) {
            UINavigationController *nvc = (UINavigationController *)[self.childViewControllers objectAtIndex:i];
            nvc.navigationBar.barStyle = [ThemeColors barStyle:theme];
        }
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setThemeFromNotification:)
                                            name:kThemeChangedNotification
                                               object:nil];
    [self setTheme:[[ThemeManager sharedManager] theme]];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nv = (UINavigationController *)viewController;
//      NSLog(@"curtab %lu", (unsigned long)tabBarController.selectedIndex);
//      NSLog("class top : %@ !!!", [nv.topViewController class]);
        
        //actualisation si tap sur l'onglet
        if (tabBarController.selectedIndex == 0 && [nv.topViewController isKindOfClass:[ForumsTableViewController class]]) {
            [(ForumsTableViewController *)nv.topViewController reload];
        }
        
        if (tabBarController.selectedIndex == 1 && [nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            [(FavoritesTableViewController *)nv.topViewController reload];
        }
        
        if (tabBarController.selectedIndex == 2 && [nv.topViewController isKindOfClass:[HFRMPViewController class]]) {
            [(HFRMPViewController *)nv.topViewController fetchContent];
        }

    }
    return YES;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    // Unsure why WKWebView calls this controller - instead of it's own parent controller
    if (self.presentedViewController) {
        NSLog(@"PRESENTED %@", self.presentedViewController);
        [self.presentedViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}


/*
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSLog(@"didSelectViewController %@", viewController);
	
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nv = (UINavigationController *)viewController;
        if ([nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            NSLog("favprotes !!!");
        }
    }

}
*/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
		
	if ([enabled isEqualToString:@"all"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	
}

/* for iOS6 support */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //NSLog(@"supportedInterfaceOrientations");
    
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"all"]) {
        //NSLog(@"All");
        
		return UIInterfaceOrientationMaskAll;
	} else {
        //NSLog(@"Portrait");
        
		return UIInterfaceOrientationMaskPortrait;
	}
}


- (BOOL)shouldAutorotate
{
    //NSLog(@"shouldAutorotate");

    return YES;
}

-(void)popAllToRoot:(BOOL)includingSelectedIndex {
    //not selectedIndex
    long nbTab = self.viewControllers.count;
    
    for (int i = 0; i < nbTab; i++) {
        if (includingSelectedIndex || (!includingSelectedIndex && i != self.selectedIndex)) {
            [(UINavigationController *)self.viewControllers[i] popToRootViewControllerAnimated:NO];
        }
    }
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"new orientation: %d", [[UIDevice currentDevice] orientation]);
}
*/


@end
