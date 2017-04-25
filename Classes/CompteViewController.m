//
//  CompteViewController.m
//  HFRplus
//
//  Created by FLK on 12/08/10.
//

#import "CompteViewController.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"
#import "IdentificationViewController.h"
#import "HFRplusAppDelegate.h"
#import "RangeOfCharacters.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "Constants.h"

@implementation CompteViewController
@synthesize compteView, profilBtn, loginView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mon Compte";
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //On check si il est logged
    [self checkLogin];
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}

-(void)setThemeColors:(Theme)theme{
    if ([self.view respondsToSelector:@selector(setTintColor:)]) {
        self.view.tintColor = [ThemeColors tintColor:theme];
    }
    
    self.view.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.loginView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.compteView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.loadingLabel.textColor = [ThemeColors cellTextColor:theme];
    [self.loadingIndicator setColor:[ThemeColors cellTextColor:theme]];
}


- (void)checkLogin {
    //NSLog(@"checkLogin");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/editprofil.php?config=hfr.inc", [k ForumURL]]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setUseCookiePersistence:YES];
    [request startAsynchronous];
    //NSLog(@"checkLogin fin");
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"requestFinished");
    
    // Use when fetching text data
    NSString *responseString = [request responseString];
    //NSLog(@"finish %@", [request responseString]);
    
    NSString *regularExpressionString = @".*<td class=\"profilCase3\">([^<]+)</td>.*";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:responseString];
    
    if (myStringMatchesRegEx) {
        //NSLog(@"finish OK");
        
        //OK
        
        [[self profilBtn] setTitle:[NSString stringWithFormat:@"Profil: %@", [[[responseString stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByDecodingXMLEntities]] forState:UIControlStateNormal];
        [self.compteView setHidden:NO];
        [self.loginView setHidden:YES];
        
        [[HFRplusAppDelegate sharedAppDelegate] login];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
        
    }
    else {
        //KO need to LOG IN
        
        //NSLog(@"finish KO");
        [self login];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
}

- (IBAction)logout {
    //NSLog(@"logout");
    
    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];
    
    for (NSHTTPCookie *aCookie in cookies) {
        //NSLog(@"%@", aCookie);
        
        [cookShared deleteCookie:aCookie];
    }
    
    //NSLog(@"logout: %@", [request responseString]);
    [self.compteView setHidden:YES];
    [self.loginView setHidden:NO];
    
    [[HFRplusAppDelegate sharedAppDelegate] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
}

- (IBAction)login {
    
    
    // Create the root view controller for the navigation controller
    // The new view controller configures a Cancel and Done button for the
    // navigation bar.
    IdentificationViewController *identificationController = [[IdentificationViewController alloc]
                                                              initWithNibName:@"IdentificationViewController" bundle:nil];
    identificationController.delegate = self;
    identificationController.view.backgroundColor = [ThemeColors greyBackgroundColor:[[ThemeManager sharedManager] theme]];
    
    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                    initWithRootViewController:identificationController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    [self.loginView setHidden:YES];
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
}

- (void)identificationViewControllerDidFinish:(IdentificationViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
    [self.compteView setHidden:YES];
    [self.loginView setHidden:NO];
    
}

- (void)identificationViewControllerDidFinishOK:(IdentificationViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
    [self checkLogin];
}

- (IBAction)goToProfil {
    [[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithString:[NSString stringWithFormat:@"%@/user/editprofil.php", [k ForumURL]]]];
}

- (void)viewDidUnload {
    //NSLog(@"viewDidUnload");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.compteView = nil;
    self.loginView = nil;
    self.profilBtn = nil;
}


- (void)dealloc {
    //NSLog(@"dealloc CVC");
    [self viewDidUnload];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
