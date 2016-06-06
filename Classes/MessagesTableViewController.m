//
//  MessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 07/07/10.
//

#import <unistd.h>

#import "MessagesTableViewController.h"
#import "ASIFormDataRequest.h"

#import "ShakeView.h"
#import "HTMLNode.h"

@implementation MessagesTableViewController

@synthesize aToolbar;

#pragma mark -
#pragma mark View lifecycle


-(void)setupScrollAndPage
{
	//NSLog(@"topicName: %@", self.topicName);
	
	//On vire le '#t09707987987'
	NSRange rangeFlagPage;
	rangeFlagPage =  [[self currentUrl] rangeOfString:@"#" options:NSBackwardsSearch];
	
    
    if (self.stringFlagTopic.length == 0) {
        if (!(rangeFlagPage.location == NSNotFound)) {
            self.stringFlagTopic = [[self currentUrl] substringFromIndex:rangeFlagPage.location];
        }
        else {
            self.stringFlagTopic = @"";
        }
    }
    
	if (!(rangeFlagPage.location == NSNotFound)) {
		self.currentUrl = [[self currentUrl] substringToIndex:rangeFlagPage.location];
    }    
	//--


    /* else */
    
    {
        //On check si y'a page=2323
        NSString *regexString  = @".*page=([^&]+).*";
        NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
        NSRange   searchRange = NSMakeRange(0, self.currentUrl.length);
        NSError  *error2        = NULL;
        
        matchedRange = [self.currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
        
        if (matchedRange.location == NSNotFound) {
            NSRange rangeNumPage =  [[self currentUrl] rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
            if (rangeNumPage.location == NSNotFound) {
                //
                NSLog(@"something went wrong");
                return;
                //[self.navigationController popViewControllerAnimated:YES];
            }
            else {
                self.pageNumber = [[self.currentUrl substringWithRange:rangeNumPage] intValue];
            }
        }
        else {
            self.pageNumber = [[self.currentUrl substringWithRange:matchedRange] intValue];
            
        }
        //On check si y'a page=2323
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
    }

    //NSLog(@"pageNumber %d", self.pageNumber);

    if (self.isSearchIntra) {
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"Recherche | %@", self.topicName]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
        
    }
    
	//self.title = [NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber];
    
	//[self navigationItem].titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	
}

-(void)setupPageToolbar:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser
{
    if (!self.pageNumber && !self.errorReported) {

        self.errorReported = YES;
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            // Do your long running code
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
        
        return;
    }
	//NSLog(@"setupPageToolbar");
    //Titre
	HTMLNode *titleNode = [[bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum2Title" allowPartial:YES] findChildTag:@"h3"]; //Get all the <img alt="" />
	if ([titleNode allContents] && self.topicName.length == 0) {
		//NSLog(@"setupPageToolbar titleNode %@", [titleNode allContents]);
		self.topicName = [titleNode allContents];
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];

        //self.title = [NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber];

		//[self navigationItem].titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	}
    //Titre
    
    
	HTMLNode * pagesTrNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum2PagesHaut" allowPartial:YES];
	
	if(pagesTrNode)
	{
        
		HTMLNode * pagesLinkNode = [pagesTrNode findChildWithAttribute:@"class" matchingName:@"left" allowPartial:NO];
		
		if (pagesLinkNode) {
			//NSLog(@"pages %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));
			
			//NSArray *temporaryNumPagesArray = [[NSArray alloc] init];
			NSArray *temporaryNumPagesArray = [pagesLinkNode children];
            
			[self setFirstPageNumber:[[[temporaryNumPagesArray objectAtIndex:2] contents] intValue]];
			
            //NSLog(@"num %d = %d", [self pageNumber], [self firstPageNumber]);

            
			if ([self pageNumber] == [self firstPageNumber]) {
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setFirstPageUrl:newFirstPageUrl];
			}
			else {
                //NSLog(@"[temporaryNumPagesArray objectAtIndex:2] %@", [temporaryNumPagesArray objectAtIndex:2]);
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray objectAtIndex:2] getAttributeNamed:@"href"]];
				[self setFirstPageUrl:newFirstPageUrl];
			}
			

			[self setLastPageNumber:[[[temporaryNumPagesArray lastObject] contents] intValue]];

			
			if ([self pageNumber] == [self lastPageNumber]) {
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setLastPageUrl:newLastPageUrl];
			}
			else {
                //NSLog(@"lastObject %@", [[temporaryNumPagesArray lastObject] allContents]);
                
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray lastObject] getAttributeNamed:@"href"]];
				[self setLastPageUrl:newLastPageUrl];
			}

			/*
			 NSLog(@"premiere %d", [self firstPageNumber]);			
			 NSLog(@"premiere url %@", [self firstPageUrl]);
			 
			 NSLog(@"premiere %d", [self lastPageNumber]);			
			 NSLog(@"premiere url %@", [self lastPageUrl]);		
			 */
			
			//TableFooter
			UIToolbar *tmptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
			tmptoolbar.barStyle = UIBarStyleDefault;
			[tmptoolbar sizeToFit];
			
			//Add buttons
			UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
																						 target:self
																						 action:@selector(firstPage:)];
			if ([self pageNumber] == [self firstPageNumber]) {
				[systemItem1 setEnabled:NO];
			}
			
			UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
																						 target:self
																						 action:@selector(lastPage:)];

			if ([self pageNumber] == [self lastPageNumber]) {
				[systemItem2 setEnabled:NO];
			}		
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 44)];
			[label setFont:[UIFont boldSystemFontOfSize:15.0]];
			[label setAdjustsFontSizeToFitWidth:YES];
			[label setBackgroundColor:[UIColor clearColor]];
			[label setTextAlignment:NSTextAlignmentCenter];
			[label setLineBreakMode:NSLineBreakByTruncatingMiddle];
			[label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
			
			[label setTextColor:[UIColor whiteColor]];
			[label setNumberOfLines:0];
			[label setTag:666];
			[label setText:[NSString stringWithFormat:@"%d/%d", [self pageNumber], [self lastPageNumber]]];
			
			UIBarButtonItem *systemItem3 = [[UIBarButtonItem alloc] initWithCustomView:label];
			
			
			
			
			
			//Use this to put space in between your toolbox buttons
			UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];

			//Add buttons to the array
			NSArray *items = [NSArray arrayWithObjects: systemItem1, flexItem, systemItem3, flexItem, systemItem2, nil];
			
			//release buttons
			
			//add array of buttons to toolbar
			[tmptoolbar setItems:items animated:NO];
			
			self.aToolbar = tmptoolbar;
			
		}
		else {
			self.aToolbar = nil;
			//NSLog(@"pas de pages");
            [self setFirstPageNumber:1];
            [self setLastPageNumber:1];
		}
		
		//--
		
		
		//NSArray *temporaryPagesArray = [[NSArray alloc] init];
		
		NSArray *temporaryPagesArray = [pagesTrNode findChildrenWithAttribute:@"class" matchingName:@"pagepresuiv" allowPartial:YES];
		
        if (self.isSearchIntra) {
            if (self.swipeLeftRecognizer) [self.view addGestureRecognizer:self.swipeLeftRecognizer];
        }
		else if(temporaryPagesArray.count != 3)
		{
			//NSLog(@"pas 3");
			//[self.view removeGestureRecognizer:swipeLeftRecognizer];
			//[self.view removeGestureRecognizer:swipeRightRecognizer];
		}
		else {
            HTMLNode *nextUrlNode = [[temporaryPagesArray objectAtIndex:0] findChildWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO];
            
            if (nextUrlNode) {
                //nextPageUrl = [[NSString stringWithFormat:@"%@", [topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber + 1)]]] retain];
                //nextPageUrl = [[NSString stringWithFormat:@"%@", [topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber + 1)]]] retain];
                if (self.swipeLeftRecognizer) [self.view addGestureRecognizer:self.swipeLeftRecognizer];
                self.nextPageUrl = [[nextUrlNode getAttributeNamed:@"href"] copy];
                //NSLog(@"nextPageUrl = %@", nextPageUrl);
                
            }
            else {
                self.nextPageUrl = @"";
                //[self.view removeGestureRecognizer:swipeLeftRecognizer];
            }
            
            HTMLNode *previousUrlNode = [[temporaryPagesArray objectAtIndex:1] findChildWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO];
            
            if (previousUrlNode) {
                //previousPageUrl = [[topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber - 1)]] retain];
                if (self.swipeRightRecognizer) [self.view addGestureRecognizer:self.swipeRightRecognizer];
                self.previousPageUrl = [[previousUrlNode getAttributeNamed:@"href"] copy];
                //NSLog(@"previousPageUrl = %@", previousPageUrl);
                
            }
            else {
                self.previousPageUrl = @"";
                //[self.view removeGestureRecognizer:swipeRightRecognizer];
                
                
            }
		}
	}
	else {
		self.aToolbar = nil;
	}
	//NSLog(@"Fin setupPageToolbar");

	//--Pages
}


