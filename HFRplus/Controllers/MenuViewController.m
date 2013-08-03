//
//  MenuViewController.m
//  HFRplus
//
//  Created by Shasta on 15/06/13.
//
//

#import "MenuViewController.h"
#import "WEPopoverController.h"
#import <QuartzCore/QuartzCore.h>

@interface MenuViewController ()
- (void)setupMenuPortrait;
- (void)setupMenuLandscape;

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
    
    self.isAnimating = NO;
    
    //NSLog(@"VDL");
    //[UIColor colorWithRed:242/255.f green:144/255.f blue:27/255.f alpha:1.0f]
    //[UIFont boldSystemFontOfSize:15.0], UITextAttributeFont,
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.0f],UITextAttributeTextColor,
                                               [UIColor whiteColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-2, -1)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    //[[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.0f forBarMetrics:UIBarMetricsDefault];
    

    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setBackgroundImage:[[[UIImage imageNamed:@"pw_maze_white"] imageByApplyingAlpha:0.8] imageResizingModeTile] forBarMetrics:UIBarMetricsDefault];

    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"back_on"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back"]
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.0f], UITextAttributeTextColor,
      [UIColor whiteColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(-2, 0)], UITextAttributeTextShadowOffset,
      [UIFont boldSystemFontOfSize:12], UITextAttributeFont,
      nil]
                                                forState:UIControlStateHighlighted];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(-2, 0)], UITextAttributeTextShadowOffset,
      [UIColor colorWithRed:242/255.f green:144/255.f blue:27/255.f alpha:1.0f], UITextAttributeTextColor,
      [UIFont boldSystemFontOfSize:12], UITextAttributeFont,
      nil]
                                                forState:UIControlStateNormal];
        
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"orange_dot"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"black_dot"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"grey_dot"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"black_dot"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.25f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CAGradientLayer *bottomShadow = [[CAGradientLayer alloc] init];
    bottomShadow.frame = CGRectMake(0,0, self.view.frame.size.width, 2);
    bottomShadow.colors = [NSArray arrayWithObjects:(__bridge id)(lightColor), (__bridge id)(darkColor), nil];
    
    [self.menuView.layer addSublayer:bottomShadow];
    //self.tableView.tableFooterView = footerShadow;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        [self setupMenuPortrait];
    } else {
        [self setupMenuLandscape];
    }
    
    
    /*
    //Header shadow
    UIView *headerShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    
    CAGradientLayer *topShadow = [[[CAGradientLayer alloc] init] autorelease];
    topShadow.frame = CGRectMake(0, 0, self.view.frame.size.width, 10);
    topShadow.colors = [NSArray arrayWithObjects:(id)lightColor, (id)darkColor, nil];
    headerShadow.alpha = 0.3;
    
    [headerShadow.layer addSublayer:topShadow];
    //self.tableView.tableHeaderView = headerShadow;
    */
    
    //[self.menuView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pw_maze_black"]]];
    /*
    self.btnCategories.layer.masksToBounds = NO;
    self.btnCategories.layer.cornerRadius = 8; // if you like rounded corners
    self.btnCategories.layer.shadowOffset = CGSizeMake(0, -1);
    self.btnCategories.layer.shadowRadius = 0.5;
    self.btnCategories.layer.shadowOpacity = 0.3;
    
    self.btnFavoris.layer.masksToBounds = NO;
    self.btnFavoris.layer.cornerRadius = 8; // if you like rounded corners
    self.btnFavoris.layer.shadowOffset = CGSizeMake(0, -1);
    self.btnFavoris.layer.shadowRadius = 0.5;
    self.btnFavoris.layer.shadowOpacity = 0.3;
    */
    //self.btnCategories.layer.borderColor = [UIColor]
    
    // scrollView init
    /*
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320 * 2 + 20 * 3, 460 * 2 + 20 * 3)];
    
    int nbTab = 4;
    int x = 20, y = 20;
    _tabsViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < nbTab; i++) {
        
        UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 320, 460)];
        tabView.backgroundColor = [UIColor whiteColor];
        tabView.autoresizesSubviews = YES;
        [tabView setContentMode:UIViewContentModeScaleToFill];
        tabView.clipsToBounds = YES;
        //[tabView setUserInteractionEnabled:NO];
        
        UIView *tabtouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        tabtouchView.backgroundColor = [UIColor darkGrayColor];
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
        
        //NSLog((@"i = %d |  mod %d", i, i%2);
        
        if (i%2) {
            x = 20;
            y+= 480;
        }
        
    }
    [_scrollView addSubview:_containerView];

    _scrollView.contentSize = CGSizeMake(320 * 2 + 20 * 3, 460 * 2 + 20 * 3);
 
    CGRect scrollViewFrame = _scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / _scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / _scrollView.contentSize.height;

    
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    _scrollView.minimumZoomScale = minScale;
    _scrollView.maximumZoomScale = minScale;//0.3835f;
    _scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    
    //NSLog(@"_tabsViews %@", _tabsViews);
    
*/
    

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    


}

