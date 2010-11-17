//
//  AddMessageViewController.m
//  HFR+
//
//  Created by Lace on 16/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddMessageViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import "RegexKitLite.h"

//#import "SmileFormController.h"


@implementation AddMessageViewController
@synthesize delegate, textView, arrayInputData, formSubmit, accessoryView, smileView;
@synthesize request, loadingView;

@synthesize lastSelectedRange, loaded;//navBar, 
@synthesize segmentControler, isDragging;

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
		self.formSubmit = [[NSString alloc] init];
		
		self.loaded = NO;
		self.isDragging = NO;
		
		self.haveCategory = NO;
		self.haveTitle = NO;
		self.haveTo	= NO;
		
		self.offsetY = 0;
		
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
	

	
	/*
	 
	 self.smileysWebView.layer.cornerRadius = 10;
	 [self.smileysWebView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
	 [self.smileysWebView.layer setBorderWidth: 1.0];
	 */
	
	 for (id subview in smileView.subviews)
		 if ([[subview class] isSubclassOfClass: [UIScrollView class]])
			 ((UIScrollView *)subview).bounces = NO;
	 
	
	/*
	NSString *path = [[NSBundle mainBundle] pathForResource:
					  @"commonsmile" ofType:@"plist"];
	
	// Build the array from the plist  
	self.arrayData = [[NSMutableArray alloc] initWithContentsOfFile:path];
	
	NSLog(@"self.arrayData count %d", [self.arrayData count]);
	[self renderSmileys];
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
		[UIView commitAnimations];	
		
		[self.textView becomeFirstResponder];
	}
	else {
		if ([self.textView text].length > 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention !" message:@"Vous allez perdre le contenu de votre message."
														   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", nil];
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
	if (buttonIndex == 1) {
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
		//NSLog(@"POST: %@ : %@", key, [self.arrayInputData objectForKey:key]);
		if ([key isEqualToString:@"allowvisitor"] || [key isEqualToString:@"have_sondage"]) {
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
	switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
		case 0:
		{
/*
			SmileFormController *smileFormController = [[[SmileFormController alloc] initWithNibName:@"SmileFormController" bundle:nil] autorelease];
			// Pass the selected object to the new view controller.
			self.navigationItem.backBarButtonItem =
			[[UIBarButtonItem alloc] initWithTitle:@"Retour"
											 style: UIBarButtonItemStyleBordered
											target:nil
											action:nil];
			
			
			[self.navigationController pushViewController:smileFormController animated:YES];
*/
			/*
			if (self.smileView.alpha == 0) {
				[[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
				
				NSRange newRange = textView.selectedRange;
				newRange.length = 0;
				textView.selectedRange = newRange;
				
				[self.smileView setHidden:NO];
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.2];		
				[self.smileView setAlpha:1];
				[UIView commitAnimations];
			}
			else {
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.2];		
				[self.smileView setAlpha:0];
				[UIView commitAnimations];
			}
*/
			if (self.smileView.alpha == 0.0) {
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
		case 2:
			break;
		case 3:
			break;			
		default:
			break;
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
	NSLog(@"keyboardWillShow ADD %@", notification);

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
	NSLog(@"keyboardWillHide ADD");

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
	NSLog(@"textFieldDidBeginEditing");
	
	[segmentControler setEnabled:NO forSegmentAtIndex:0];		
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	[segmentControler setEnabled:YES forSegmentAtIndex:0];		
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"textFieldShouldReturn");
	
	//[textField resignFirstResponder];
	if (textField == self.textFieldTo) {
		[self.textFieldTitle becomeFirstResponder];
	}
	else if (textField == self.textFieldTitle)
	{
		[self.textView becomeFirstResponder];
	}

	return NO;

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
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"smileyReceived" object:nil];
	
	self.delegate = nil;
	[self.arrayInputData release];

	[super dealloc];

	
	
}

@end
