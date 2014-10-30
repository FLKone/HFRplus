//
//  TabBarController.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "TabBarController.h"
#import "HFRplusAppDelegate.h"

@implementation TabBarController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	//NSLog(@"TBC viewDidLoad");
    
    
    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        [tabBarItem1 setImage:[UIImage imageNamed:@"44-shoebox"]];
        [tabBarItem2 setImage:[UIImage imageNamed:@"28-star"]];
        [tabBarItem3 setImage:[UIImage imageNamed:@"18-envelope.png"]];
        [tabBarItem4 setImage:[UIImage imageNamed:@"06-magnify.png"]];
        
    } else {
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"categories_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem1.image = [[UIImage imageNamed:@"categories"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"favorites_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem2.image = [[UIImage imageNamed:@"favorites"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"mp_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem3.image = [[UIImage imageNamed:@"mp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"search_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
        tabBarItem4.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tab = [defaults stringForKey:@"default_tab"];
    
	if (tab) {
		[self setSelectedIndex:[tab intValue]];
	} else {
		//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
    
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
	[label release];
	 
	//moreNavigationBar.topItem.title = [NSString stringWithFormat:@"HFR+ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	//UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Déconnexion" style:UIBarButtonItemStyleBordered target:self action:nil];
	//moreNavigationBar.topItem.leftBarButtonItem = segmentBarItem;
	
	//[segmentBarItem release];
     
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	//NSLog(@"didSelectViewController %@", viewController);
	/*
	if ([[NSString stringWithFormat:@"%@", [viewController class]] isEqualToString:@"UIMoreNavigationController"]) {
		NSLog(@"UIMoreNavigationController");
	}
	*/
}

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
- (NSUInteger)supportedInterfaceOrientations
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

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"new orientation: %d", [[UIDevice currentDevice] orientation]);
}
*/
- (void)dealloc {
    [super dealloc];
}


@end
