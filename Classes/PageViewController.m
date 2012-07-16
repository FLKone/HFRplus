    //
//  PageViewController.m
//  HFRplus
//
//  Created by FLK on 10/10/10.
//

#import "PageViewController.h"


@implementation PageViewController
@synthesize previousPageUrl, nextPageUrl;
@synthesize currentUrl, pageNumber;
@synthesize firstPageNumber, lastPageNumber;
@synthesize firstPageUrl, lastPageUrl;
@synthesize pageNumberField;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		self.nextPageUrl = [[NSString alloc] init];
		self.previousPageUrl = [[NSString alloc] init];
		
		self.firstPageUrl = [[NSString alloc] init];
		self.lastPageUrl = [[NSString alloc] init];		
    }
    return self;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)fetchContent{
	
}

-(void)choosePage{
	//NSLog(@"choosePage");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aller à la page" message:[NSString stringWithFormat:@"\n\n(numéro entre %d et %d)\n", [self firstPageNumber], [self lastPageNumber]]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"OK", nil];
	
	pageNumberField = [[UITextField alloc] initWithFrame:CGRectZero];
	[pageNumberField setBackgroundColor:[UIColor whiteColor]];
	[pageNumberField setPlaceholder:@"numéro de la page"];
	pageNumberField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[pageNumberField setBackground:[UIImage imageNamed:@"bginput"]];
	
	//[pageNumberField textRectForBounds:CGRectMake(5.0, 5.0, 258.0, 28.0)];
	
	
	[pageNumberField.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[pageNumberField.layer setBorderWidth: 1.0];
	
	pageNumberField.font = [UIFont systemFontOfSize:15];
	pageNumberField.textAlignment = UITextAlignmentCenter;
	pageNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	pageNumberField.keyboardAppearance = UIKeyboardAppearanceAlert;
	pageNumberField.keyboardType = UIKeyboardTypeNumberPad;
	pageNumberField.delegate = self;
	[pageNumberField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[alert setTag:668];
	[alert addSubview:pageNumberField];

	
	[alert show];

	UILabel* tmpLbl = [alert.subviews objectAtIndex:1];
	pageNumberField.frame = CGRectMake(12.0, tmpLbl.frame.origin.y + 30, 260.0, 30.0);
	//[pageNumberField textRectForBounds:CGRectMake(5.0, 5.0, 258.0, 28.0)];
	
	//NSLog(@"alert.frame %f %f %f %f", alert.frame.origin.x, alert.frame.origin.y, alert.frame.size.width, alert.frame.size.height);
	
	[alert release];
	
}

- (void)goToPage:(NSString *)pageType;
{
	//NSLog(@"gotoPageNumber %@", pageType);

	
	if ([pageType isEqualToString:@"begin"]) {
		[self firstPage:nil];
	}
	else if ([pageType isEqualToString:@"end"]) {
		[self lastPage:nil];
	}
	else if ([pageType isEqualToString:@"next"]) {
		[self nextPage:nil];
	}
	else if ([pageType isEqualToString:@"previous"]) {
		[self previousPage:nil];
	}	
	else if ([pageType isEqualToString:@"choose"]) {
		[self choosePage];
	}	
	
}

-(void)gotoPageNumber:(int)number{
	//NSLog(@"gotoPageNumber %d", number);
	
	if (!number) {
		return;
	}
	
	//NSLog(@"Current URL %@", self.currentUrl);
	
	
	NSString *newUrl = [NSString stringWithString:self.currentUrl];
	
	
	
	//On remplace le numéro de page dans le titre
	NSString *regexString  = @".*page=([^&]+).*";
	NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
	NSRange   searchRange = NSMakeRange(0, self.currentUrl.length);
	NSError  *error2        = NULL;
	//int numPage;
	
	matchedRange = [self.currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
	
	if (matchedRange.location == NSNotFound) {
		NSRange rangeNumPage =  [[self currentUrl] rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
		//NSLog(@"New URL %@", [newUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", number]]);
		newUrl = [newUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", number]];
		//self.pageNumber = [[self.forumUrl substringWithRange:rangeNumPage] intValue];
	}
	else {
		//NSLog(@"New URL %@", [newUrl stringByReplacingCharactersInRange:matchedRange withString:[NSString stringWithFormat:@"%d", number]]);
		newUrl = [newUrl stringByReplacingCharactersInRange:matchedRange withString:[NSString stringWithFormat:@"%d", number]];
		//self.pageNumber = [[self.forumUrl substringWithRange:matchedRange] intValue];
		
	}	
	
	self.currentUrl = newUrl;
	[self fetchContent];
}

-(void)textFieldDidChange:(id)sender {
	//NSLog(@"textFieldDidChange %d %@", [[(UITextField *)sender text] intValue], sender);	
	
	
	if ([[(UITextField *)sender text] length] > 0) {
		int val; 
		if ([[NSScanner scannerWithString:[(UITextField *)sender text]] scanInt:&val]) {
			//NSLog(@"int %d %@ %@", val, [(UITextField *)sender text], [NSString stringWithFormat:@"%d", val]);
			
			if (![[(UITextField *)sender text] isEqualToString:[NSString stringWithFormat:@"%d", val]]) {
				//NSLog(@"pas int");
				[sender setText:[NSString stringWithFormat:@"%d", val]];
			}
			else if ([[(UITextField *)sender text] intValue] < [self firstPageNumber]) {
				//NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
				[sender setText:[NSString stringWithFormat:@"%d", [self firstPageNumber]]];
				//NSLog(@"ERROR NOW %d", [[(UITextField *)sender text] intValue]);
				
			}
			else if ([[(UITextField *)sender text] intValue] > [self lastPageNumber]) {
				//NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
				[sender setText:[NSString stringWithFormat:@"%d", [self lastPageNumber]]];
				//NSLog(@"ERROR NOW %d", [[(UITextField *)sender text] intValue]);
				
			}	
			else {
				//NSLog(@"OK");
			}
		}
		else {
			[sender setText:@""];
		}
		
		
	}
}

-(void)nextPage:(id)sender {
	
	self.currentUrl = self.nextPageUrl;
	[self fetchContent];	
}
-(void)previousPage:(id)sender {
	
	self.currentUrl = self.previousPageUrl;
	[self fetchContent];	
}
-(void)firstPage {
    [self firstPage:nil];
}
-(void)lastPage {
    [self lastPage:nil];
}
-(void)firstPage:(id)sender {
	
	if(self.firstPageUrl.length > 0) self.currentUrl = self.firstPageUrl;
	[self fetchContent];
}
-(void)lastPage:(id)sender {
	
	if(self.lastPageUrl.length > 0) self.currentUrl = self.lastPageUrl;
	[self fetchContent];	
}
-(void)lastAnswer {
	
	if(self.lastPageUrl.length > 0) self.currentUrl = [NSString stringWithFormat:@"%@#bas", self.lastPageUrl];
	[self fetchContent];	
}

- (void)dealloc {
	
	self.currentUrl = nil;
	
	self.nextPageUrl = nil;
	self.previousPageUrl = nil;

	self.firstPageUrl = nil;
	self.lastPageUrl = nil;
	
	self.pageNumberField = nil;

	
    [super dealloc];
	

}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	
	//NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 666)) {
		usleep(200000);
		
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
	else if (([alertView tag] == 668)) {
		//NSLog(@"keud");
		[pageNumberField becomeFirstResponder];
	}
	
	
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//NSLog(@"willDismissWithButtonIndex PT %@", alertView);
	if (([alertView tag] == 668)) {
		[self.pageNumberField resignFirstResponder];
		self.pageNumberField = nil;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//NSLog(@"clickedButtonAtIndex PT %@", alertView);
	
    
    
	if (buttonIndex == 1 && alertView.tag == 667) {
		[self fetchContent];
	}
	else if (buttonIndex == 1 && alertView.tag == 668) {
		[self gotoPageNumber:[[pageNumberField text] intValue]];
	}
}

@end
