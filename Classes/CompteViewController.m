//
//  CompteViewController.m
//  HFR+
//
//  Created by Shasta on 12/08/10.
//

#import "CompteViewController.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"
#import "IdentificationViewController.h"
#import "HFRplusAppDelegate.h"

@implementation CompteViewController
@synthesize compteView, profilBtn, loginView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 
	self.title = @"Mon Compte";
	
	//On check si il est logged
	[self checkLogin];
}


- (void)checkLogin {
	//NSLog(@"checkLogin");
	NSURL *url = [NSURL URLWithString:@"http://forum.hardware.fr/user/editprofil.php?config=hfr.inc"];
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
		[[self profilBtn] setTitle:[NSString stringWithFormat:@"Profil: %@", [[responseString stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] forState:UIControlStateNormal];
		[self.compteView setHidden:NO];
		[self.loginView setHidden:YES];

		[[HFRplusAppDelegate sharedAppDelegate] login];

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
	
	NSURL *url = [NSURL URLWithString:@"http://www.hardware.fr/membres/?logout=1"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUseCookiePersistence:YES];
	[request startSynchronous];
	
	if (request) {
		
		NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		NSArray *cookies = [cookShared cookies];
		
		for (NSHTTPCookie *aCookie in cookies) {
			NSLog(@"%@", aCookie);
			
			[cookShared deleteCookie:aCookie];
		}
		
		//NSLog(@"logout: %@", [request responseString]);
		[self.compteView setHidden:YES];
		[self.loginView setHidden:NO];

		[[HFRplusAppDelegate sharedAppDelegate] logout];

	}
}

- (IBAction)login {

	
	// Create the root view controller for the navigation controller
	// The new view controller configures a Cancel and Done button for the
	// navigation bar.
	IdentificationViewController *identificationController = [[IdentificationViewController alloc]
											  initWithNibName:@"IdentificationViewController" bundle:nil];
	identificationController.delegate = self;
	
	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:identificationController];
	[self presentModalViewController:navigationController animated:YES];
	[self.loginView setHidden:YES];
	
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[identificationController release];
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
	[[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithString:@"http://forum.hardware.fr/user/editprofil.php"]];
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

    [super dealloc];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