- (void)setupMenuPortrait {
    
    CGRect viewFrame = self.view.frame;
    
    NSLog(@"viewFrame %@", NSStringFromCGRect(viewFrame));

    if (self.popoverView.frame.origin.y == 0) {
        self.popoverView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    }
    else
    {
        self.popoverView.frame = CGRectMake(0, viewFrame.size.height, viewFrame.size.width, viewFrame.size.height);
    }
    
    self.forumsController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    self.favoritesController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    self.searchController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    self.messagesController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    
    NSLog(@"popoverView %@", NSStringFromCGRect(self.popoverView.frame));
    NSLog(@"forumsController %@", NSStringFromCGRect(self.forumsController.view.frame));

    //self.btnCategories.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}

- (void)setupMenuLandscape {
    CGRect viewFrame = self.view.frame;
    
    NSLog(@"viewFrame %@", NSStringFromCGRect(viewFrame));
    
    if (self.popoverView.frame.origin.y == 0) {
        self.popoverView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
    }
    else
    {
        self.popoverView.frame = CGRectMake(0, viewFrame.size.width, viewFrame.size.height, viewFrame.size.width);
    }
    
    self.forumsController.view.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
    self.favoritesController.view.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
    self.searchController.view.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
    self.messagesController.view.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);

    NSLog(@"popoverView %@", NSStringFromCGRect(self.popoverView.frame));
    NSLog(@"forumsController %@", NSStringFromCGRect(self.forumsController.view.frame));
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //NSLog(@"will %f %f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y);
    
    if((fromInterfaceOrientation == UIDeviceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIDeviceOrientationLandscapeRight)){
        [self setupMenuPortrait];
        
    } else  if((fromInterfaceOrientation == UIDeviceOrientationPortrait) || (fromInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown)){
        [self setupMenuLandscape];
        
    }
    
    
    NSLog(@"viewFrame %@", NSStringFromCGRect(self.popoverView.frame));
    NSLog(@"viewFrame %d", self.popoverView.subviews.count);

}
- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"viewDidAppear %d", animated);
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int tab = [[defaults stringForKey:@"default_tab"] integerValue];
    
	switch (tab) {
        case 1:
            [self.btnFavoris sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
            
        default:
            [self.btnCategories sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
    }
    */
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
                         
                         //NSLog(@"offset %@", NSStringFromCGPoint(newOffset));
                         
                         
                         _scrollView.maximumZoomScale = 1;
                         _scrollView.zoomScale = 1;
                         _scrollView.contentOffset = newOffset;
                         [view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         
                         //NSLog(@"finish");
                     }];

}

-(void)oneTap:(UITapGestureRecognizer *)sender {
    //NSLog(@"oneTap %@", sender.view);
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

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 4; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 23; // ImageSize/2  == 62 / 2 == 31 pixels 46/2 = 23
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 20;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}


