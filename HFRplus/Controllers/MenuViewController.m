//
//  MenuViewController.m
//  HFRplus
//
//  Created by Shasta on 15/06/13.
//
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnCategories release];
    [_scrollView release];
    [_popoverView release];
    [super dealloc];
}
- (IBAction)switchBtn:(id)sender forEvent:(UIEvent *)event {

    // Statut du bouton switch-like on/off
    if ([(UIButton *)sender isSelected]) {
        [(UIButton *)sender setHighlighted:NO];
        [(UIButton *)sender setSelected:NO];
    }
    else
    {
        [(UIButton *)sender setHighlighted:NO];
        [(UIButton *)sender setSelected:YES];
    }
    
    //  Desactiver le bouton actif //TODO
    
    
    
    // Action pour chaque bouton
    if (sender == self.btnCategories) {
        NSLog(@"btnCategories");
        
        
        ForumsTableViewController *forumsViewController = [[ForumsTableViewController alloc]
                                                           initWithNibName:@"ForumsTableViewController" bundle:nil];
        
        // Create the navigation controller and present it modally.
        UINavigationController *navigationController = [[UINavigationController alloc]
                                                        initWithRootViewController:forumsViewController];
        
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot.png"] forBarMetrics:UIBarMetricsDefault];
        
        
        [self addChildViewController:navigationController];
        [navigationController didMoveToParentViewController:self];
        
                

        
        //[self presentModalViewController:navigationController animated:YES];
        
        //navigationController.view.frame = _popoverView.frame;
        [_popoverView addSubview:navigationController.view];
    }
    
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"shouldAutorotateToInterfaceOrientation");

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
    NSLog(@"supportedInterfaceOrientations");
    
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"all"]) {
        //NSLog(@"All");
        
		return UIInterfaceOrientationMaskAll;
	} else {
        //NSLog(@"Portrait");
        
		return UIInterfaceOrientationMaskPortrait;
	}
}

@end
