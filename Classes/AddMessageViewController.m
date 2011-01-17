//
//  AddMessageViewController.m
//  HFR+
//
//  Created by FLK on 16/08/10.
//

#import "HFRplusAppDelegate.h"
#import "AddMessageViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import "RegexKitLite.h"

//#import "SmileFormController.h"


@implementation AddMessageViewController
@synthesize delegate, textView, arrayInputData, formSubmit, accessoryView, smileView;
@synthesize request, loadingView, requestSmile;

@synthesize lastSelectedRange, loaded;//navBar, 
@synthesize segmentControler, isDragging, textFieldSmileys, smileyArray, segmentControlerPage, smileyPage, commonTableView, usedSearchDict, usedSearchSortedArray;

@synthesize haveTitle, textFieldTitle;
@synthesize haveTo, textFieldTo;
@synthesize haveCategory, textFieldCat;
@synthesize offsetY;

/*

- (BOOL)canPerformAction: (SEL)action withSender: (id)sender {
	NSLog(@"canPerformAction %@", NSStringFromSelector(action));
	
    if (action == @selector(copy:)) return YES;
    if (action == @selector(textBold:)) return YES;
    if (action == @selector(textItalic:)) return YES;
    if (action == @selector(textUnderline:)) return YES;
    if (action == @selector(textStrike:)) return YES;
    return NO;
}
*/