- (IBAction)switchBtn:(MenuButton *)sender forEvent:(UIEvent *)event {
    //NSLog(@"switchBtn %d", self.isAnimating);

    NSLog(@"_popoverView.frame %@", NSStringFromCGRect(_popoverView.frame));
    //return;
    
    if (self.isAnimating) {
        //NSLog(@"isAnimating CANCEL ANIMATION");
        return;
        //[_popoverView.layer removeAllAnimations];
    }
    
    BOOL add = NO;

    // Statut du bouton switch-like on/off
    if ([sender isSelected]) {
        [sender setHighlighted:NO];
        [sender setSelected:NO];
    }
    else
    {
        add = YES;
        [sender setHighlighted:NO];
        [sender setSelected:YES];
    }
    
    //NSLog(@"sender      %@", sender);
    //NSLog(@"_activeMenu %@", _activeMenu);
    
    //  Desactiver le bouton actif //TODO
    if (_activeMenu) {
        //NSLog(@"================ desactiver ancien");
        [_activeMenu setHighlighted:NO];
        [_activeMenu setSelected:NO];
        
        
        float delay = 0.f;
        
        //if ([_activeMenu isSelected]) {
            //NSLog(@"desactiver ancien");
            //[_activeMenu sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            //NSLog(@"_activeMenu %@", _activeMenu);
            
            
            
            CGRect currentFrame = _popoverView.frame;
            
            currentFrame.origin.y = [[[[UIApplication sharedApplication] keyWindow] screen] bounds].size.height;
        
            self.isAnimating = YES;
            [UIView animateWithDuration:0.100 delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 //uncomment this and comment out the other if you want to move UIView_2 down to show UIView_1
                                 //UIView_2.frame = uiview2_translated_rect;
                                 
                                 _popoverView.frame = currentFrame;
                             } completion:^(BOOL finished) {
                                 
                                 _activeMenu = nil;
                                 
                                 [_activeController.view removeFromSuperview];
                                 self.isAnimating = NO;
                                 //NSLog(@"REMOVE isAnimating %d", self.isAnimating);
                                 
                                 [self showTool:sender];
                             }];
            
            
            delay = 0.2f;
            
        //}
    }
    else
    {
                
        [self showTool:sender];
    }
    
    
    //NSLog(@"END STCH");
}


