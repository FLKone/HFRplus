//
//  MessageDetailViewController.m
//  HFRplus
//
//  Created by FLK on 10/07/10.
//

#import "HFRplusAppDelegate.h"

#import "MessageDetailViewController.h"
#import "MessagesTableViewController.h"
#import "RangeOfCharacters.h"
//#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"

#import "UIWebView+Tools.h"

#import "LinkItem.h"

@implementation MessageDetailViewController
@synthesize messageView, messageAuthor, messageDate, authorAvatar, messageTitle, messageTitleString, messageAvatar;
@synthesize pageNumber, currentPostID;
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
		
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.actionBtn.tintColor = [UIColor whiteColor];
            self.quoteBtn.tintColor = [UIColor whiteColor];
            self.editBtn.tintColor = [UIColor whiteColor];
        }

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
        //segmentedControl.tintColor = defaultTintColor;
    }
    else {
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            segmentedControl.tintColor = [UIColor colorWithRed:144/255.f green:152/255.f blue:159/255.f alpha:0.51];
        }


    }
}

-(OrderedDictionary *)arrayData {

    return self.parent.arrayData;
}

-(void)setupData
{
    
	if ([[self arrayData] indexForKey:self.currentPostID] > 0) {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:0];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];

	}

	
	if([[self arrayData] indexForKey:self.currentPostID] < [self arrayData].count - 1)
	{
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:1];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
		
	}
    

	[[self.parent messagesWebView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='anch%@';", self.currentPostID]];

    NSString *myRawContent = [[[self arrayData] objectForKey:self.currentPostID] dicoHTML];
    
    if ([[[self arrayData] objectForKey:self.currentPostID] quotedNB]) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<a class=\"quotedhfrlink\" href=\"%@\">%@</a>", [[[self arrayData] objectForKey:self.currentPostID] quotedLINK], [[[self arrayData] objectForKey:self.currentPostID] quotedNB]]];
    }
    if ([[[self arrayData] objectForKey:self.currentPostID] editedTime ]) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<br/><p class=\"editedhfrlink\">édité par %@</p>", [[[self arrayData] objectForKey:self.currentPostID] editedTime]]];
    }
    
    NSString *customFontSize = [self userTextSizeDidChange];

    
	NSString *HTMLString = [NSString stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
                            <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">\
                            <head>\
							<meta name='viewport' content='initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=0' />\
                            <script type='text/javascript' src='jquery-2.1.1.min.js'></script>\
                            <link type='text/css' rel='stylesheet' href='style-liste.css'/>\
                            <link type='text/css' rel='stylesheet' href='style-liste-retina.css' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\
                            <style type='text/css'>\
                            %@\
                            </style>\
							</head><body><div class='bunselected maxmessage' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'><div class='message' id='1'><div class='content'><div class='right'>%@</div></div></div></div></body></html><script type='text/javascript'>\
                            document.addEventListener('DOMContentLoaded', loadedML);\
                            function loadedML() { document.location.href = 'oijlkajsdoihjlkjasdoloaded://loaded'; };\
							function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; } function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; } function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}} $('img').error(function(){\
                            $(this).attr('src', 'photoDefaultfailmini.png');}); </script>", customFontSize, myRawContent];

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
	
	[messageDate setText:(NSString *)[[[self arrayData] objectForKey:self.currentPostID] messageDate]];
	[messageAuthor setText:[[[self arrayData] objectForKey:self.currentPostID] name]];

	//NSString* imageURL = @"http://theurl.com/image.gif";

	
	if ([[[self arrayData] objectForKey:self.currentPostID] imageUI]) {

		[authorAvatar setImage:[UIImage imageWithContentsOfFile:[[[self arrayData] objectForKey:self.currentPostID] imageUI]]];

		
	}
	else {
		[authorAvatar setImage:[UIImage imageNamed:@"avatar_male_gray_on_light_48x48"]];
	}
	
	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                              target:nil
                                                                              action:nil];
    fixedItem.width = 10;
    
	if([[[self arrayData] objectForKey:self.currentPostID] urlEdit]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, editBtn, fixedItem, actionBtn, nil] animated:NO];
		
	}
	else if([[[self arrayData] objectForKey:self.currentPostID] urlQuote]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, quoteBtn, fixedItem, actionBtn, nil] animated:NO];
	}
	else {
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, actionBtn, nil] animated:NO];
	}
	
	if(self.parent.navigationItem.rightBarButtonItem.enabled) {
		quoteBtn.enabled = YES;		
	}
	else {
		quoteBtn.enabled = NO;	
		if([[[self arrayData] objectForKey:self.currentPostID] urlEdit]){
			actionBtn.enabled = NO;
		}
		else {
			actionBtn.enabled = YES;
		}

	}

	
}

