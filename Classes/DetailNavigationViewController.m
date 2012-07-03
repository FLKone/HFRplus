//
//  DetailNavigationViewController.m
//  HFRplus
//
//  Created by FLK on 02/07/12.
//

#import "DetailNavigationViewController.h"
#import "MessagesTableViewController.h"
#import "SplitViewController.h"

@interface DetailNavigationViewController ()

@end

@implementation DetailNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self topViewController] setTitle:@"HFR+"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] popOver] dismissPopoverAnimated:YES];
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];
        SplitViewController *mySplit = [[HFRplusAppDelegate sharedAppDelegate] splitViewController];
        
        [navItem setLeftBarButtonItem:[mySplit mybarButtonItem] animated:YES];
    }

    if ([viewController isKindOfClass:[MessagesTableViewController class]]) {
        [navigationController setNavigationBarHidden:FALSE animated:animated];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if ([enabled isEqualToString:@"all"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

@end