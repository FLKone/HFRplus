//
//  TabBarController.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "TabBarController.h"
#import "HFRplusAppDelegate.h"
#import "FavoritesTableViewController.h"

@implementation TabBarController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	NSLog(@"TBC viewDidLoad");
    self.title = @"Menu";
    if ([self.tabBar respondsToSelector:@selector(setTranslucent:)]) {
        self.tabBar.translucent = NO;
    }

    
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
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"categories_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.image = [[UIImage imageNamed:@"categories"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"favorites_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.image = [[UIImage imageNamed:@"favorites"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"mp_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.image = [[UIImage imageNamed:@"mp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"dots_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.image = [[UIImage imageNamed:@"dots"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        //tabBarItem4.selectedImage = [[UIImage imageNamed:@"search_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        //tabBarItem4.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tab = [defaults stringForKey:@"default_tab"];
    
	if (tab) {
		[self setSelectedIndex:[tab intValue]];
	} else {
		//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
    /*
	UINavigationBar *moreNavigationBar = self.moreNavigationController.navigationBar;
	
	// Make the title of this page the same as the title of this app
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor =[UIColor whiteColor];
	//label.text= @"HFR+ 1.1 (1.1.0.7)";
	label.text= [NSString stringWithFormat:@"HFR+ %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];	
	//label.text= [NSString stringWithFormat:@"HFR+ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];	
	moreNavigationBar.topItem.titleView = label;		
	 */
	//moreNavigationBar.topItem.title = [NSString stringWithFormat:@"HFR+ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	//UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Déconnexion" style:UIBarButtonItemStyleBordered target:self action:nil];
	//moreNavigationBar.topItem.leftBarButtonItem = segmentBarItem;
	
	//[segmentBarItem release];
     
}

- (BOOL)tabBarController:(UITabBarController * _Nonnull)tabBarController shouldSelectViewController:(UIViewController * _Nonnull)viewController {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nv = (UINavigationController *)viewController;
//      NSLog(@"curtab %lu", (unsigned long)tabBarController.selectedIndex);
//      NSLog("class top : %@ !!!", [nv.topViewController class]);
        
        //actualisation si tap sur l'onglet
        if (tabBarController.selectedIndex == 1 && [nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            [(FavoritesTableViewController *)nv.topViewController reload];
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