#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//NSLog(@"initWithNibName add");
		
		self.arrayInputData = [[NSMutableDictionary alloc] init];
		self.smileyArray = [[NSMutableArray alloc] init];
		self.formSubmit = [[NSString alloc] init];
		
		self.loaded = NO;
		self.isDragging = NO;
		
		self.haveCategory = NO;
		self.haveTitle = NO;
		self.haveTo	= NO;
		
		self.offsetY = 0;
		
		self.usedSearchDict = [[NSMutableDictionary alloc] init];
		self.usedSearchSortedArray = [[NSMutableArray alloc] init];
		// Recherche Smileys utilises
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"usedSmilieys.plist"]];
		
		if ([fileManager fileExistsAtPath:usedSmilieys]) {
			self.usedSearchDict = [NSMutableDictionary dictionaryWithContentsOfFile:usedSmilieys];
			self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		}
		
		
		[usedSmilieys release];
		[fileManager release];
		// Recherche Smileys utilises		
		
		//NSLog(@"usedSearchDict %@", self.usedSearchDict);
		//NSLog(@"usedSearchSortedArray %@", self.usedSearchSortedArray);
		
		self.title = @"Nouv. message";
    }
    return self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidStartLoad");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidFinishLoad");
	
	NSString *jsString = [[[NSString alloc] initWithString:@""] autorelease];
	//jsString = [jsString stringByAppendingString:@"$('body').bind('touchmove', function(e){e.preventDefault()});"];
	jsString = [jsString stringByAppendingString:@"$('.button').addSwipeEvents().bind('tap', function(evt, touch) { $(this).addClass('selected'); window.location = 'oijlkajsdoihjlkjasdosmile://'+$.base64.encode(this.title); });"];
	[webView stringByEvaluatingJavaScriptFromString:jsString];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%d, got:%d | url:%@", UIWebViewNavigationTypeLinkClicked, navigationType, [aRequest.URL absoluteString]);
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		return NO;
	}
	else if (navigationType == UIWebViewNavigationTypeOther) {
		if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdosmile"]) {
			NSString *regularExpressionString = @"oijlkajsdoihjlkjasdosmile://(.*)";
			[self didSelectSmile:[[[NSString alloc] initWithData:[NSData dataFromBase64String:[[[aRequest.URL absoluteString] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] encoding:NSASCIIStringEncoding] autorelease]];
			
			return NO;
		}		
	}
	
	return YES;
}
- (void)viewDidLoad {
	//Bouton Annuler
	UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelBarItem;
	[cancelBarItem release];	
	
	//Bouton Envoyer
	UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = sendBarItem;
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	
	[sendBarItem release];	
	
	[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:0];
	[self.segmentControlerPage setWidth:40.0 forSegmentAtIndex:0];
	[self.segmentControlerPage setWidth:40.0 forSegmentAtIndex:2];	

	[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:2];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)initData { //- (void)viewDidLoad {
	//NSLog(@"viewDidLoad add");
	
   // [super viewDidLoad];
	
	[self.smileView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"smileybase" ofType:@"html"] isDirectory:NO]]];
		
	self.formSubmit = @"http://forum.hardware.fr/bddpost.php";

	 [[NSNotificationCenter defaultCenter] addObserver:self
	 selector:@selector(smileyReceived:)
	 name:@"smileyReceived" object:nil];

	self.lastSelectedRange = NSMakeRange(NSNotFound, NSNotFound);
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
	v.backgroundColor = [UIColor whiteColor];
	[self.commonTableView setTableFooterView:v];
	[v release];
	
	/*
	 
	 self.smileysWebView.layer.cornerRadius = 10;
	 [self.smileysWebView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
	 [self.smileysWebView.layer setBorderWidth: 1.0];
		
	 for (id subview in smileView.subviews)
		 if ([[subview class] isSubclassOfClass: [UIScrollView class]])
			 ((UIScrollView *)subview).bounces = NO;
	 
	 */
	
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	
	// On rajoute les menus pour le style
    UIMenuItem *textBoldItem = [[[UIMenuItem alloc] initWithTitle:@"B" action:@selector(textBold:)] autorelease];
    UIMenuItem *textItalicItem = [[[UIMenuItem alloc] initWithTitle:@"I" action:@selector(textItalic:)] autorelease];
    UIMenuItem *textUnderlineItem = [[[UIMenuItem alloc] initWithTitle:@"U" action:@selector(textUnderline:)] autorelease];
    UIMenuItem *textStrikeItem = [[[UIMenuItem alloc] initWithTitle:@"S" action:@selector(textStrike:)] autorelease];
    
	UIMenuItem *textSpoilerItem = [[[UIMenuItem alloc] initWithTitle:@"SPOILER" action:@selector(textSpoiler:)] autorelease];
    UIMenuItem *textFixeItem = [[[UIMenuItem alloc] initWithTitle:@"FIXE" action:@selector(textFixe:)] autorelease];
 //   UIMenuItem *textCppItem = [[[UIMenuItem alloc] initWithTitle:@"CPP" action:@selector(textStrike:)] autorelease];
    UIMenuItem *textLinkItem = [[[UIMenuItem alloc] initWithTitle:@"URL" action:@selector(textLink:)] autorelease];
    //UIMenuItem *textMailItem = [[[UIMenuItem alloc] initWithTitle:@"@" action:@selector(textStrike:)] autorelease];
    UIMenuItem *textImgItem = [[[UIMenuItem alloc] initWithTitle:@"IMG" action:@selector(textImg:)] autorelease];
	
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:textBoldItem, textItalicItem, textUnderlineItem, textStrikeItem,
														   textSpoilerItem, textFixeItem, textLinkItem, textImgItem, nil]];

	
	[segmentControler setEnabled:NO forSegmentAtIndex:1];		
	//[segmentControler setEnabled:NO forSegmentAtIndex:2];		

}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewWillBeginDragging");
	self.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//NSLog(@"scrollViewDidEndDragging");
	if (!decelerate) {
		self.isDragging = NO;
	} 
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidScroll");
	//self.scrollViewer.contentOffset = CGPointMake(self.scrollViewer.contentOffset.x, self.scrollViewer.contentOffset.y + 20);
	if (![self.textView isFirstResponder] && !self.isDragging) {
	//	//NSLog(@"contentOffset 1");
		self.textView.contentOffset = CGPointMake(0, self.offsetY);
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewWillBeginDecelerating");
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidEndDecelerating");
	self.isDragging = NO;
	
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
	//NSLog(@"scrollViewDidEndScrollingAnimation");
	
	//[self.textView scrollRangeToVisible:self.textView.selectedRange];
	if (![self.textView isFirstResponder] && !self.isDragging) {
	//NSLog(@"contentOffset 2");
	
		self.textView.contentOffset = CGPointMake(0, self.offsetY);
	}
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)textViewDidChange:(UITextView *)ftextView
{
	//NSLog(@"textViewDidChange");
	
	if ([ftextView text].length > 0) {
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	}
	else {
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated{
	//NSLog(@"viewWillAppear");
	[super viewWillAppear:animated];

	if(lastSelectedRange.location != NSNotFound) 
	{
		textView.selectedRange = lastSelectedRange;
	}

}

-(void)setupResponder {
	if (self.haveTo && ![[textFieldTo text] length]) {
		[textFieldTo becomeFirstResponder];
	}
	else if (self.haveTitle) {
		[textFieldTitle becomeFirstResponder];
	}
	else {
		[textView becomeFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	//NSLog(@"viewWillDisappear");
	[super viewWillDisappear:animated];
	
	[self.view endEditing:YES];

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

- (IBAction)cancel {
	//NSLog(@"cancel %@", self.formSubmit);

	if (self.smileView.alpha != 0) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2];		
		[self.smileView setAlpha:0];
		
		[self.segmentControler setAlpha:1];
		[self.segmentControlerPage setAlpha:0];		
		
		[UIView commitAnimations];	
		
		[self.textView becomeFirstResponder];
	}
	else if (self.commonTableView.alpha != 0) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2];		
		[self.commonTableView setAlpha:0];
		
		[self.segmentControler setAlpha:1];
		[self.segmentControlerPage setAlpha:0];		
		
		[UIView commitAnimations];	
		
		[self.textView becomeFirstResponder];
	}
	else {
		if ([self.textView text].length > 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention !" message:@"Vous allez perdre le contenu de votre message."
														   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", nil];
			[alert setTag:666];
			[alert show];
			[alert release];
		}
		else {
			[self.delegate addMessageViewControllerDidFinish:self];	
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1 && alertView.tag == 666) {
		[self.delegate addMessageViewControllerDidFinish:self];	
	}
}

- (IBAction)done {
	//NSLog(@"done %@", self.formSubmit);
	
	ASIFormDataRequest  *arequest =  
	[[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:self.formSubmit]] autorelease];
	//delete
	NSString *key;
	for (key in self.arrayInputData) {
		NSLog(@"POST: %@ : %@", key, [self.arrayInputData objectForKey:key]);
		if ([key isEqualToString:@"allowvisitor"] || [key isEqualToString:@"have_sondage"] || [key isEqualToString:@"sticky"] || [key isEqualToString:@"sticky_everywhere"]) {
			if ([[self.arrayInputData objectForKey:key] isEqualToString:@"1"]) {
				[arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
			}
		}
		else if ([key isEqualToString:@"delete"]) {
			
		}
		else
			[arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
	}	
	
    [arequest setPostValue:[textView text] forKey:@"content_form"];
	if (self.haveTitle) {
		[arequest setPostValue:[textFieldTitle text] forKey:@"sujet"];
	}
	if (self.haveCategory) {
		[arequest setPostValue:[textFieldCat text] forKey:@"subcat"];
	}	
	if (self.haveTo) {
		[arequest setPostValue:[textFieldTo text] forKey:@"dest"];
	}	
	[arequest startSynchronous];
	
	if (arequest) {
		if ([arequest error]) {
			//NSLog(@"error: %@", [[arequest error] localizedDescription]);

			UIAlertView *alertKO = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[[arequest error] localizedDescription]
														   delegate:self cancelButtonTitle:@"Retour" otherButtonTitles: nil];
			[alertKO show];
			[alertKO release];
		}
		else if ([arequest responseString])
		{
			NSError * error = nil;
			HTMLParser *myParser = [[HTMLParser alloc] initWithString:[arequest responseString] error:&error];

			HTMLNode * bodyNode = [myParser body]; //Find the body tag
			
			HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
			
			//NSLog(@"responseString: %@", [arequest responseString]);
			
			if ([messagesNode findChildTag:@"a"] || [messagesNode findChildTag:@"input"]) {
				UIAlertView *alertKKO = [[UIAlertView alloc] initWithTitle:nil message:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
															   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alertKKO show];
				[alertKKO release];				
			}
			else {
				UIAlertView *alertOK = [[UIAlertView alloc] initWithTitle:@"Hooray !" message:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
																  delegate:self.delegate cancelButtonTitle:nil otherButtonTitles: nil];
				[alertOK setTag:666];
				[alertOK show];

				UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				
				// Adjust the indicator so it is up a few pixels from the bottom of the alert
				indicator.center = CGPointMake(alertOK.bounds.size.width / 2, alertOK.bounds.size.height - 50);
				[indicator startAnimating];
				[alertOK addSubview:indicator];
				[indicator release];

				
				[alertOK release];
				
				[self.delegate addMessageViewControllerDidFinishOK:self];	

			}


			[myParser release];
		}
	}
	
}

- (IBAction)segmentFilterAction:(id)sender
{
	
	// The segmented control was clicked, handle it here 
	
	//NSLog(@"Segment clicked: %d", [(UISegmentedControl *)sender selectedSegmentIndex]);
	
	//[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:NO];
	if (sender == self.segmentControler) {
		switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
			case 0:
			{
				if (self.smileView.alpha == 0.0) {
					self.loaded = NO;
					[textView resignFirstResponder];
					[textFieldSmileys resignFirstResponder];
					NSRange newRange = textView.selectedRange;
					newRange.length = 0;
					textView.selectedRange = newRange;
					
					[self.smileView setHidden:NO];
					[UIView beginAnimations:nil context:nil];
					[UIView setAnimationDuration:0.2];		
					[self.smileView setAlpha:1];
					[self.commonTableView setAlpha:0];
					
					[self.segmentControler setAlpha:0];
					[self.segmentControlerPage setAlpha:1];	
					
					[UIView commitAnimations];
				}
				else {
					[UIView beginAnimations:nil context:nil];
					[UIView setAnimationDuration:0.2];		
					[self.smileView setAlpha:0];
					[UIView commitAnimations];	
					[(UISegmentedControl *)sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
					[self.textView becomeFirstResponder];
				}			
				break;
			}
			case 1:
				break;					
			default:
				break;
		}
	}
	else if (sender == self.segmentControlerPage) {
		switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {

			case 0:
				//NSLog(@"previous");
				[self loadSmileys:--self.smileyPage];	
				break;
			case 1:
			{
				//NSLog(@"smile");
				NSString *translatable = [self.smileView stringByEvaluatingJavaScriptFromString:@"$('#container').css('display');"];
				
				if ([translatable isEqualToString:@"none"]) {
					[self.smileView stringByEvaluatingJavaScriptFromString:@"$('#container').show();$('#container_ajax').html('');"];
					[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:0];
					[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:2];
					[self.segmentControlerPage setTitle:@"Annuler" forSegmentAtIndex:1];

				}
				else {
					[self cancel];
				}

				break;				
			}
					
			case 2:
				//NSLog(@"next");
				[self loadSmileys:++self.smileyPage];	
				break;					
			default:
				break;
		}
	}

	
}


#pragma mark -
#pragma mark TextView Mod

- (void) smileyReceived: (NSNotification *) notification {
	//NSLog(@"%@", notification);

	// When the accessory view button is tapped, add a suitable string to the text view.
    NSMutableString *text = [textView.text mutableCopy];
	
	//NSLog(@"%d - %d", text.length, lastSelectedRange.location);

    [text insertString:[notification object] atIndex:lastSelectedRange.location];
	
	lastSelectedRange.location += [[notification object] length];
	
    textView.text = text;
    [text release];	
	
	self.loaded = YES;
	
	[self textViewDidChange:self.textView];

}

- (void) didSelectSmile:(NSString *)smile {
	//NSLog(@"didSelectSmile");

	//STATS RECHERCHES
	// Recherche Smileys utilises
	if (self.textFieldSmileys.text.length >= 3) {
		NSNumber *val;
		if ((val = [self.usedSearchDict valueForKey:self.textFieldSmileys.text])) {
			//NSLog(@"existe %@", val);
			[self.usedSearchDict setObject:[NSNumber numberWithInt:[val intValue]+1] forKey:self.textFieldSmileys.text];
		}
		else {
			//NSLog(@"nouveau");
			[self.usedSearchDict setObject:[NSNumber numberWithInt:1] forKey:self.textFieldSmileys.text];
			
		}
		
		//NSLog(@"%@", self.usedSearchDict);
		
		NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"usedSmilieys.plist"]];
		
		[self.usedSearchDict writeToFile:usedSmilieys atomically:YES];
		
		// Recherche Smileys utilises
	}
	
	NSMutableString *text = [textView.text mutableCopy];
	
	//NSLog(@"%@ - %d - %d", smile, text.length, lastSelectedRange.location);
	
    [text insertString:smile atIndex:lastSelectedRange.location];
	
	lastSelectedRange.location += [smile length];
	lastSelectedRange.length = 0;
	
    textView.text = text;
    [text release];	
	
	
	self.loaded = YES;
	[self textViewDidChange:self.textView];
	
	
	
	NSString *jsString = [[[NSString alloc] initWithString:@""] autorelease];
	jsString = [jsString stringByAppendingString:@"$(\".selected\").each(function (i) {\
				$(this).delay(800).removeClass('selected');\
				});"];
	
	[self.smileView stringByEvaluatingJavaScriptFromString:jsString];
	
	//NSLog(@"didSelectSmile END");
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];		
	[self.smileView setAlpha:0];
	
	[self.segmentControler setAlpha:1];
	[self.segmentControlerPage setAlpha:0];
	
	[UIView commitAnimations];	
	
	[self.textView becomeFirstResponder];
	

	
}

