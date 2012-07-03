//
//  MessageDetailViewController.m
//  HFR+
//
//  Created by Lace on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HFRplusAppDelegate.h"

#import "MessageDetailViewController.h"
#import "MessagesTableViewController.h"
#import "RangeOfCharacters.h"
//#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"


#import "LinkItem.h"

@implementation MessageDetailViewController
@synthesize messageView, messageAuthor, messageDate, authorAvatar, messageTitle, messageTitleString;
@synthesize pageNumber, curMsg, arrayData;
@synthesize parent, defaultTintColor, messagesTableViewController;
@synthesize toolbarBtn, quoteBtn, editBtn, actionBtn, arrayAction, styleAlert;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//NSLog(@"initWithNibName");
		
		self.arrayAction = [[NSMutableArray alloc] init];
		
		self.actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																  target:self 
                                                                       action:@selector(ActionList:)];
		self.actionBtn.style = UIBarButtonItemStyleBordered;
		
		
		self.quoteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
																target:self 
																action:@selector(QuoteMessage)];
		self.quoteBtn.style = UIBarButtonItemStyleBordered;

		self.editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																target:self 
																action:@selector(EditMessage)];
		self.editBtn.style = UIBarButtonItemStyleBordered;
		
		
		
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView;
	
	// Before we show this view make sure the segmentedControl matches the nav bar style
	//if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
	//	self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque)
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        segmentedControl.tintColor = defaultTintColor;
    }
    else {
        segmentedControl.tintColor = [UIColor colorWithRed:144/255.f green:152/255.f blue:159/255.f alpha:0.51];

    }
}

-(void)setupData
{
	//NSLog(@"curmsg");
	//NSLog(@"curmsg %d - arraydata %d", curMsg, arrayData.count);
	
	if (curMsg > 0) {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:0];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];

	}

	
	if(curMsg < arrayData.count - 1)
	{
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:1];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
		
	}	
	
	[[self.parent messagesWebView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='%@';", [[arrayData objectAtIndex:curMsg] postID]]];
	
	
	//<link type='text/css' rel='stylesheet' href='style-max-land.css' media='only screen and (orientation:landscape)'/>\
	//<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=0;' />\

	NSString *HTMLString = [NSString stringWithFormat:@"<html><head><link type='text/css' rel='stylesheet' href='style-max.css' />\
							<meta name='viewport' content='width=320, initial-scale=1.0' />\
							</head><body><div class='bunselected' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'>%@</div></body></html><script type='text/javascript'>\
							function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; } function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; } function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}} </script>", 	
							[[arrayData objectAtIndex:curMsg] dicoHTML]];

	HTMLString = [HTMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"href=\"/forum2.php?" withString:@"href=\"http://forum.hardware.fr/forum2.php?"];
	//HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"href=\"/hfr/" withString:@"href=\"http://forum.hardware.fr/hfr/"];
	
	//Custom Internal Images
	NSString *regEx2 = @"<img src=\"http://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx2
														  withString:@"<img class=\"smileycustom\" src=\"http://forum-images.hardware.fr/$1\" />"];
	
	//Native Internal Images
	NSString *regEx0 = @"<img src=\"http://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx0
														  withString:@"|NATIVE-$1-98787687687697|"];

	//Replace Internal Images with Bundle://
	NSString *regEx4 = @"\\|NATIVE-([^-]+)-98787687687697\\|";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx4
														  withString:@"<img src='$1' />"];
	
	//NSLog(@"HTMLString: %@", HTMLString);
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	
	//NSLog(@"baseURL: %@", baseURL);

	[messageView loadHTMLString:HTMLString baseURL:baseURL];
	
	[messageView setUserInteractionEnabled:YES];
	
	//[HTMLString release];
	
	[messageDate setText:(NSString *)[[arrayData objectAtIndex:curMsg] messageDate]];
	[messageAuthor setText:[[arrayData objectAtIndex:curMsg] name]];

	//NSLog(@"avat: %@", [[arrayData objectAtIndex:curMsg] imageUrl]);

	//NSString* imageURL = @"http://theurl.com/image.gif";

	
	if ([[arrayData objectAtIndex:curMsg] imageUI]) {

		[authorAvatar setImage:[UIImage imageWithContentsOfFile:[[arrayData objectAtIndex:curMsg] imageUI]]];

		
	}
	else {
		[authorAvatar setImage:[UIImage imageNamed:@"avatar_male_gray_on_light_48x48.png"]];
	}
	
	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];

	if([[arrayData objectAtIndex:curMsg] urlEdit]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, editBtn, actionBtn, nil] animated:NO];
		
	}
	else if([[arrayData objectAtIndex:curMsg] urlQuote]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, quoteBtn, actionBtn, nil] animated:NO];
	}
	else {
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, actionBtn, nil] animated:NO];
	}
	
	if(self.parent.navigationItem.rightBarButtonItem.enabled) {
		quoteBtn.enabled = YES;		
	}
	else {
		quoteBtn.enabled = NO;	
		if([[arrayData objectAtIndex:curMsg] urlEdit]){
			actionBtn.enabled = NO;
		}
		else {
			actionBtn.enabled = YES;
		}

	}

	[flexItem release];
	
}

- (void)viewDidAppear:(BOOL)animated
{
	//NSLog(@"MDV viewDidAppear");	
	
    [super viewDidAppear:animated];
	self.parent.isAnimating = NO;
	
	[self setupData];

}

