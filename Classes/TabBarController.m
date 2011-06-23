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
	
	NSLog(@"TBC viewDidLoad");
    
    
    
    
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
	label.textAlignment = UITextAlignmentCenter;
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

- (void)browserViewControllerDidFinish:(BrowserViewController *)controller {
    // NSLog(@"photoViewControllerDidFinish");
    
	[self dismissModalViewControllerAnimated:YES];
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
