//
//  PageViewController.m
//  HFRplus
//
//  Created by FLK on 10/10/10.
//

#import "HFRplusAppDelegate.h"
#import "PageViewController.h"
#import "MessagesTableViewController.h"

@implementation PageViewController
@synthesize previousPageUrl, nextPageUrl;
@synthesize currentUrl, pageNumber;
@synthesize firstPageNumber, lastPageNumber;
@synthesize firstPageUrl, lastPageUrl;

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

-(void)choosePage {
	//NSLog(@"choosePage");
	
    
    
    if ([UIAlertController class]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Aller à la page"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = [NSString stringWithFormat:@"(numéro entre %d et %d)", [self firstPageNumber], [self lastPageNumber]];
            textField.textAlignment = NSTextAlignmentCenter;
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            textField.keyboardAppearance = UIKeyboardAppearanceDefault;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        
        [alert addAction:cancelAction];
        
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self gotoPageNumber:[[alert.textFields[0] text] intValue]];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        
        
    } else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aller à la page" message:nil
                                                       delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"OK", nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = [NSString stringWithFormat:@"(numéro entre %d et %d)", [self firstPageNumber], [self lastPageNumber]];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
        [alert setTag:668];
        [alert show];

    }
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
    else if ([pageType isEqualToString:@"submitsearch"]) {
        if ([self respondsToSelector:@selector(searchSubmit:)]) {
            [self searchSubmit:nil];
        }

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
	NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
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
	
    newUrl = [newUrl stringByRemovingAnchor];
    
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
    
    if ([[self class] isSubclassOfClass:[MessagesTableViewController class]]) {
        [self fetchContent:kNewMessageFromNext];

    }
    else {
        [self fetchContent];
    }
    
    
}
- (IBAction)searchSubmit:(UIBarButtonItem *)sender {
    
}

- (void)fetchContent:(int)from {
    
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


- (void)didPresentAlertView:(UIAlertView *)alertView
{
	NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 666)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
	else if (([alertView tag] == 668)) {
		//NSLog(@"keud");
	}
    else if (([alertView tag] == 6666) || ([alertView tag] == kAlertBlackListOK)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    else if ([alertView tag] == kAlertPasteBoardOK) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
	
	
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//NSLog(@"willDismissWithButtonIndex PT %@", alertView);
    
	if (([alertView tag] == 668)) {

	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"clickedButtonAtIndex PT %@ index : %ld", alertView, (long)buttonIndex);
    
	if (buttonIndex == 1 && alertView.tag == 667) {
		[self fetchContent];
	}
    else if (buttonIndex == 1 && alertView.tag == 6677) {
        if ([self isKindOfClass:[MessagesTableViewController class]]) {
            [(MessagesTableViewController *)self searchNewMessages:kNewMessageFromUpdate];
        }
    }
	else if (buttonIndex == 1 && alertView.tag == 668) {
		[self gotoPageNumber:[[[alertView textFieldAtIndex:0] text] intValue]];
    }
    else if (buttonIndex == 0 && alertView.tag == 770) {
        NSLog(@"BIM");
        //[self.navigationController popViewControllerAnimated:YES];
        //[self gotoPageNumber:[[[alertView textFieldAtIndex:0] text] intValue]];
    }
    else if (buttonIndex == 1 && alertView.tag == 770) {
        NSLog(@"BAM");
        if ([self isKindOfClass:[MessagesTableViewController class]]) {
            [(MessagesTableViewController *)self.navigationController.topViewController toggleSearch:YES];
        }
        //[self gotoPageNumber:[[[alertView textFieldAtIndex:0] text] intValue]];
    }
}

@end