-(void)setupIntrSearch:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    HTMLNode * tmpSearchNode = [bodyNode findChildWithAttribute:@"action" matchingName:@"/transsearch.php" allowPartial:NO];
    if(tmpSearchNode)
    {
        [self.searchInputData removeAllObjects];
        
        
        NSArray *wantedArr = [NSArray arrayWithObjects:@"hash_check", @"p", @"post", @"cat", @"firstnum", @"currentnum", @"word", @"spseudo", @"filter", nil];
        //NSLog(@"INTRA");
        //hidden input for URL          post | cat | currentnum
        //hidden input for URL          word | spseudo | filter
        
        NSArray *arrInput = [tmpSearchNode findChildTags:@"input"];
        for (HTMLNode *no in arrInput) {
            //NSLog(@"%@ = %@", [no getAttributeNamed:@"name"], [no getAttributeNamed:@"value"]);
            
            if ([no getAttributeNamed:@"name"] && [wantedArr indexOfObject: [no getAttributeNamed:@"name"]] != NSNotFound) {
                
                //NSLog(@"WANTED %lu", (unsigned long)[wantedArr indexOfObject: [no getAttributeNamed:@"name"]]);
                if (![[no getAttributeNamed:@"type"] isEqualToString:@"checkbox"] || ([[no getAttributeNamed:@"type"] isEqualToString:@"checkbox"] && [[no getAttributeNamed:@"checked"] isEqualToString:@"checked"])) {
                    [self.searchInputData setValue:[no getAttributeNamed:@"value"] forKey:[no getAttributeNamed:@"name"]];
                }
                
                if ([[no getAttributeNamed:@"name"] isEqualToString:@"word"]) {
                    [self.searchKeyword setText:[no getAttributeNamed:@"value"]];
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"spseudo"]) {
                    [self.searchPseudo setText:[no getAttributeNamed:@"value"]];
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"filter"]) {
                    //NSLog(@"name %@ = %@", [no getAttributeNamed:@"name"], [no getAttributeNamed:@"checked"]);
                    if ([[no getAttributeNamed:@"checked"] isEqualToString:@"checked"]) {
                        //NSLog(@"FILTER ON");
                        [self.searchFilter setOn:YES animated:NO];
                    }
                    else {
                        //NSLog(@"FILTER OFF");
                        [self.searchFilter setOn:NO animated:NO];
                    }
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"currentnum"]) {
                    [self.searchFromFP setOn:NO animated:NO];
                }
            }
        }
        
    }
    else if (self.searchInputData.count) {
        if ([self.searchInputData valueForKey:@"word"]) {
            [self.searchKeyword setText:[self.searchInputData valueForKey:@"word"]];
        }
        
        if ([self.searchInputData valueForKey:@"spseudo"]) {
            [self.searchPseudo setText:[self.searchInputData valueForKey:@"spseudo"]];
        }
        
        if ([self.searchInputData valueForKey:@"filter"]) {
            [self.searchFilter setOn:YES animated:NO];
        }
        
        if (![self.searchInputData valueForKey:@"currentnum"] && ![self.searchInputData valueForKey:@"firstnum"]) {
            [self.searchFromFP setOn:YES animated:NO];
        }
        else {
            [self.searchFromFP setOn:NO animated:NO];
        }
    }
}



