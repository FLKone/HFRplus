//
//  HFRNavigationController.m
//  HFRplus
//
//  Created by FLK on 19/07/12.
//

#import "HFRNavigationController.h"
#import "HFRplusAppDelegate.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "UINavigationBar+Helper.h"
#import "MWPhotoBrowser.h"
@interface HFRNavigationController ()

@end

@implementation HFRNavigationController

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
   // NSLog(@"viewDidLoad HFR HFR NavControll.");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userThemeDidChange)
                                                 name:kThemeChangedNotification
                                               object:nil];
    /*
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(navigationBarDoubleTap:)];
        tapRecon.numberOfTapsRequired = 2;
        [self.navigationBar addGestureRecognizer:tapRecon];

    }
     */
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (![self.topViewController isKindOfClass:[MWPhotoBrowser class]]) {
            [self.navigationBar setBottomBorderColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] height:1];
        }
  
    }

}

- (NSString *) userThemeDidChange {
    
    NSLog(@"HFR userThemeDidChange");
    
    Theme theme = [[ThemeManager sharedManager] theme];

    
    [self.navigationBar setBackgroundImage:[ThemeColors imageFromColor:[ThemeColors navBackgroundColor:theme]] forBarMetrics:UIBarMetricsDefault];
    
    if ([self.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationBar setTintColor:[ThemeColors tintColor:theme]];
    }
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors textColor:theme]}];
    
    /*
    if (theme == ThemeLight) {
        [self.navigationBar setBarStyle:UIBarStyleDefault];
    }
    else {
        [self.navigationBar setBarStyle:UIBarStyleBlack];
    }
    */
    
    [self.navigationBar setNeedsDisplay];
    
    [self.topViewController viewWillAppear:NO];

    return @"";
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
}

- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer {
    NSLog(@"navigationBarDoubleTapnavigationBarDoubleTap");
    [[ThemeManager sharedManager] switchTheme];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [ThemeColors statusBarStyle:[[ThemeManager sharedManager] theme]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
	
	if (![enabled isEqualToString:@"none"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

/* for iOS6 support */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //NSLog(@"supportedInterfaceOrientations");
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"none"]) {
        return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (BOOL)shouldAutorotate
{
   // NSLog(@"shouldAutorotate %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"]);

    return YES;
}


@end
