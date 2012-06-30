//
//  IdentificationViewController.m
//  HFR+
//
//  Created by Lace on 25/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HFRplusAppDelegate.h"
#import "IdentificationViewController.h"
#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"


@implementation IdentificationViewController
@synthesize delegate;
@synthesize pseudoField, passField;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//NSLog(@"viewDidLoad");
	self.title = @"Identification";

    [super viewDidLoad];
	
	//Bouton Finish
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
	
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	
}

- (void)viewDidAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	[pseudoField becomeFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.pseudoField = nil;
	self.passField = nil;
	
}


- (void)dealloc {
	//NSLog(@"dealloc IVC");
	[self viewDidUnload];
	
	self.delegate = nil;
	
    [super dealloc];
}
/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == 1 && textField.text.length > 0) {
		[textField resignFirstResponder];
		[[textField.superview viewWithTag:2] becomeFirstResponder];
	}
	
	return YES;

}
*/
-(IBAction)done:(id)sender {
	if ([sender isEqual:pseudoField] && pseudoField.text.length > 0) {
		//NSLog(@"pseudoField");
		[pseudoField resignFirstResponder];
		[passField becomeFirstResponder];
	}
	if ([sender isEqual:passField] && passField.text.length > 0 && pseudoField.text.length > 0) {
		//NSLog(@"passField");
		[passField resignFirstResponder];
		
		[self connexion];
	}	
}

-(IBAction)connexion {
	[pseudoField resignFirstResponder];
	[passField resignFirstResponder];
	
	if (passField.text.length == 0 || pseudoField.text.length == 0) {
		return;
	}
    
	//NSLog(@"connexion");
	ASIFormDataRequest  *request =  
	[[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:@"http://www.hardware.fr/membres/popupLogin.php"]] autorelease];
    [request setPostValue:pseudoField.text forKey:@"pseudo"];
    [request setPostValue:passField.text forKey:@"pwd"];
    [request setPostValue:@"send" forKey:@"action"];
    
    [request setPostValue:@"Se connecter" forKey:@"login"];
	[request startSynchronous];
	
	if (request) {
        
        
		if ([request error]) {
			//NSLog(@"localizedDescription %@", [[request error] localizedDescription]);
			//NSLog(@"responseString %@", [request responseString]);
		} else if ([request responseString]) {
			//NSLog(@"responseString %@", [request responseString]);
            
			if ([[request responseString] length] == 0) {
				//KO
				//NSLog(@"connexion KO");
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Le pseudo que vous avez saisi n'a pas été trouvé ou votre mot de passe est incorrect.\nVeuillez réessayer."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[alert release];
			}
			else {
				//NSLog(@"connexion OK");
                
				[self finishOK];
			}
		}
	}	
}

- (void)finishOK {
	[self.delegate identificationViewControllerDidFinishOK:self];	
}
- (void)finish {
	[self.delegate identificationViewControllerDidFinish:self];	
}

- (IBAction)goToCreate {
	[[HFRplusAppDelegate sharedAppDelegate] openURL:@"http://forum.hardware.fr/inscription.php"];
}
@end