- (void)viewDidDisappear:(BOOL)animated
{
	//NSLog(@"MDV viewDidDisappear");	
	
    [super viewDidDisappear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.styleAlert = [[UIActionSheet alloc] init];
	
	// "Segmented" control to the right
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"up.png"],
											 [UIImage imageNamed:@"down.png"],
											 nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
		segmentedControl.frame = CGRectMake(0, 0, 90, 24);
	}
	else {
		segmentedControl.frame = CGRectMake(0, 0, 90, 30);
	}	
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;

	defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
	
    [segmentBarItem release];
	
	[messageTitle setText:self.messageTitleString];	


}
	 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if ([enabled isEqualToString:@"all"]) {
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
	//NSLog(@"viewDidUnload MessageDetailView");
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	[self.messageView stopLoading];
	self.messageView.delegate = nil;
	self.messageView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	

	self.messageAuthor = nil;
	self.messageDate = nil;
	self.authorAvatar = nil;
	
	self.messageTitle = nil;
	
	self.toolbarBtn = nil;
}

- (void)dealloc {
	//NSLog(@"dealloc MessageDetailView");

	[self viewDidUnload];

	self.quoteBtn = nil;
	self.editBtn = nil;
	self.actionBtn = nil;
	self.arrayAction = nil;
	
    self.styleAlert = nil;
	
	self.messageTitleString = nil;
	self.arrayData = nil;

	self.parent = nil;

	self.defaultTintColor = nil;

    [super dealloc];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidStartLoad");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidFinishLoad");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"expected:%d, got:%d | url:%@", UIWebViewNavigationTypeLinkClicked, navigationType, [aRequest.URL absoluteString]);

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        if ([[aRequest.URL scheme] isEqualToString:@"file"]) {
            
            if ([[[aRequest.URL pathComponents] objectAtIndex:0] isEqualToString:@"/"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
                NSLog(@"pas la meme page / topic");
                // Navigation logic may go here. Create and push another view controller.
                
                //NSLog(@"did Select row Topics table views: %d", indexPath.row);
                
                //if (self.messagesTableViewController == nil) {
                MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                self.messagesTableViewController = aView;
                [aView release];
                //}
                
                
                //setup the URL
                self.messagesTableViewController.topicName = @"";	
                self.messagesTableViewController.isViewed = YES;	
                
                //NSLog(@"push message liste");
                [self.navigationController pushViewController:messagesTableViewController animated:YES];  
            }
            

            return NO;
        }        
        else {
            NSURL *url = aRequest.URL;
            NSString *urlString = url.absoluteString;
            
            [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
            return NO;
        }
        
    }

    return YES;
}

- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	//NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);
	
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			curMsg -=1;
			[self setupData];
			break;
		case 1:
			//down
			curMsg +=1;			
			[self setupData];
			break;
		default:
			break;
	}
	
	[(UILabel *)self.navigationItem.titleView setText:[NSString stringWithFormat:@"Page: %d — %d/%d", self.pageNumber, curMsg + 1, arrayData.count]];

	//[parent.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:curMsg] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	
}

-(void)QuoteMessage
{
	[parent quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString] ]];
}

-(void)EditMessage
{
	[parent setEditFlagTopic:[[arrayData objectAtIndex:curMsg] postID]];
	[parent editMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString] ]];

}

-(void)ActionList:(id)sender {
	//NSLog(@"ActionList %@", [NSDate date]);

	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	if ([self.parent canBeFavorite]) {
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Ajouter aux favoris", @"actionFavoris:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	} 
	
	if([[arrayData objectAtIndex:curMsg] urlEdit] && self.parent.navigationItem.rightBarButtonItem.enabled){
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"QuoteMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	}
	else  {
		//[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Voir le profil", @"actionProfil:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		if([[arrayData objectAtIndex:curMsg] MPUrl]){
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Envoyer un message", @"actionMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		}
	}
	
	//"Citer ☑"@"Citer ☒"@"Citer ☐"	
	if([[arrayData objectAtIndex:curMsg] quoteJS] && self.parent.navigationItem.rightBarButtonItem.enabled) {
		NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
		components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
		components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		NSArray *quoteComponents = [components componentsSeparatedByString:@","];
		
		NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
		NSString *quotes = [self.parent LireCookie:nameCookie];
		
		if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☐", @"actionCiter:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];	

		}
		else {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☑", @"actionCiter:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];	

		}
		
	}
    
    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:self.arrayAction.count animated:YES];
        return;
    }
    else {
        [styleAlert release];
        styleAlert = [[UIActionSheet alloc] init];
    }
    
	for (id tmpAction in self.arrayAction) {
		[styleAlert addButtonWithTitle:[tmpAction valueForKey:@"title"]];
	}	
	
	[styleAlert addButtonWithTitle:@"Annuler"];

	styleAlert.cancelButtonIndex = self.arrayAction.count;
	styleAlert.delegate = self;

	styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { 
        [styleAlert showFromBarButtonItem:sender animated:YES];
    }
    else {
        UIBarButtonItem *Ubbi = (UIBarButtonItem *)sender;
        [styleAlert showFromRect:Ubbi.customView.frame inView:[[HFRplusAppDelegate sharedAppDelegate] window] animated:YES];
    }
    
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{

	if (buttonIndex < [self.arrayAction count]) {
		//NSLog(@"clickedButtonAtIndex %d %@", buttonIndex, [NSNumber numberWithInt:curMsg]);

		[self.parent performSelector:NSSelectorFromString([[self.arrayAction objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:[NSNumber numberWithInt:curMsg]];
	}
	
}

#pragma mark -
#pragma mark AddMessage Delegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    //NSLog(@"addMessageViewControllerDidFinish %@", self.editFlagTopic);
	
	//[self setEditFlagTopic:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
	//NSLog(@"addMessageViewControllerDidFinishOK");
	
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popToViewController:self animated:NO];
}
- (void)didPresentAlertView:(UIAlertView *)alertView
{
	
	//NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 666)) {
		usleep(200000);
		
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
	
	
}

@end