-(void)insertBBCode:(NSString *)code {
	
	NSMutableString *text = [textView.text mutableCopy];
	
	//NSLog(@"textView %d %d", textView.selectedRange.location, textView.selectedRange.length);

    NSRange selectedRange = textView.selectedRange;
    
    [text insertString:[NSString stringWithFormat:@"[/%@]", code] atIndex:selectedRange.location+selectedRange.length];
    [text insertString:[NSString stringWithFormat:@"[%@]", code] atIndex:selectedRange.location];	
	
	//NSLog(@"selectedRange %d %d", selectedRange.location, selectedRange.length);
	
	if (selectedRange.length > 0) {
		selectedRange.location += (code.length * 2) + 5 + selectedRange.length;
	}
	else {
		selectedRange.location += code.length + 2;
	}

	selectedRange.length = 0;
	
	
	
    textView.text = text;
	textView.selectedRange = selectedRange;
    [text release];
	
}
- (void)textBold:(id)sender{
	[self insertBBCode:@"b"];
}
- (void)textItalic:(id)sender{
	[self insertBBCode:@"i"];
}
- (void)textUnderline:(id)sender{
	[self insertBBCode:@"u"];

}
- (void)textStrike:(id)sender{
	[self insertBBCode:@"strike"];
}

- (void)textSpoiler:(id)sender{
	[self insertBBCode:@"spoiler"];
}
- (void)textFixe:(id)sender{
	[self insertBBCode:@"fixed"];
}	 
- (void)textLink:(id)sender{
	[self insertBBCode:@"url"];
}
- (void)textImg:(id)sender{
	[self insertBBCode:@"img"];
}