- (void)showTool:(MenuButton *)sender {
    
    if (![sender isSelected]) {
        return;
    }
    
    _activeMenu = sender;

    NSLog(@"_popoverView.frame %@", NSStringFromCGRect(_popoverView.frame));
    
    CGRect currentFrame = _popoverView.frame;
    currentFrame.origin.y = [[[[UIApplication sharedApplication] keyWindow] screen] bounds].size.height;
    _popoverView.frame = currentFrame;
    [_popoverView setNeedsDisplay];
        NSLog(@"_popoverView.frame %@", NSStringFromCGRect(_popoverView.frame));
    
    
    //return;
    if (sender == self.btnCategories) {
        //NSLog(@"== btnCategories");
        
        CGRect currentFrame = _popoverView.frame;
        currentFrame.origin.y = 0;
        currentFrame.origin.x = 0;

        self.isAnimating = YES;
        [UIView animateWithDuration:0.100 delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //NSLog(@"START ANIMATION CATEGORIES");

                             
                             UINavigationController *navigationController;
                             
                             if (!_forumsController) {
                                 ForumsTableViewController *forumsViewController = [[ForumsTableViewController alloc] initWithNibName:@"ForumsTableViewController" bundle:nil];
                                 navigationController = [[UINavigationController alloc] initWithRootViewController:forumsViewController];
                                 _forumsController = navigationController;
                                 [self addChildViewController:_forumsController];
                             }
                             else
                                 navigationController = _forumsController;
                             
                             [navigationController didMoveToParentViewController:self];
                             [_popoverView addSubview:navigationController.view];
                             _activeController = navigationController;
                             
                             _popoverView.frame = currentFrame;
                             
                             
                         } completion:^(BOOL finished) {
                             self.isAnimating = NO;
                             //NSLog(@"ADD isAnimating %d", self.isAnimating);
                         }];
    }
    else if (sender == self.btnFavoris) {
        //NSLog(@"== btnFavoris");
        
        CGRect currentFrame = _popoverView.frame;
        currentFrame.origin.y = 0;
        currentFrame.origin.x = 0;

        self.isAnimating = YES;
        [UIView animateWithDuration:0.100 delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //NSLog(@"START ANIMATION FAVORIS");
                                                          
                             UINavigationController *navigationController;
                             
                             if (!_favoritesController) {
                                 FavoritesTableViewController *favoritesViewController = [[FavoritesTableViewController alloc] initWithNibName:@"FavoritesTableViewController" bundle:nil];
                                 navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
                                 _favoritesController = navigationController;
                                 [self addChildViewController:_favoritesController];
                             }
                             else
                                 navigationController = _favoritesController;
                             
                             [navigationController didMoveToParentViewController:self];
                             [_popoverView addSubview:navigationController.view];
                             _activeController = navigationController;
                             
                             _popoverView.frame = currentFrame;
                             
                         } completion:^(BOOL finished) {
                             self.isAnimating = NO;
                             //NSLog(@"ADD isAnimating %d", self.isAnimating);
                         }];
        
    }
    else if (sender == self.btnSearch) {
        //NSLog(@"== btnSearch");
        
        CGRect currentFrame = _popoverView.frame;
        currentFrame.origin.y = 0;
        currentFrame.origin.x = 0;
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.200 delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //NSLog(@"START ANIMATION SEARCH");
                             
                             UINavigationController *navigationController;
                             
                             if (!_searchController) {
                                 HFRSearchViewController *searchViewController = [[HFRSearchViewController alloc] initWithNibName:@"HFRSearchViewController" bundle:nil];
                                 navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
                                 _searchController = navigationController;
                                 [self addChildViewController:_searchController];
                             }
                             else
                                 navigationController = _searchController;
                             
                             
                             [navigationController didMoveToParentViewController:self];
                             [_popoverView addSubview:navigationController.view];
                             _activeController = navigationController;
                             
                             _popoverView.frame = currentFrame;
                             
                         } completion:^(BOOL finished) {
                             self.isAnimating = NO;
                             //NSLog(@"ADD isAnimating %d", self.isAnimating);
                         }];
        
    }
    else if (sender == self.btnMessages) {
        //NSLog(@"== btnMessages");
        
        CGRect currentFrame = _popoverView.frame;
        currentFrame.origin.y = 0;
        currentFrame.origin.x = 0;

        self.isAnimating = YES;
        [UIView animateWithDuration:0.200 delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //NSLog(@"START ANIMATION MP");
                             
                             UINavigationController *navigationController;
                             
                             if (!_messagesController) {
                                 HFRMPViewController *messagesViewController = [[HFRMPViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
                                 navigationController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
                                 _messagesController = navigationController;
                                 [self addChildViewController:_messagesController];
                             }
                             else
                                 navigationController = _messagesController;
                             
                             
                             [navigationController didMoveToParentViewController:self];
                             [_popoverView addSubview:navigationController.view];
                             _activeController = navigationController;
                             
                             _popoverView.frame = currentFrame;
                             
                         } completion:^(BOOL finished) {
                             self.isAnimating = NO;
                             //NSLog(@"ADD isAnimating %d", self.isAnimating);
                         }];
        
    }
    else if (sender == self.btnTabs) {
        NSLog(@"== btnTabs");
        
        CGRect scrollViewFrame = _scrollView.frame;
        CGSize cz = CGSizeMake(320 * 2 + 20 * 3, 460 * 2 + 20 * 3);
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
                    //NSLog(@"[view subviews] %@", [view subviews]);
                    
                    UIView* tapView = [[view subviews] objectAtIndex:1];
                    if (tapView.alpha == 0) {
                        //NSLog(@"sds");
                        tapView.alpha = .8;
                    }
                }
            }
            [UIView commitAnimations];
        }
    }
    
}

- (void)loadTab:(id)viewController
{
    //NSLog(@"loadTab %@", viewController);
    
    if ([[_tabsViews objectAtIndex:0] subviews].count == 2) {
        [_navigationTab1Controller removeFromParentViewController];
        [_navigationTab1Controller.view removeFromSuperview];
    }
    
    _navigationTab1Controller = [[UINavigationController alloc] initWithRootViewController:viewController];
    //[_navigationTab1Controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_dot"] forBarMetrics:UIBarMetricsDefault];
    

    


    [self addChildViewController:_navigationTab1Controller];
    [_navigationTab1Controller didMoveToParentViewController:self];

    //NSLog(@"subs B %@", [[_tabsViews objectAtIndex:0] subviews]);

    _navigationTab1Controller.view.frame = ((UIView *)[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:0]).frame;
    [[_tabsViews objectAtIndex:0] insertSubview:_navigationTab1Controller.view belowSubview:[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:0]];
    [_activeMenu sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self zoomToView:[[[_tabsViews objectAtIndex:0] subviews] objectAtIndex:1]];

    
    

    //NSLog(@"subs A %@", [[_tabsViews objectAtIndex:0] subviews]);
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //NSLog(@"shouldAutorotateToInterfaceOrientation");

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

@end
