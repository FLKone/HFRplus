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

#import "TopicsTableViewController.h"
#import "FavoritesTableViewController.h"
#import "HFRMPViewController.h"
#import "TabBarController.h"

@interface SplitViewController ()

@end

@implementation SplitViewController
@synthesize popOver, mybarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSLog(@"initWithNibNameinitWithNibNameinitWithNibNameinitWithNibName");
        self.mybarButtonItem = [[UIBarButtonItem alloc] init];
        self.delegate = self;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if ([self respondsToSelector:@selector(setPresentsWithGesture:)]) {
        //[self setPresentsWithGesture:NO];
    }

//    [self setPreferredDisplayMode:UISpli];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark Split Collapsing

- (void)splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
    //NSLog(@"displayMode %ld", (long)displayMode);
    return;
        if (displayMode == UISplitViewControllerDisplayModePrimaryHidden || displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
            //NSLog(@"IN");
            UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];

            navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.displayModeButtonItem.target action:self.displayModeButtonItem.action];
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }

    
}
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    //NSLog(@"collapseSecondaryViewController");

    
    //NSLog(@"secondaryViewController %@", secondaryViewController);
    //NSLog(@"primaryViewController %@", primaryViewController);

    
    if ([secondaryViewController isKindOfClass:[DetailNavigationViewController class]]
        && [(UINavigationController *)secondaryViewController viewControllers].count > 0
        && [[(UINavigationController *)secondaryViewController viewControllers][0] isKindOfClass:[MessagesTableViewController class]]) {
        
        //NSLog(@"top VC %@", [(UINavigationController *)secondaryViewController topViewController]);
        
        for (UIViewController *vc in [(UINavigationController *)secondaryViewController viewControllers]) {
            //NSLog(@"vc");
            [(UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate].rootController selectedViewController] pushViewController:vc animated:NO];

        }
        DetailNavigationViewController *navigationController = [[DetailNavigationViewController alloc] initWithRootViewController:[[UIViewController alloc] init]];
        navigationController.delegate = navigationController;

        [[HFRplusAppDelegate sharedAppDelegate] setDetailNavigationController:navigationController];

        // If the detail controller doesn't have an item, display the primary view controller instead
        
        return YES;
    }
    
    return NO;
    
}

- (UIViewController*)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    //NSLog(@"separateSecondaryViewControllerFromPrimaryViewController");

    UITabBarController *masterVC = splitViewController.viewControllers[0];
    
    if ([(UINavigationController*)masterVC.selectedViewController viewControllers].count > 1) {
//        if ([((UINavigationController*)masterVC.selectedViewController).topViewController isKindOfClass:[MessagesTableViewController class]]) {

            NSMutableArray *arrVC = [NSMutableArray array];


            NSUInteger counti = [(UINavigationController *)masterVC.selectedViewController viewControllers].count;
            
            for (int i = 0; i < counti; i++) {
                //NSLog(@"intloop");
                if (![[(UINavigationController*)masterVC.selectedViewController topViewController] isKindOfClass:[TopicsTableViewController class]]
                    && ![[(UINavigationController*)masterVC.selectedViewController topViewController] isKindOfClass:[FavoritesTableViewController class]]) {
                    UIViewController *tmpVCC = [(UINavigationController*)masterVC.selectedViewController popViewControllerAnimated:NO];
                    [arrVC addObject:tmpVCC];
                    //NSLog(@"class %@", [tmpVCC class]);

                }
                else {
                    //NSLog(@"intloop break");
                    break;
                }
            }
        
            if (arrVC.count == 0) {
                //NSLog(@"rien a separer");
                return nil;
            }
            DetailNavigationViewController *navigationController = [[DetailNavigationViewController alloc] initWithRootViewController:[[UIViewController alloc] init]];
            navigationController.delegate = navigationController;
        
            //NSLog(@"arrVC %@", arrVC);
            [navigationController setViewControllers:[[arrVC reverseObjectEnumerator] allObjects]];
            //NSLog(@"vc.count %lu", (unsigned long)navigationController.viewControllers.count);

            navigationController.viewControllers[0].navigationItem.leftBarButtonItem = self.displayModeButtonItem;
            navigationController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
            navigationController.navigationBar.translucent = NO;
            [[[HFRplusAppDelegate sharedAppDelegate] rootController] popAllToRoot:NO];
            [[HFRplusAppDelegate sharedAppDelegate] setDetailNavigationController:navigationController];
            
            return navigationController;
//        }
//        else {
//            NSLog(@"NIL 00");
//            return nil; // Use the default implementation
//        }
    }
    else {
        //NSLog(@"NIL");
        return nil; // Use the default implementation
    }
}

/*
- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController{
    
    NSLog(@"separateSecondaryViewControllerFromPrimaryViewController primaryViewController %@", primaryViewController);
    return nil;
}
 */
 /*
- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController{
   
    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
        for (UIViewController *controller in [(UINavigationController *)primaryViewController viewControllers]) {
            if ([controller isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)controller visibleViewController] isKindOfClass:[NoteViewController class]]) {
                return controller;
            }
        }
    }
    
    // No detail view present
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *detailView = [storyboard instantiateViewControllerWithIdentifier:@"detailView"];
    
    // Ensure back button is enabled
    UIViewController *controller = [detailView visibleViewController];
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    
    return detailView;
    
}
*/

#pragma mark Nav+