#pragma mark -
#pragma mark Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
	//NSLog(@"textViewShouldBeginEditing");

	if(lastSelectedRange.location != NSNotFound) 
	{
		textView.selectedRange = lastSelectedRange;
	}
	
	
    return YES;  
	
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
	 */
    
    if (textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;    

        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
    }
	
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
	//NSLog(@"textViewShouldEndEditing");

	if(self.loaded)
	{
		//NSLog(@"textViewShouldEndEditing NO");
		self.loaded = NO;
		return NO;
	}
	
	self.lastSelectedRange = textView.selectedRange;
	
    [textView resignFirstResponder];
	//NSLog(@"textViewShouldEndEditing YES");
	
    return YES;
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
	//NSLog(@"keyboardWillShow ADD %@", notification);

    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.accessoryView.frame = newTextViewFrame;

    [UIView commitAnimations];
	//[self.scrollViewer setContentSize:CGSizeMake(self.textView.frame.size.width, MAX(self.textView.frame.size.height, newTextViewFrame.size.height - segmentControler.frame.size.height - 5))];

}

- (void)keyboardWillHide:(NSNotification *)notification {
	//NSLog(@"keyboardWillHide ADD");

    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.accessoryView.frame = self.view.bounds;

    [UIView commitAnimations];
	//[self.scrollViewer setContentSize:CGSizeMake(self.textView.frame.size.width, MAX(self.textView.frame.size.height, self.view.bounds.size.height - segmentControler.frame.size.height - 5))];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//NSLog(@"textFieldDidBeginEditing %@", textField);
	
	if (textField != textFieldSmileys) {
		[segmentControler setEnabled:NO forSegmentAtIndex:0];
		[textFieldSmileys setEnabled:NO];
	}
	else {
		if (self.usedSearchDict.count > 0) {

			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.2];		
			[self.smileView setAlpha:0];
			
			[self.segmentControler setAlpha:1];
			[self.segmentControlerPage setAlpha:0];		
			
			[UIView commitAnimations];
			
			[self textFieldSmileChange:self.textFieldSmileys]; //on affiche les recherches

			[self.commonTableView reloadData];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.2];		
			[self.commonTableView setAlpha:1];
			[UIView commitAnimations];
		}


	}
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//NSLog(@"textFieldDidEndEditing %@", textField);
	
	[segmentControler setEnabled:YES forSegmentAtIndex:0];	
	[textFieldSmileys setEnabled:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	//NSLog(@"textFieldShouldReturn");
	
	//[textField resignFirstResponder];
	if (textField == self.textFieldTo) {
		[self.textFieldTitle becomeFirstResponder];
	}
	else if (textField == self.textFieldTitle)
	{
		[self.textView becomeFirstResponder];
	}
	else if (textField == self.textFieldSmileys)
	{
		if (self.textFieldSmileys.text.length < 3) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Saisir 3 caractères minimum !" 
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else {
			
			if (self.smileView.alpha == 0.0) {
				// BUG pas de selection ///
				self.loaded = NO;
				[textView resignFirstResponder];
				NSRange newRange = textView.selectedRange;
				newRange.length = 0;
				textView.selectedRange = newRange;
				
				[self.smileView setHidden:NO];
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.2];		
				[self.smileView setAlpha:1];
				[UIView commitAnimations];
			}
			
			[self.commonTableView setAlpha:0];
			
			[textFieldSmileys resignFirstResponder];
			[self fetchSmileys];
			/*
			[self.smileView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
			$.ajax({ url: '%@/message-smi-mp-aj.php?config=hfr.inc&findsmilies=%@',\
			success: function(data){\
				$('#container').hide();\
				$('#container_ajax').html(data);\
				$('#container_ajax img').addSwipeEvents().bind('tap', function(evt, touch) { $(this).addClass('selected'); window.location = 'oijlkajsdoihjlkjasdosmile://'+$.base64.encode(this.alt); });\
			}\
			\
			});", kForumURL, self.textFieldSmileys.text]];
			 */
		}
	}
	return NO;

}
/*- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	NSLog(@"textFieldShouldClear %@", textField.text);

	
	return YES;

}*/
-(IBAction)textFieldSmileChange:(id)sender
{
	//NSLog(@"textFieldSmileChange %@", [(UITextField *)sender text]);
	if ([(UITextField *)sender text].length > 0) {
		self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF contains[c] '%@'", [(UITextField *)sender text]]]];
		[self.commonTableView reloadData];
		//NSLog(@"usedSearchSortedArray %@", usedSearchSortedArray);		
	}
	else {
		self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		[self.commonTableView reloadData];
		//NSLog(@"usedSearchSortedArray %@", usedSearchSortedArray);				
	}
	if (self.usedSearchSortedArray.count == 0) {
		UILabel *labelTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)] autorelease];
		labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[labelTitle setFont:[UIFont systemFontOfSize:14.0]];
		[labelTitle setAdjustsFontSizeToFitWidth:NO];
		[labelTitle setLineBreakMode:UILineBreakModeTailTruncation];
		//[labelTitle setBackgroundColor:[UIColor blueColor]];
		[labelTitle setTextAlignment:UITextAlignmentCenter];
		[labelTitle setHighlightedTextColor:[UIColor whiteColor]];
		[labelTitle setTag:999];
		[labelTitle setText:@"Pas de résultats"];
		[labelTitle setTextColor:[UIColor blackColor]];
		[labelTitle setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.commonTableView setTableFooterView:labelTitle];		
	}
	else {
		[self.commonTableView setTableFooterView:nil];
	}

	
	

}

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchSmileys
{
	//NSLog(@"fetchSmileys");

	
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
	
	[self setRequestSmile:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/message-smi-mp-aj.php?config=hfr.inc&findsmilies=%@", kForumURL, self.textFieldSmileys.text]]]];
	[requestSmile setDelegate:self];
	
	[requestSmile setDidStartSelector:@selector(fetchSmileContentStarted:)];
	[requestSmile setDidFinishSelector:@selector(fetchSmileContentComplete:)];
	[requestSmile setDidFailSelector:@selector(fetchSmileContentFailed:)];

	[self.smileView stringByEvaluatingJavaScriptFromString:@"$('#container').hide();$('#container_ajax').html('<div class=\"loading\"><img src=\"loadinfo.net.gif\" /> Recherche en cours...</div>');"];
	[requestSmile startAsynchronous];
	//NSLog(@"fetchSmileys");

}

- (void)fetchSmileContentStarted:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentStarted");
}