-(HTMLNode *)loadDataInTableView:(HTMLParser *)myParser
{
    NSLog(@"loadDataInTableView MTVC");

	[self setupScrollAndPage];

    HTMLNode *bodyNode = [super loadDataInTableView:myParser];

    [self setupIntrSearch:bodyNode andP:myParser];

	//--Pages
	[self setupPageToolbar:bodyNode andP:myParser];
    self.navigationItem.rightBarButtonItem.enabled = YES;

    return bodyNode;
}


- (void)viewDidUnload {
    NSLog(@"viewDidUnload Messages Table View");
    [super viewDidUnload];

    [self setSearchFromFP:nil];
    [self setSearchFilter:nil];
    
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad %@", self.topicName);


    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleTap:)];
    [self.searchBg addGestureRecognizer:tapRecognizer];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
    
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // 
    
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [label setTextColor:[UIColor blackColor]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [label setFont:[UIFont boldSystemFontOfSize:13.0]];
        }
        else {
            [label setFont:[UIFont boldSystemFontOfSize:17.0]];
        }
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [label setTextColor:[UIColor whiteColor]];
            label.shadowColor = [UIColor darkGrayColor];
            [label setFont:[UIFont boldSystemFontOfSize:13.0]];
            label.shadowOffset = CGSizeMake(0.0, -1.0);
            
            
        }
        else {
            [label setTextColor:[UIColor colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00]];
            label.shadowColor = [UIColor whiteColor];
            [label setFont:[UIFont boldSystemFontOfSize:19.0]];
            label.shadowOffset = CGSizeMake(0.0, 0.5f);
            
        }
        
    }
    
    [label setNumberOfLines:2];
    
    [label setText:self.topicName];
    [label adjustFontSizeToFit];
    [self.navigationItem setTitleView:label];
    
	//Gesture
    if (self.gestureEnabled) {
        UIGestureRecognizer *recognizer;

        //De Gauche à droite
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRight:)];
        self.swipeRightRecognizer = (UISwipeGestureRecognizer *)recognizer;

        //De Droite à gauche
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToLeft:)];
        self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
    }
	//-- Gesture


	//Bouton Repondre message
    
    if (self.isSearchIntra) {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchTopic)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    else {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionsTopic:)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    

	[(ShakeView*)self.view setShakeDelegate:self];
	
    
    

    if (!self.searchInputData) {
        NSLog(@"NO searchInputData");
        self.searchInputData = [[NSMutableDictionary alloc] init];
    }


    [super viewDidLoad];

}

