    //
//  QuoteMessageViewController.m
//  HFRplus
//
//  Created by FLK on 17/08/10.
//

#import "HFRplusAppDelegate.h"

#import "QuoteMessageViewController.h"
#import "HTMLParser.h"
#import "Forum.h"
#import "SubCatTableViewController.h"


@implementation QuoteMessageViewController
@synthesize urlQuote;
@synthesize myPickerView, pickerViewArray, actionSheet, catButton;
- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"======== fetchContent");
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
	
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.urlQuote lowercaseString]]]];
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[self.accessoryView setHidden:YES];
	[self.loadingView setHidden:NO];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
		//started
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	
	[self.arrayInputData removeAllObjects];
	
	[self loadDataInTableView:[request responseData]];

	[self.accessoryView setHidden:NO];
	[self.loadingView setHidden:YES];
	
	[self setupResponder];
	//NSLog(@"======== fetchContentComplete");
	
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	[self.loadingView setHidden:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:777];
	[alert show];
	[alert release];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 777) {
		if (buttonIndex == 1) {
			[self fetchContent];
		}
		else {
			[self cancel];
		}

	}
	else {
		[super alertView:alertView clickedButtonAtIndex:buttonIndex];
	}
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.pickerViewArray = [[NSMutableArray alloc] init];
		
		self.title = @"Répondre";
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (void)viewDidLoad {
	[super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSubCat) name:@"CatSelected" object:nil];
    
	[self fetchContent];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)loadDataInTableView:(NSData *)contentData {
	//[NSURL URLWithString:[self.urlQuote lowercaseString]]
	//NSDate *thenT = [NSDate date]; // Create a current date

	NSError * error = nil;
	//HTMLParser * myParser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:[self.urlQuote lowercaseString]] error:&error];
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:&error];
	//NSLog(@"error %@", error);
	//NSDate *then0 = [NSDate date]; // Create a current date

	HTMLNode * bodyNode = [myParser body]; //Find the body tag
		
	HTMLNode * fastAnswerNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hop" allowPartial:NO];
	
	NSArray *temporaryAllInputArray = [fastAnswerNode findChildTags:@"input"];
	//NSLog(@"inputNode ========== %d", temporaryAllInputArray.count);

	temporaryAllInputArray = [temporaryAllInputArray arrayByAddingObjectsFromArray:[fastAnswerNode findChildTags:@"select"]];
	
	//NSLog(@"inputNode ========== %d", temporaryAllInputArray.count);

	for (HTMLNode * inputallNode in temporaryAllInputArray) { //Loop through all the tags
		//NSLog(@"inputallNode: %@ - value: %@", [inputallNode getAttributeNamed:@"name"], [inputallNode getAttributeNamed:@"value"]);

		if ([inputallNode getAttributeNamed:@"value"] && [inputallNode getAttributeNamed:@"name"]) {
			
			if ([[inputallNode getAttributeNamed:@"name"] isEqualToString:@"MsgIcon"]) {
				if ([[inputallNode getAttributeNamed:@"checked"] isEqualToString:@"checked"]) {
					[self.arrayInputData setObject:[inputallNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
				}

			}
			else if ([[inputallNode getAttributeNamed:@"type"] isEqualToString:@"checkbox"]) {
				if ([[inputallNode getAttributeNamed:@"checked"] isEqualToString:@"checked"]) {
					//NSLog(@"checked");
					[self.arrayInputData setObject:@"1" forKey:[inputallNode getAttributeNamed:@"name"]];
				}
				else {
					//NSLog(@"pas checked");
					[self.arrayInputData setObject:@"0" forKey:[inputallNode getAttributeNamed:@"name"]];
				}

			}
			else {
				[self.arrayInputData setObject:[inputallNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
			}

			
			if ([[inputallNode getAttributeNamed:@"name"] isEqualToString:@"sujet"]) {
				if ([[inputallNode getAttributeNamed:@"type"] isEqualToString:@"hidden"]) {
				}
				else {
					//NSLog(@"Sujet OK");
					self.haveTitle = YES;
				}
				
			}
			
			if ([[inputallNode getAttributeNamed:@"name"] isEqualToString:@"dest"]) {
				//NSLog(@"haveTohaveTohaveTohaveTohaveTo");
				self.haveTo = YES;
			}
			
		}		
		else if ([[inputallNode tagName] isEqualToString:@"select"]) {
			
			if ([[inputallNode getAttributeNamed:@"name"] isEqualToString:@"subcat"]) {
				self.haveCategory = YES;
				
				for (HTMLNode * catNode in [inputallNode children]) { //Loop through all the tags
					
					Forum *aForum = [[Forum alloc] init];

					//Title
					NSString *aForumTitle = [[NSString alloc] initWithString:[[catNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					[aForum setATitle:aForumTitle];
					[aForumTitle release];

					//ID
					NSString *aForumID = [[NSString alloc] initWithString:[[catNode getAttributeNamed:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					[aForum setAID:aForumID];
					[aForumID release];
					
					[pickerViewArray addObject:aForum];
					
					[aForum release];
				}
			}
			
			
			//NSLog(@"select");
			HTMLNode *selectedNode = [inputallNode findChildWithAttribute:@"selected" matchingName:@"selected" allowPartial:NO];
			if (selectedNode) {
				//NSLog(@"selectedNode %@ %@", [selectedNode contents], [inputallNode getAttributeNamed:@"name"]);

				[self.arrayInputData setObject:[selectedNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
			}
			else {
				//NSLog(@"pas selected %@ %@", [[inputallNode firstChild] contents], [inputallNode getAttributeNamed:@"name"]);

				[self.arrayInputData setObject:[[inputallNode firstChild] getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
			}

		}


		
	}

	
	//useless [self.arrayInputData setObject:[[fastAnswerNode findChildWithAttribute:@"name" matchingName:@"password" allowPartial:NO] getAttributeNamed:@"value"] forKey:@"password"];
	//useless [self.arrayInputData setObject:[[fastAnswerNode findChildWithAttribute:@"name" matchingName:@"pseudo" allowPartial:NO] getAttributeNamed:@"value"] forKey:@"pseudo"];
	//useless [self.arrayInputData setObject:@"1" forKey:@"MsgIcon"];
	
	


	
	[super initData];
	
	
	//self.navigationItem.prompt = @"Répondre";

	//[[self.navBar.items objectAtIndex:2] setTitle:self.title];
	

	//EDITOR
	float offsetforiPad = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { 
        offsetforiPad += 220;
    }
    
	float originY = 0;
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	if (self.haveTo) {
		UITextField *titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(8, originY, 25, 43)];
		titleLabel.text = @"À :";
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
		titleLabel.font = [UIFont systemFontOfSize:15];
		titleLabel.userInteractionEnabled = NO;
		titleLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		textFieldTo = [[UITextField alloc] initWithFrame:CGRectMake(38, originY, 265 + offsetforiPad, 43)];
        textFieldTo.tag = 1;
		textFieldTo.backgroundColor = [UIColor whiteColor];
		textFieldTo.font = [UIFont systemFontOfSize:15];
		textFieldTo.delegate = self;
		textFieldTo.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textFieldTo.keyboardAppearance = UIKeyboardAppearanceAlert;
		textFieldTo.returnKeyType = UIReturnKeyNext;
		[textFieldTo setText:[self.arrayInputData valueForKey:@"dest"]];
		textFieldTo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		originY += textFieldTo.frame.size.height;
		
		UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, originY, 320 + offsetforiPad, 1)] autorelease];
		separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
		separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		originY += separator.frame.size.height;
		
		[headerView addSubview:titleLabel];
		[headerView addSubview:textFieldTo];
		[headerView addSubview:separator];
		
		[titleLabel release];
		
		headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.x, headerView.frame.size.width, originY);	
	}

	if (self.haveTitle) {
		UITextField *titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(8, originY, 45, 43)];
		titleLabel.text = @"Sujet :";
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
		titleLabel.font = [UIFont systemFontOfSize:15];
		titleLabel.userInteractionEnabled = NO;
		titleLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		textFieldTitle = [[UITextField alloc] initWithFrame:CGRectMake(58, originY, 245 + offsetforiPad, 43)];
        textFieldTitle.tag = 2;        
		textFieldTitle.backgroundColor = [UIColor whiteColor];
		textFieldTitle.font = [UIFont systemFontOfSize:15];
		textFieldTitle.delegate = self;
		textFieldTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textFieldTitle.keyboardAppearance = UIKeyboardAppearanceAlert;
		textFieldTitle.returnKeyType = UIReturnKeyNext;
		[textFieldTitle setText:[self.arrayInputData valueForKey:@"sujet"]];
		textFieldTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		//[textFieldTitle setText:[[fastAnswerNode findChildWithAttribute:@"name" matchingName:@"sujet" allowPartial:NO] getAttributeNamed:@"value"]];

		originY += textFieldTitle.frame.size.height;
		
		UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, originY, 320 + offsetforiPad, 1)] autorelease];
		separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
		separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		originY += separator.frame.size.height;
		
		[headerView addSubview:titleLabel];
		[headerView addSubview:textFieldTitle];
		[headerView addSubview:separator];
		
		[titleLabel release];

		headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.x, headerView.frame.size.width, originY);
		
		//[titleLabel release];
		//[separator release];
	}
	
	if (self.haveCategory) {
		UITextField *titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(8, originY, 75, 43)];
		titleLabel.text = @"Catégorie :";
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
		titleLabel.font = [UIFont systemFontOfSize:15];
		titleLabel.userInteractionEnabled = NO;
		titleLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		catButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		catButton.frame = CGRectMake(88, originY + 5, 215 + offsetforiPad, 33);
		
		int row = 0;
		for(Forum *aForum in pickerViewArray){
			if ([[aForum aID] isEqualToString:[self.arrayInputData valueForKey:@"subcat"]]) {
				[catButton setTitle:[aForum aTitle] forState:UIControlStateNormal];
				break;
			}
			row++;
		}
		[catButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[catButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
		[catButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
		catButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		
		textFieldCat = [[UITextField alloc] initWithFrame:CGRectMake(88, originY, 215, 43)];
		textFieldCat.backgroundColor = [UIColor whiteColor];
		textFieldCat.font = [UIFont systemFontOfSize:15];
		textFieldCat.delegate = self;
		textFieldCat.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textFieldCat.keyboardAppearance = UIKeyboardAppearanceAlert;
		textFieldCat.returnKeyType = UIReturnKeyNext;
		//NSLog(@"CAT %@", [self.arrayInputData valueForKey:@"subcat"]);
		[textFieldCat setText:[self.arrayInputData valueForKey:@"subcat"]];
		textFieldCat.userInteractionEnabled = NO;
		textFieldCat.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		originY += textFieldCat.frame.size.height;
		
		UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, originY, 320 + offsetforiPad, 1)] autorelease];
		separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
		separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		originY += separator.frame.size.height;
		
		[headerView addSubview:titleLabel];
		[headerView addSubview:textFieldCat];
		[headerView addSubview:catButton];
		[headerView addSubview:separator];
		
		[titleLabel release];

		headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.x, headerView.frame.size.width, originY);

		//[titleLabel release];
		//[catButton release];
		//[separator release];
		
		//-- PICKER
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
		
		myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
		
		myPickerView.showsSelectionIndicator = YES;
		myPickerView.dataSource = self;
		myPickerView.delegate = self;
		
		[myPickerView selectRow:row inComponent:0 animated:NO];

		[actionSheet addSubview:myPickerView];
		
		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Retour"]];
		closeButton.momentary = YES; 
		closeButton.frame = CGRectMake(10, 7.0f, 55.0f, 30.0f);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blackColor];
		[closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
		[actionSheet addSubview:closeButton];
		[closeButton release];
		
		UISegmentedControl *confirmButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Valider"]];
		confirmButton.momentary = YES; 
		confirmButton.tag = 546; 
		confirmButton.frame = CGRectMake(255, 7.0f, 55.0f, 30.0f);
		confirmButton.segmentedControlStyle = UISegmentedControlStyleBar;
		confirmButton.tintColor = [UIColor colorWithRed:60/255.f green:136/255.f blue:230/255.f alpha:1.00];
		[confirmButton addTarget:self action:@selector(loadSubCat) forControlEvents:UIControlEventValueChanged];
		[actionSheet addSubview:confirmButton];
		[confirmButton release];
		//-- PICKER
		
	}

	headerView.frame = CGRectMake(headerView.frame.origin.x, originY * -1.0f, headerView.frame.size.width, originY);
	[self.textView addSubview:headerView];
    textView.tag = 3;        

	[headerView release];
	

	self.offsetY = originY * -1.0f;
	self.textView.contentInset = UIEdgeInsetsMake(originY, 0.0f, 0.0f, 0.0f);
	self.textView.contentOffset = CGPointMake(0.0f, self.offsetY);
	//--- EDITOR
	
	//-----
	//NSString *key;
	//for (key in self.arrayInputData) {
	//	NSLog(@"POST: %@ : %@", key, [self.arrayInputData objectForKey:key]);
	//}	
	//-----

	
	
	
	[self.textView setText:[[fastAnswerNode findChildWithAttribute:@"id" matchingName:@"content_form" allowPartial:NO] contents]];
	//textView.contentOffset = CGPointMake(0, 0);

	[self textViewDidChange:self.textView];
	
	//NSLog(@"self.formSubmit %@", self.formSubmit);

	NSString *newSubmitForm = [[NSString alloc] initWithFormat:@"%@%@", kForumURL, [fastAnswerNode getAttributeNamed:@"action"]];
	[self setFormSubmit:newSubmitForm];
	[newSubmitForm release];
	
	//self.formSubmit = [NSString stringWithFormat:@"http://forum.hardware.fr/%@", [fastAnswerNode getAttributeNamed:@"action"]];
	//NSLog(@"self.formSubmit2 %@", self.formSubmit);
	[myParser release];
	

	//NSDate *nowT = [NSDate date]; // Create a current date
	
	//NSLog(@"TOPICS Time elapsed then0		: %f", [then0 timeIntervalSinceDate:thenT]);
	//NSLog(@"TOPICS Time elapsed nowT		: %f", [nowT timeIntervalSinceDate:then0]);
	//NSLog(@"TOPICS Time elapsed Total		: %f", [nowT timeIntervalSinceDate:thenT]);
}



#pragma mark -
#pragma mark UIPickerViewDelegate

-(void)loadSubCat
{
    [_popover dismissPopoverAnimated:YES];
    
	[catButton setTitle:[[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle] forState:UIControlStateNormal];
	[textFieldCat setText:[[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aID]];
	
	[self dismissActionSheet];
	
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myPickerView)	// don't show selection for the custom picker
	{
		// report the selection to the UI label
		//label.text = [NSString stringWithFormat:@"%@ - %d",
		//			  [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]],
		//			  [pickerView selectedRowInComponent:1]];
		
		//NSLog(@"%@", [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]]);
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	if (row == 0) {
		//NSString *returnStr = @"";
		
	}
	else {
		returnStr = @"- ";
	}
	
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == myPickerView)
	{
		if (component == 0)
		{
			returnStr = [returnStr stringByAppendingString:[[pickerViewArray objectAtIndex:row] aTitle]];
		}
	}
	
	return returnStr;
}
/*
 - (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
 {
 CGFloat componentWidth = 0.0;
 
 if (component == 0)
 componentWidth = 240.0;	// first column size is wider to hold names
 else
 componentWidth = 40.0;	// second column is narrower to show numbers
 
 return componentWidth;
 }
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	//CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   40,
								   self.view.frame.size.width,
								   size.height);
	
	
	return pickerRect;
}

-(void)dismissActionSheet {
	[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)showPicker:(id)sender{
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //NSLog(@"TT %@", [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle]);
        
        SubCatTableViewController *subCatTableViewController = [[[SubCatTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        subCatTableViewController.suPicker = myPickerView;
        subCatTableViewController.arrayData = pickerViewArray;
        subCatTableViewController.notification = @"CatSelected";

        self.popover = [[[UIPopoverController alloc] initWithContentViewController:subCatTableViewController] autorelease];
        
        [_popover presentPopoverFromRect:[(UIButton *)sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        
        
    } else {
        CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
        myPickerView.frame = [self pickerFrameWithSize:pickerSize];
        
        
        [actionSheet showInView:self.view];
        
        CGRect curFrame = [[actionSheet viewWithTag:546] frame];
        curFrame.origin.x =  self.view.frame.size.width - curFrame.size.width - 10;
        [[actionSheet viewWithTag:546] setFrame:curFrame];
        
        [UIView beginAnimations:nil context:nil];
        [actionSheet setFrame:CGRectMake(0, self.view.frame.size.height - myPickerView.frame.size.height - 44,
                                         self.view.frame.size.width, myPickerView.frame.size.height + 44)];
        
        [actionSheet setBounds:CGRectMake(0, 0,
                                          self.view.frame.size.width, myPickerView.frame.size.height + 44)];
        
        [UIView commitAnimations]; 
    }

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.urlQuote = nil;
	
	//Picker
	self.myPickerView = nil;
	self.actionSheet = nil;
	self.pickerViewArray = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CatSelected" object:nil];

    
    [super dealloc];
}

@end