- (void)fetchSmileContentComplete:(ASIHTTPRequest *)theRequest
{
//	NSLog(@"%@", [theRequest responseString]);
	[self.segmentControlerPage setTitle:@"Smilies" forSegmentAtIndex:1];

	//NSDate *thenT = [NSDate date]; // Create a current date
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithString:[theRequest responseString] error:NULL];
	HTMLNode * smileNode = [myParser doc]; //Find the body tag
	
	NSArray * tmpImageArray =  [smileNode findChildTags:@"img"];
	
	//Traitement des smileys (to Array)
	[self.smileyArray removeAllObjects]; //RaZ
	
	for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
		[self.smileyArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"src"], [imgNode getAttributeNamed:@"alt"], nil] forKeys:[NSArray arrayWithObjects:@"source", @"code", nil]]];
	}
	//NSLog(@"%@", self.smileyArray);
	
	if (self.smileyArray.count == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Aucun résultat !" 
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.textFieldSmileys becomeFirstResponder];
		[self.smileView stringByEvaluatingJavaScriptFromString:@"$('#container').show();$('#container_ajax').html('');"];
		return;
	}
	
	[self loadSmileys:0];
	//[self loadSmileys:smileyPage];	

	//NSDate *nowT = [NSDate date]; // Create a current date
	
	//NSLog(@"SMILEYS Parse Time elapsed Total		: %f", [nowT timeIntervalSinceDate:thenT]);
}