-(void)fullScreen {
    [self fullScreen:nil];
}

-(void)fullScreen:(id)sender {
    
    if ([(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController respondsToSelector:@selector(MoveRightToLeft)]) {
        [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController MoveRightToLeft];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"clickedButtonAtIndex %d", buttonIndex);
    
    if (buttonIndex < self.arrayActionsMessages.count) {
        NSLog(@"action %@", [self.arrayActionsMessages objectAtIndex:buttonIndex]);
        if ([self respondsToSelector:NSSelectorFromString([[self.arrayActionsMessages objectAtIndex:buttonIndex] objectForKey:@"code"])])
        {
            //[self performSelector:];
            [self performSelectorOnMainThread:NSSelectorFromString([[self.arrayActionsMessages objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:nil waitUntilDone:NO];
        }
        else {
            NSLog(@"CRASH not respondsToSelector %@", [[self.arrayActionsMessages objectAtIndex:buttonIndex] objectForKey:@"code"]);
            
            [self performSelectorOnMainThread:NSSelectorFromString([[self.arrayActionsMessages objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:nil waitUntilDone:NO];
            
        }
    }
    
}



-(void)searchTopic {

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    

    [self toggleSearch];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if(self.detailViewController) self.detailViewController = nil;
	if(self.messagesTableViewController) self.messagesTableViewController = nil;
 
}

- (void)viewDidDisappear:(BOOL)animated {
	//NSLog(@"viewDidDisappear");

    [super viewDidDisappear:animated];
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

#pragma mark -
#pragma mark Gestures

-(void) shakeHappened:(ShakeView*)view
{
    //NSLog(@"shake");
	if (![request inProgress] && !self.isLoading) {
        //NSLog(@"shake OK");
		[self searchNewMessages:kNewMessageFromShake];
	}
    else {
        //NSLog(@"shake KO");
    }
}

- (void)handleSwipeToLeft:(UISwipeGestureRecognizer *)recognizer {
    
    if (self.isSearchIntra) {
        NSLog(@"isSearchInstra");

        [self searchSubmit:nil];
    }
    else {
        NSLog(@"NEXT");

        [self nextPage:recognizer];
    }
}
- (void)handleSwipeToRight:(UISwipeGestureRecognizer *)recognizer {
    if (!self.isSearchIntra && (self.searchBg.alpha == 0.0 || self.searchBg.hidden == YES)) {
        [self previousPage:recognizer];
    }
}

#pragma mark -
#pragma mark AddMessage Delegate
-(BOOL) canBeFavorite{
	if ([self isUnreadable]) {
		return NO;
	}
	
	
	return YES;
}


- (NSString*)generateHTMLToolbar {

    NSString *tooBar = @"";

    //Toolbar;
    if (self.aToolbar && !self.isSearchIntra) {
        NSString *buttonBegin, *buttonEnd;
        NSString *buttonPrevious, *buttonNext;

        if ([(UIBarButtonItem *)[self.aToolbar.items objectAtIndex:0] isEnabled]) {
            buttonBegin = @"<div class=\"button begin active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://begin\">begin</a></div>";
            buttonPrevious = @"<div class=\"button2 begin active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://previous\">previous</a></div>";
        }
        else {
            buttonBegin = @"<div class=\"button begin\"></div>";
            buttonPrevious = @"<div class=\"button2 begin\"></div>";
        }

        if ([(UIBarButtonItem *)[self.aToolbar.items objectAtIndex:4] isEnabled]) {
            buttonEnd = @"<div class=\"button end active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://end\">end</a></div>";
            buttonNext = @"<div class=\"button2 end active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://next\">next</a></div>";
        }
        else {
            buttonEnd = @"<div class=\"button end\"></div>";
            buttonNext = @"<div class=\"button2 end\"></div>";
        }


        //[NSString stringWithString:@"<div class=\"button end\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://end\">end</a></div>"];

        tooBar =  [NSString stringWithFormat:@"<div id=\"toolbarpage\">\
                   %@\
                   %@\
                   <a href=\"oijlkajsdoihjlkjasdoauto://choose\">%d/%d</a>\
                   %@\
                   %@\
                   </div>", buttonBegin, buttonPrevious, [self pageNumber], [self lastPageNumber], buttonNext, buttonEnd];
    }
    else if (self.isSearchIntra) {
        tooBar = [NSString stringWithFormat:@"<a href=\"oijlkajsdoihjlkjasdoauto://submitsearch\" id=\"searchintra_nextbutton\">Résultats suivants &raquo;</a>"];
    }
    return tooBar;
}

#pragma mark -
#pragma mark Search Lifecycle

-(void)handleTap:(id)sender{
    [self toggleSearch:NO];
}

- (void)toggleSearch {
    
    if (self.searchBg.alpha && !self.searchBg.hidden)
        [self toggleSearch:NO];
    else
        [self toggleSearch:YES];
    
}

- (void)toggleSearch:(BOOL) active {
    //NSLog(@"toggleSearchtoggleSearchtoggleSearchtoggleSearch");
    if (!active) {
        //NSLog(@"RESIGN");
        CGRect oldframe = self.searchBox.frame;
        //NSLog(@"oldframe %@", NSStringFromCGRect(oldframe));
        
        CGRect newframe = oldframe;
        newframe.origin.y = 0 - oldframe.size.height;
        
        [self.searchKeyword resignFirstResponder];
        [self.searchPseudo resignFirstResponder];
        
        [UIView beginAnimations:@"FadeOut" context:nil];
        [UIView setAnimationDuration:0.2];
        [self.searchBg setAlpha:0];
        self.searchBox.frame = newframe;
        
        [UIView commitAnimations];

    } else {
        //NSLog(@"BECOME");
        CGRect oldframe = self.searchBox.frame;
        //NSLog(@"oldframe %@", NSStringFromCGRect(oldframe));
        
        CGRect newframe = oldframe;
        newframe.origin.y = 0 - oldframe.size.height;
        oldframe.origin.y = 0;
        self.searchBox.frame = newframe;
        [self.searchBox setHidden:NO];
        [self.searchBg setAlpha:0];
        [self.searchBg setHidden:NO];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.searchBg setAlpha:0.7];
            self.searchBox.frame = oldframe;
        } completion:^(BOOL finished){
            [self.searchKeyword becomeFirstResponder];
        }];

    }
}

- (IBAction)searchNext:(UITextField *)sender {
    //NSLog(@"searchNext %@", sender);
        if ([sender isEqual:self.searchKeyword]) {
            //NSLog(@"searchKeyword");
            [self.searchKeyword resignFirstResponder];
            [self.searchPseudo becomeFirstResponder];
        }
        else if ([sender isEqual:self.searchPseudo] && (self.searchPseudo.text.length > 0 || self.searchKeyword.text.length > 0)) {
            //NSLog(@"searchPseudo");
            [self.searchPseudo resignFirstResponder];
            
            [self searchSubmit:nil];
        }
}

- (IBAction)searchFilterChanged:(UISwitch *)sender {
    //NSLog(@"Filter %lu", (unsigned long)sender.isOn);
    
    if (sender.isOn) {
      [self.searchInputData setValue:[NSString stringWithFormat:@"%d", sender.isOn] forKey:@"filter"];
    }
    else {
        [self.searchInputData removeObjectForKey:@"filter"];
    }
}

- (IBAction)searchFromFPChanged:(UISwitch *)sender {
    //NSLog(@"searchFromFPChanged %lu", (unsigned long)sender.isOn);
    
    if (sender.isOn) {
        [self.searchInputData removeObjectForKey:@"currentnum"];
        [self.searchInputData removeObjectForKey:@"firstnum"];
    }
}

- (IBAction)searchPseudoChanged:(UITextField *)sender {
    //NSLog(@"searchPseudoChanged %@", sender.text);
    if ([sender.text length]) {
        [self.searchInputData setValue:[NSString stringWithFormat:@"%@", sender.text] forKey:@"spseudo"];
    }
    else {
        [self.searchInputData setValue:@"" forKey:@"spseudo"];
    }
    
}

- (IBAction)searchKeywordChanged:(UITextField *)sender {
    //NSLog(@"searchKeywordChanged %@", sender.text);
    if ([sender.text length]) {
        [self.searchInputData setValue:[NSString stringWithFormat:@"%@", sender.text] forKey:@"word"];
    }
    else {
        [self.searchInputData setValue:@"" forKey:@"word"];
    }

}

- (IBAction)searchSubmit:(UIBarButtonItem *)sender {
    NSLog(@"searchSubmit");
    
    //NSString *baseURL = [NSString stringWithFormat:@"/forum2.php?%@", [self serializeParams:self.searchInputData]];

    ASIFormDataRequest  *arequest = [[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/transsearch.php", kForumURL]]];
    
    for (NSString *key in self.searchInputData) {
        [arequest setPostValue:[self.searchInputData objectForKey:key] forKey:key];
        //NSLog(@"POST: %@ : %@", key, [self.searchInputData objectForKey:key]);
    }
    
    [arequest setShouldRedirect:NO];
    [arequest startSynchronous];
    
    NSString *baseURL = @"";
    
    if (arequest) {
        NSString *Location = [[arequest responseHeaders] objectForKey:@"Location"];
        NSLog(@"responseHeaders: %@", [arequest responseHeaders]);
        NSLog(@"requestHeaders: %@", [arequest requestHeaders]);

        if ([arequest error]) {
            NSLog(@"error: %@", [[arequest error] localizedDescription]);
        }
        else if ([arequest responseString])
        {
            baseURL = Location;
            //NSLog(@"responseString %@", [arequest responseString]);
        }
    }
    
    if (!baseURL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Aucune réponse n'a été trouvée"
                                                       delegate:self cancelButtonTitle:@"Affiner" otherButtonTitles:nil, nil];
        
        [alert setTag:780];
        [alert show];
        return;
    }
    
    [self toggleSearch:NO];

    if (self.isSearchIntra) {
        self.currentUrl = baseURL;
        [self fetchContent:kNewMessageFromUnkwn];
    }
    else {
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:baseURL];

        //setup the URL
        [aView setTopicName:[NSString stringWithString:self.topicName]];
        [aView setSearchInputData:[NSMutableDictionary dictionaryWithDictionary:self.searchInputData]];

        aView.isViewed = YES;
        aView.isSearchIntra = YES;

        self.messagesTableViewController = aView;


        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                         style: UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }
        
        [self.navigationController pushViewController:messagesTableViewController animated:YES];
    }

}


-(NSString *)serializeParams:(NSDictionary *)params {
    /*
     
     Convert an NSDictionary to a query string
     
     */
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)[value objectForKey:subKey],
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)subValue,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else {
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)[params objectForKey:key],
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

/*


 NSString *firstPostID = [[self.arrayData objectAtIndex:0] postID];
 NSLog(@">>>> DELETE TEST %@", firstPostID);

 NSLog(@">>>> DELETE TEST A %@", self.arrayData);

 [self.arrayData removeObjectForKey:firstPostID];

 NSLog(@">>>> DELETE TEST B %@", self.arrayData);

 NSLog(@"%@", [NSString stringWithFormat:@"\
 var elemt = $('#%@');\
 var okh = $(window).scrollTop();\
 var eh = elemt.outerHeight();\
 elemt.remove();\
 $(window).scrollTop( okh - eh );", firstPostID]);


 dispatch_async(dispatch_get_main_queue(),
 ^{
 [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
 var elemt = $('#%@');\
 var okh = $(window).scrollTop();\
 var eh = elemt.outerHeight();\
 elemt.remove();\
 $(window).scrollTop( okh - eh );", firstPostID]];
 });

 NSLog(@">>>> DELETE TEST FIN");
 */
@end