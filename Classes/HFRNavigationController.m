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
    NSLog(@"viewDidLoad HFR HFR NavControll.");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userThemeDidChange)
                                                 name:kThemeChangedNotification
                                               object:nil];
    
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(navigationBarDoubleTap:)];
    tapRecon.numberOfTapsRequired = 2;
    [self.navigationBar addGestureRecognizer:tapRecon];
    
}

- (NSString *) userThemeDidChange {
    
    NSLog(@"HFR userThemeDidChange");
    
    Theme theme = [[ThemeManager sharedManager] theme];

    
    [self.navigationBar setBackgroundImage:[ThemeColors imageFromColor:[ThemeColors navBackgroundColor:theme]] forBarMetrics:UIBarMetricsDefault];
    
    if ([self.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationBar setTintColor:[ThemeColors tintColor:theme]];
    }
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors textColor:theme]}];
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
