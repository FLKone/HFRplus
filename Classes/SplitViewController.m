//
//  SplitViewController.m
//  HFRplus
//
//  Created by FLK on 02/07/12.
//

#import "SplitViewController.h"
#import "HFRplusAppDelegate.h"
#import "MessagesTableViewController.h"

#import "AideViewController.h"

@interface SplitViewController ()

@end

@implementation SplitViewController
@synthesize popOver, mybarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.mybarButtonItem = [[UIBarButtonItem alloc] init];

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if ([self respondsToSelector:@selector(setPresentsWithGesture:)]) {
        [self setPresentsWithGesture:NO];
    }

    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)MoveLeftToRight {
    
    //Les deux controllers
    TabBarController *leftTabBarController = [self.viewControllers objectAtIndex:0];
    UINavigationController *rightNavController = [self.viewControllers objectAtIndex:1];
    
    [rightNavController popToRootViewControllerAnimated:YES];
    
    [rightNavController setViewControllers:nil];
    UIViewController * uivc = [[[UIViewController alloc] init] autorelease];
    uivc.title = @"HFR+";
    [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:uivc, nil]];

    
    
    //Première tab > navController > msgController
    //leftTabBarController.selectedIndex = 0;
    UINavigationController *leftNavController= (UINavigationController *)leftTabBarController.selectedViewController;
    
    if ([leftNavController.topViewController isMemberOfClass:[MessagesTableViewController class]]) {
        MessagesTableViewController *leftMessageController = (MessagesTableViewController *)leftNavController.topViewController;
        NSString *currentUrl = leftMessageController.currentUrl;
        
        [leftNavController popViewControllerAnimated:YES];
        
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:currentUrl];
        [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:aView, nil] animated:YES];
        [aView release];

    }

    NSLog(@"END MoveLeftToRight");
}

-(void)MoveRightToLeft:(NSString *)url {
    NSLog(@"MoveRightToLeft");
    
    //Les deux controllers
    TabBarController *leftTabBarController = [self.viewControllers objectAtIndex:0];
    UINavigationController *rightNavController = [self.viewControllers objectAtIndex:1];
    
    //Première tab > navController
    //leftTabBarController.selectedIndex = 0;
    UINavigationController *leftNavController= (UINavigationController *)leftTabBarController.selectedViewController;
    
    //deuxième tab > msgController
    MessagesTableViewController *rightMessageController = (MessagesTableViewController *)rightNavController.topViewController;
    
    [rightMessageController.navigationItem setLeftBarButtonItem:nil animated:NO];
    
    rightMessageController.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                     style: UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        rightMessageController.navigationItem.backBarButtonItem.title = @" ";
    }
    
    MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:rightMessageController.currentUrl];
    [leftNavController pushViewController:aView animated:YES];
    [aView release];
    
    BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil andURL:url];
    [browserViewController setFullBrowser:YES];
    
    [rightNavController popToRootViewControllerAnimated:NO];
    [rightNavController setViewControllers:nil animated:NO];
    [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:browserViewController, nil] animated:NO];
    
    [browserViewController release];
    NSLog(@"END MoveRightToLeft");
}

-(void)MoveRightToLeft {
    [self MoveRightToLeft:@"http://www.google.com"];
}

/* for iOS6 support */
- (NSUInteger)supportedInterfaceOrientations
{
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
    return YES;
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

#pragma mark Split View Delegate

-(void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UITabBarController *)aViewController
{
    if (aViewController.view.frame.size.width > 320) {
        
        aViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        
        NSInteger selected = [aViewController selectedIndex];
        
        [aViewController setSelectedIndex:4]; // bugfix select dernière puis reselectionne le bon.
        [aViewController setSelectedIndex:selected];

    }

}

- (void)splitViewController: (SplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Menu";
    
    NSLog(@"%@", [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers]);

    
    UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];

    [navItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    svc.popOver = pc;
    [svc setMybarButtonItem:barButtonItem];

}

- (void)splitViewController: (SplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
   
    NSLog(@"%@", [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers]);
    
    UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];
    [navItem setLeftBarButtonItem:nil animated:YES];
    
    svc.popOver = nil;
    
}

@end