-(void)MoveLeftToRight {
    
    //Les deux controllers
    TabBarController *leftTabBarController = [self.viewControllers objectAtIndex:0];
    UINavigationController *rightNavController = [self.viewControllers objectAtIndex:1];
    
    [rightNavController popToRootViewControllerAnimated:YES];
    
    [rightNavController setViewControllers:[NSArray array]];
    UIViewController * uivc = [[UIViewController alloc] init];
    uivc.title = @"HFR+";
    [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:uivc, nil]];

    
    
    //Première tab > navController > msgController
    //leftTabBarController.selectedIndex = 0;
    UINavigationController *leftNavController= (UINavigationController *)leftTabBarController.selectedViewController;
    
    while (![leftNavController.topViewController isMemberOfClass:[MessagesTableViewController class]] && leftNavController.viewControllers.count > 1) {
        
        [leftNavController popViewControllerAnimated:NO];
    }
    
    
    if ([leftNavController.topViewController isMemberOfClass:[MessagesTableViewController class]]) {
        MessagesTableViewController *leftMessageController = (MessagesTableViewController *)leftNavController.topViewController;
        
        NSLog(@"old url  %@", leftMessageController.currentUrl);
        NSLog(@"old lastStringFlagTopic %@", leftMessageController.lastStringFlagTopic);
        
        NSString *theUrl = leftMessageController.currentUrl;
        if (leftMessageController.lastStringFlagTopic) {
            theUrl = [theUrl stringByAppendingString:leftMessageController.lastStringFlagTopic];

        }
        
        [leftNavController popViewControllerAnimated:YES];
        
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:theUrl];
        [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:aView, nil] animated:YES];

    }

    NSLog(@"END MoveLeftToRight");
}

-(void)NavPlus:(NSString *)url {
    //Les deux controllers
    //TabBarController *leftTabBarController = [self.viewControllers objectAtIndex:0];
    UINavigationController *rightNavController = [self.viewControllers objectAtIndex:1];
    
    //Première tab > navController
    //leftTabBarController.selectedIndex = 0;

    //on check à droite s'il y a un MessageTVC
    while (![rightNavController.topViewController isMemberOfClass:[MessagesTableViewController class]]) {
        
        [rightNavController popViewControllerAnimated:NO];
        
        if (rightNavController.viewControllers.count == 1) {
            break;
        }
    }
    
    //on a un MessageTVC à droite
    if ([rightNavController.topViewController isMemberOfClass:[MessagesTableViewController class]]) {
        [self MoveRightToLeft:url];
    }
    else
    {
        BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithURL:url];
        [browserViewController setFullBrowser:YES];
        
        [rightNavController popToRootViewControllerAnimated:NO];
        [rightNavController setViewControllers:[NSArray array] animated:NO];
        [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:browserViewController, nil] animated:NO];
        
    }
    
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
    while (![rightNavController.topViewController isMemberOfClass:[MessagesTableViewController class]]) {
        
        [rightNavController popViewControllerAnimated:NO];
    }
    
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
    
    NSLog(@"old url  %@", rightMessageController.currentUrl);
    NSLog(@"old lastStringFlagTopic %@", rightMessageController.lastStringFlagTopic);
    
    NSString *theUrl = rightMessageController.currentUrl;
    if (rightMessageController.lastStringFlagTopic) {
        theUrl = [theUrl stringByAppendingString:rightMessageController.lastStringFlagTopic];
    }
    
    MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:theUrl];
    [leftNavController pushViewController:aView animated:YES];
    
    BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithURL:url];
    [browserViewController setFullBrowser:YES];
    
    [rightNavController popToRootViewControllerAnimated:NO];
    [rightNavController setViewControllers:[NSArray array] animated:NO];
    [rightNavController setViewControllers:[NSMutableArray arrayWithObjects:browserViewController, nil] animated:NO];
    
    NSLog(@"END MoveRightToLeft");
}

-(void)MoveRightToLeft {
    [self MoveRightToLeft:@"http://www.google.com"];
}

/* for iOS6 support */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    NSLog(@"willPresentViewController");
    
    if (aViewController.view.frame.size.width > 320) {
        
        aViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        
        NSInteger selected = [aViewController selectedIndex];
        
        [aViewController setSelectedIndex:4]; // bugfix select dernière puis reselectionne le bon.
        [aViewController setSelectedIndex:selected];

    }

}

- (void)splitViewController: (SplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    NSLog(@"willHideViewController");

    barButtonItem.title = @"Menu";
    
    //NSLog(@"%@", [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers]);

    if (![self respondsToSelector:@selector(displayModeButtonItem)]) {
        NSLog(@"iOS6 iOS6 iOS6 ");

        UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];
        
        [navItem setLeftBarButtonItem:barButtonItem animated:YES];
        [navItem setLeftItemsSupplementBackButton:YES];
        
        svc.popOver = pc;
        [svc setMybarButtonItem:barButtonItem];

    }
    else {
        
        svc.popOver = pc;

        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = self.displayModeButtonItem;
        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;

    }

}

- (void)splitViewController: (SplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
   
    NSLog(@"willShowViewController");

    //NSLog(@"%@", [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers]);
    
    if (![self respondsToSelector:@selector(displayModeButtonItem)]) {
        NSLog(@"iOS6 iOS6 iOS6 ");
        UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];
        [navItem setLeftBarButtonItem:nil animated:YES];
        
        svc.popOver = nil;
    }
}

@end
