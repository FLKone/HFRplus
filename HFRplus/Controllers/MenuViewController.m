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
    [_btnFavoris release];
    [_btnSearch release];
    [super dealloc];
}
- (IBAction)switchBtn:(MenuButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"switchBtn");
    
    BOOL add = NO;
    
    
    // Statut du bouton switch-like on/off
    if ([sender isSelected]) {
        [sender setHighlighted:NO];
        [sender setSelected:NO];
        //_activeMenu = nil;
    }
    else
    {
        add = YES;
        [sender setHighlighted:NO];
        [sender setSelected:YES];
        //_activeMenu = sender;
    }
    
    NSLog(@"sender      %@", sender);
    NSLog(@"_activeMenu %@", _activeMenu);    
    
    //  Desactiver le bouton actif //TODO
    if (_activeMenu && sender != _activeMenu) {
        NSLog(@"desactiver ancien");
        [_activeMenu sendActionsForControlEvents:UIControlEventTouchUpInside];

    }
    
    // Action pour chaque bouton
    if (!add) {
        NSLog(@"REMOVE");
        
        _activeMenu = nil;
        
        [_activeController.view removeFromSuperview];
        //[_activeController removeFromParentViewController];
        
    }
    else
    {
        _activeMenu = sender;
        UINavigationController *navigationController;
        
        if (sender == self.btnCategories) {
            NSLog(@"== btnCategories");
            
            if (!_forumsController) {
                ForumsTableViewController *forumsViewController = [[ForumsTableViewController alloc] initWithNibName:@"ForumsTableViewController" bundle:nil];
                navigationController = [[UINavigationController alloc] initWithRootViewController:forumsViewController];
                [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];
                
                _forumsController = navigationController;
                
                [self addChildViewController:_forumsController];
            }
            else
                navigationController = _forumsController;

        }
        else if (sender == self.btnFavoris) {
            NSLog(@"== btnFavoris");
            
            if (!_favoritesController) {            
                FavoritesTableViewController *favoritesViewController = [[FavoritesTableViewController alloc] initWithNibName:@"FavoritesTableViewController" bundle:nil];
                navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
                [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];

                _favoritesController = navigationController;
                
                [self addChildViewController:_favoritesController];
            }
            else
                navigationController = _favoritesController;
        }
        else if (sender == self.btnSearch) {
            NSLog(@"== btnSearch");
            
            if (!_searchController) {
                HFRSearchViewController *searchViewController = [[HFRSearchViewController alloc] initWithNibName:@"HFRSearchViewController" bundle:nil];
                navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
                [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];
                
                _searchController = navigationController;
                
                [self addChildViewController:_searchController];
            }
            else
                navigationController = _searchController;
        }
        else {
            navigationController = [[UINavigationController alloc] init];
        }
        
        
        [navigationController didMoveToParentViewController:self];
        [_popoverView addSubview:navigationController.view];
        _activeController = navigationController;
    }

    /*
     //navigationController.navigationBar.alpha = .95;
     //navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
     //navigationController.navigationBar.translucent = YES;
     */
    
    
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