- (void)fetchSmileContentFailed:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentFailed %@", [theRequest.error localizedDescription]);

	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
	//											   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	//[alert show];
	//[alert release];	
}

-(void)loadSmileys:(int)page;
{
	self.smileyPage = page;
	
	[self.smileView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
															$('#container').hide();\
															$('#container_ajax').html('<div class=\"loading\"><img src=\"loadinfo.net.gif\" /> Page n˚%d...</div>');\
															", page + 1]];
	
	[self performSelectorInBackground:@selector(loadSmileys) withObject:nil];

}	

-(void)loadSmileys;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int page = self.smileyPage;
	

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *diskCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmileCache"] retain];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
	{
		//NSLog(@"createDirectoryAtPath");
		[[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	else {
		//NSLog(@"pas createDirectoryAtPath");
	}
	
	int smilePerPage = 40;
	int firstSmile = page * smilePerPage;
	int lastSmile = MIN([self.smileyArray count], (page + 1) * smilePerPage);
	
	//NSLog(@"%d to %d", firstSmile, lastSmile);
	
	int i;
	
	NSString *tmpHTML = [[[NSString alloc] initWithString:@""] autorelease];
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	for (i = firstSmile; i < lastSmile; i++) { //Loop through all the tags

		NSString *filename = [[[self.smileyArray objectAtIndex:i] objectForKey:@"source"] stringByReplacingOccurrencesOfString:@"http://forum-images.hardware.fr/" withString:@""];
		filename = [filename stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
		filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"-"];
		
		NSString *key = [diskCachePath stringByAppendingPathComponent:filename];
		
		//NSLog(@"url %@", [[self.smileyArray objectAtIndex:i] objectForKey:@"source"]);
		//NSLog(@"key %@", key);
		
		if (![fileManager fileExistsAtPath:key])
		{
			//NSLog(@"dl %@", key);
			
			[fileManager createFileAtPath:key contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[self.smileyArray objectAtIndex:i] objectForKey:@"source"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]] attributes:nil];					
		}
		
		
		tmpHTML = [tmpHTML stringByAppendingString:[NSString stringWithFormat:@"<img class=\"smile\" src=\"%@\" alt=\"%@\"/>", key, [[self.smileyArray objectAtIndex:i] objectForKey:@"code"]]];
		
	}

	[fileManager release];

	tmpHTML = [tmpHTML stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];

	[self performSelectorOnMainThread:@selector(showSmileResults:) withObject:tmpHTML waitUntilDone:YES];
	
	//Pagination
	//if (firstSmile > 0 || lastSmile < [self.smileyArray count]) {
		//NSLog(@"pagination needed");
		
		[self.segmentControler setAlpha:0];
		[self.segmentControlerPage setAlpha:1];		
		
		if (firstSmile > 0) {
			[self.segmentControlerPage setEnabled:YES forSegmentAtIndex:0];			
		}
		else {
			[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:0];
		}

		if (lastSmile < [self.smileyArray count]) {
			[self.segmentControlerPage setEnabled:YES forSegmentAtIndex:2];			
		}
		else {
			[self.segmentControlerPage setEnabled:NO forSegmentAtIndex:2];
		}		
		
		
	//}
	
	
	[diskCachePath release];
	[pool release];
}

-(void)showSmileResults:(NSString *)tmpHTML {
	
	//NSLog(@"showSmileResults");
	
	[self.smileView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
															$('#container').hide();\
															$('#container_ajax').html('%@');\
															$('#container_ajax img').addSwipeEvents().bind('tap', function(evt, touch) { $(this).addClass('selected'); window.location = 'oijlkajsdoihjlkjasdosmile://'+$.base64.encode(this.alt); });\
															", tmpHTML]];	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//NSLog(@"NB Section %d", arrayDataID.count);
	
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Recherche(s)";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSLog(@"%@", self.usedSearchDict);

	return self.usedSearchSortedArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		//NSLog(@"mew cell");
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

		cell.accessoryType = UITableViewCellAccessoryNone;
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

	cell.textLabel.text = [self.usedSearchSortedArray objectAtIndex:indexPath.row];	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	self.textFieldSmileys.text = [self.usedSearchSortedArray objectAtIndex:indexPath.row];
	[self textFieldShouldReturn:self.textFieldSmileys];
	[self.commonTableView deselectRowAtIndexPath:self.commonTableView.indexPathForSelectedRow animated:NO];

}

#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.loadingView = nil;	
	
	self.textView.delegate = nil;
    self.textView = nil;
	
    self.formSubmit = nil;
	self.accessoryView = nil;
	
	[self.smileView stopLoading];
	self.smileView.delegate = nil;
	self.smileView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	
	self.segmentControler = nil;
	
	self.textFieldTitle = nil;
	self.textFieldTo = nil;
	
	self.commonTableView = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
	//NSLog(@"dealloc ADD");

	[textView resignFirstResponder];
	[self viewDidUnload];
	
	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	[requestSmile cancel];
	[requestSmile setDelegate:nil];
	self.requestSmile = nil;
	
	self.smileyArray = nil;
	self.usedSearchDict = nil;
	self.usedSearchSortedArray = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"smileyReceived" object:nil];
	
	self.delegate = nil;
	[self.arrayInputData release];

	[super dealloc];

	
	
}

@end
