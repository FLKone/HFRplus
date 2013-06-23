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
    
    NSLog(@"VDL");
    
    // scrollView init
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320 * 2 + 20 * 3, 436 * 2 + 20 * 3)];
    
    
    int nbTab = 4;
    int x = 20, y = 20;
    _tabsViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < nbTab; i++) {
        
        UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 320, 436)];
        tabView.backgroundColor = [UIColor redColor];
        tabView.autoresizesSubviews = YES;
        [tabView setContentMode:UIViewContentModeScaleToFill];
        tabView.clipsToBounds = YES;
        //[tabView setUserInteractionEnabled:NO];
        
        UIView *tabtouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 436)];
        tabtouchView.backgroundColor = [UIColor blueColor];
        tabtouchView.alpha = .8;
        tabtouchView.tag = i+1;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [tabtouchView addGestureRecognizer:singleTap];
        
        [tabView addSubview:tabtouchView];
        
        [_containerView addSubview:tabView];
        [_tabsViews addObject:tabView];
        
        x += 340;
        
        NSLog(@"i = %d |  mod %d", i, i%2);
        
        if (i%2) {
            x = 20;
            y+= 456;
        }
        
    }
    [_scrollView addSubview:_containerView];

    _scrollView.contentSize = CGSizeMake(320 * 2 + 20 * 3, 436 * 2 + 20 * 3);
 
    CGRect scrollViewFrame = _scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / _scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / _scrollView.contentSize.height;

    
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    _scrollView.minimumZoomScale = minScale;
    _scrollView.maximumZoomScale = minScale;//0.3835f;
    _scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    
    //NSLog(@"_tabsViews %@", _tabsViews);

}
-(void)zoomToView:(UIView *)view {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGPoint newOffset;
                         newOffset.x = [view superview].frame.origin.x;
                         newOffset.y = [view superview].frame.origin.y;
                         
                         newOffset.x += _containerView.frame.origin.x;
                         newOffset.y += _containerView.frame.origin.y;
                         
                         NSLog(@"offset %@", NSStringFromCGPoint(newOffset));
                         
                         
                         _scrollView.maximumZoomScale = 1;
                         _scrollView.zoomScale = 1;
                         _scrollView.contentOffset = newOffset;
                         [view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         
                         NSLog(@"finish");
                     }];

}

-(void)oneTap:(UITapGestureRecognizer *)sender {
    NSLog(@"oneTap %@", sender.view);
    [self zoomToView:sender.view];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _containerView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return _containerView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchBtn:(MenuButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"switchBtn");
    
    NSLog(@"_tabsViews %@", _tabsViews);

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
        [_popoverView setHidden:YES];

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
            
            //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            //[navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];
            //[self addChildViewController:navigationController];
            
            //NSLog(@"subs B %@", [[_tabsViews objectAtIndex:0] subviews]);
            
            //[[_tabsViews objectAtIndex:0] insertSubview:_forumsController.view belowSubview:[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:0]];
            
            
            [navigationController didMoveToParentViewController:self];
            [_popoverView addSubview:navigationController.view];
            _activeController = navigationController;
            [_popoverView setHidden:NO];

        }
        else if (sender == self.btnFavoris) {
            NSLog(@"== btnFavoris");
            
            if (!_favoritesController) {            
                FavoritesTableViewController *favoritesViewController = [[FavoritesTableViewController alloc] initWithNibName:@"FavoritesTableViewController" bundle:nil];
                navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
                [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];

                _favoritesController = navigationController;
                
                
                [self addChildViewController:_favoritesController];
                
                //[[_tabsViews objectAtIndex:0] addSubview:navigationController.view];

            }
            else
                navigationController = _favoritesController;
            
            [navigationController didMoveToParentViewController:self];
            [_popoverView addSubview:navigationController.view];
            _activeController = navigationController;
            [_popoverView setHidden:NO];
            
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
            
            [navigationController didMoveToParentViewController:self];
            [_popoverView addSubview:navigationController.view];
            _activeController = navigationController;
            [_popoverView setHidden:NO];
            
        }
        else if (sender == self.btnTabs) {
            NSLog(@"== btnSearch");
            
            CGRect scrollViewFrame = _scrollView.frame;
            CGSize cz = CGSizeMake(320 * 2 + 20 * 3, 436 * 2 + 20 * 3);
            CGFloat scaleWidth = scrollViewFrame.size.width / cz.width;
            CGFloat scaleHeight = scrollViewFrame.size.height / cz.height;
            
            CGFloat minScale = MIN(scaleWidth, scaleHeight);
            if (_scrollView.zoomScale != minScale) {
                    
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration: .5];
                _scrollView.maximumZoomScale = minScale;
                _scrollView.zoomScale = minScale;
                _scrollView.contentOffset = CGPointMake(0, 0);
                
                for (UIView *view in _tabsViews) {
                    if ([view subviews].count == 2) {
                        NSLog(@"[view subviews] %@", [view subviews]);
                        
                        UIView* tapView = [[view subviews] objectAtIndex:1];
                        if (tapView.alpha == 0) {
                            NSLog(@"sds");
                            tapView.alpha = .8;
                        }
                    }
                }
                [UIView commitAnimations];
            }

            
            [_popoverView setHidden:YES];
            
            
        }
        
        

    }

    /*
     //navigationController.navigationBar.alpha = .95;
     //navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
     //navigationController.navigationBar.translucent = YES;
     */
    
    
}

- (void)loadTab:(id)viewController
{
    NSLog(@"loadTab %@", viewController);
    
    if ([[_tabsViews objectAtIndex:0] subviews].count == 2) {
        [_navigationTab1Controller removeFromParentViewController];
        [_navigationTab1Controller.view removeFromSuperview];
    }
    
    _navigationTab1Controller = [[UINavigationController alloc] initWithRootViewController:viewController];
    [_navigationTab1Controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];
    

    


    [self addChildViewController:_navigationTab1Controller];

    NSLog(@"subs B %@", [[_tabsViews objectAtIndex:0] subviews]);

    _navigationTab1Controller.view.frame = ((UIView *)[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:0]).frame;
    [[_tabsViews objectAtIndex:0] insertSubview:_navigationTab1Controller.view belowSubview:[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:0]];
    [self.btnTabs sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self zoomToView:[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:1]];

    
    

    NSLog(@"subs A %@", [[_tabsViews objectAtIndex:0] subviews]);
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
