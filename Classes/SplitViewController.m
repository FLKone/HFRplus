//
//  SplitViewController.m
//  HFRplus
//
//  Created by Julien ALEXANDRE on 02/07/12.
//  Copyright (c) 2012 FLK. All rights reserved.
//

#import "SplitViewController.h"
#import "HFRplusAppDelegate.h"

@interface SplitViewController ()

@end

@implementation SplitViewController
@synthesize popOver, mybarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initWithNibName");
        
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
    
    UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];

    [navItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    svc.popOver = pc;
    [svc setMybarButtonItem:barButtonItem];


}

- (void)splitViewController: (SplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {    
   
    UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];
    [navItem setLeftBarButtonItem:nil animated:YES];
    
    svc.popOver = nil;
    
}

@end