- (void)viewDidAppear:(BOOL)animated
{
	//NSLog(@"MDV viewDidAppear");
	
    [super viewDidAppear:animated];
	self.parent.isAnimating = NO;
	


}

- (void)viewDidDisappear:(BOOL)animated
{
	//NSLog(@"MDV viewDidDisappear");	
	
    [super viewDidDisappear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //NSLog(@"MDV viewDidLoad");
    [super viewDidLoad];

	self.styleAlert = [[UIActionSheet alloc] init];
	
	// "Segmented" control to the right
    
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTextSizeDidChange) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
         self.toolbarBtn.frame = CGRectMake(self.toolbarBtn.frame.origin.x, self.toolbarBtn.frame.origin.y - 49, self.toolbarBtn.frame.size.width, self.toolbarBtn.frame.size.height);
         self.messageAuthor.frame = CGRectMake(self.messageAuthor.frame.origin.x, self.messageAuthor.frame.origin.y - 49, self.messageAuthor.frame.size.width, self.messageAuthor.frame.size.height);
         self.messageDate.frame = CGRectMake(self.messageDate.frame.origin.x, self.messageDate.frame.origin.y - 49, self.messageDate.frame.size.width, self.messageDate.frame.size.height);
         self.messageAvatar.frame = CGRectMake(self.messageAvatar.frame.origin.x, self.messageAvatar.frame.origin.y - 49, self.messageAvatar.frame.size.width, self.messageAvatar.frame.size.height);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.messageAuthor setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.messageDate setFont:[UIFont boldSystemFontOfSize:8.0f]];
    }
    
    UISegmentedControl *segmentedControl;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"upsmall7"],
                                                 [UIImage imageNamed:@"downsmall7"],
                                                 nil]];
    }
    else {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"upsmall"],
                                                 [UIImage imageNamed:@"downsmall"],
                                                 nil]];
    }

	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            segmentedControl.frame = CGRectMake(0, 0, 90, 24);
        }
        else {
            segmentedControl.frame = CGRectMake(0, 0, 90, 30);
        }
    }
    else
        segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;

	//defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
	
	
	[messageTitle setText:self.messageTitleString];	

    [self.messageView setBackgroundColor:[UIColor whiteColor]];
    [self.messageView hideGradientBackground];

    //[self segmentAction:self.navigationItem.rightBarButtonItem];
    
    [self setupData];
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
	
    messageAvatar = nil;
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

    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
	
	

	self.parent = nil;


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
                //}
                
                self.navigationItem.backBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                 style: UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                    self.navigationItem.backBarButtonItem.title = @" ";
                }
                
                //setup the URL
                self.messagesTableViewController.topicName = @"";	
                self.messagesTableViewController.isViewed = YES;	
                
                //NSLog(@"push message liste");
                [self.navigationController pushViewController:messagesTableViewController animated:YES];  
            }
            

            return NO;
        }
		else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
            
            NSLog(@"%@", aRequest.URL);
            
            MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", kForumURL] withString:@""]];
            self.messagesTableViewController = aView;
            
            self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                             style: UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                self.navigationItem.backBarButtonItem.title = @" ";
            }
            
            //setup the URL
            self.messagesTableViewController.topicName = @"";
            self.messagesTableViewController.isViewed = YES;
            
            [self.navigationController pushViewController:messagesTableViewController animated:YES];
            
            return NO;
        }
        else {
            NSURL *url = aRequest.URL;
            NSString *urlString = url.absoluteString;
            
            [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
            return NO;
        }
        
    }
    else if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoloaded"]) {
            [self webViewDidFinishLoadDOM];
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoadDOM {
    [self userTextSizeDidChange];

}

- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	//NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);



	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
            self.currentPostID = [[[self arrayData] previousObjectForKey:self.currentPostID] postID];
			[self setupData];
			break;
		case 1:
			//down
            self.currentPostID = [[[self arrayData] nextObjectForKey:self.currentPostID] postID];
			[self setupData];
			break;
		default:
			break;
	}
	
	[(UILabel *)self.navigationItem.titleView setText:[NSString stringWithFormat:@"Page: %d — %lu/%lu", self.pageNumber, [self.arrayData indexForKey:self.currentPostID] + 1, (unsigned long)[self arrayData].count]];


}

-(void)QuoteMessage
{
	[parent quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[[self arrayData] objectForKey:self.currentPostID] urlQuote] decodeSpanUrlFromString] ]];
}

-(void)EditMessage
{
	[parent setEditFlagTopic:self.currentPostID];
	[parent editMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[[self arrayData] objectForKey:self.currentPostID] urlEdit] decodeSpanUrlFromString] ]];

}

-(void)ActionList:(id)sender {
	//NSLog(@"ActionList %@", [NSDate date]);

	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	if ([self.parent canBeFavorite]) {
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Ajouter aux favoris", @"actionFavoris:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	} 
	
	if([[[self arrayData] objectForKey:self.currentPostID] urlEdit] && self.parent.navigationItem.rightBarButtonItem.enabled){
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"QuoteMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	}
	else  {
		//[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Voir le profil", @"actionProfil:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		if([[[self arrayData] objectForKey:self.currentPostID] MPUrl]){
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Envoyer un message", @"actionMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		}
	}
	
	//"Citer ☑"@"Citer ☒"@"Citer ☐"	
	if([[[self arrayData] objectForKey:self.currentPostID] quoteJS] && self.parent.navigationItem.rightBarButtonItem.enabled) {
		NSString *components = [[[[self arrayData] objectForKey:self.currentPostID] quoteJS] substringFromIndex:7];
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
    
    if (![self.parent isSearchInstra]) {
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Copier le lien", @"actionLink:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    }
    
    
    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:self.arrayAction.count animated:YES];
        return;
    }
    else {
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	if (buttonIndex < [self.arrayAction count]) {


        
        [self.parent performSelectorOnMainThread:NSSelectorFromString([[self.arrayAction objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:self.currentPostID waitUntilDone:NO];
        
    }
	
}

- (NSString *) userTextSizeDidChange {
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_text"] isEqualToString:@"sys"]) {

        if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
            CGFloat userFontSize = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody].pointSize;
            userFontSize = floorf(userFontSize*0.90);
            NSString *script = [NSString stringWithFormat:@"$('.message .content .right').css('cssText', 'font-size:%fpx !important');", userFontSize];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right table.code *').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right p.editedhfrlink').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            
            [self.messageView stringByEvaluatingJavaScriptFromString:script];
            
            return [NSString stringWithFormat:@".message .content .right { font-size:%fpx !important; }", userFontSize];
            
            //NSLog(@"userFontSize %@", script);
        }
    }
    return @"";
    
}


#pragma mark -
#pragma mark AddMessage Delegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    NSLog(@"addMessageViewControllerDidFinish");
	
	//[self setEditFlagTopic:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
	NSLog(@"addMessageViewControllerDidFinishOK");
	
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popToViewController:self animated:NO];
}
- (void)didPresentAlertView:(UIAlertView *)alertView
{
	
	NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 666)) {
		usleep(200000);
		
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
	
	
}

@end