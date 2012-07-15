//
//  TopicsTableViewController.m
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import "HFRplusAppDelegate.h"

#import "ASIHTTPRequest.h"
#import "HTMLParser.h"

#import "ShakeView.h"

#import "TopicsTableViewController.h"
#import "MessagesTableViewController.h"
#import "HFRMPViewController.h"

//#import "TopicsCell.h"
#import "TopicCellView.h"
#import "Topic.h"

#import "SubCatTableViewController.h"


@implementation TopicsTableViewController
@synthesize forumNewTopicUrl, forumName, loadingView, topicsTableView, arrayData;
@synthesize messagesTableViewController;

@synthesize swipeLeftRecognizer, swipeRightRecognizer;

@synthesize pressedIndexPath;
@synthesize imageForSelectedRow, imageForUnselectedRow;

@synthesize imageForRedFlag, imageForYellowFlag, imageForBlueFlag;

@synthesize forumBaseURL, forumFavorisURL, forumFlag1URL, forumFlag0URL;

@synthesize request;

@synthesize myPickerView, pickerViewArray, actionSheet;


@synthesize tmpCell;
@synthesize status, statusMessage, maintenanceView, selectedFlagIndex;

@synthesize popover = _popover;

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"fetchContent %@", [NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]);
	self.status = kIdle;
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];

	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]]]];
	[request setShouldRedirect:NO];

	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];


	[self.view removeGestureRecognizer:swipeLeftRecognizer];
	[self.view removeGestureRecognizer:swipeRightRecognizer];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	[self.maintenanceView setHidden:YES];
	usleep(50000);
	[self.topicsTableView setHidden:YES];
	[self.loadingView setHidden:NO];
	
	//--
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	
	[self.arrayData removeAllObjects];
	[self.topicsTableView reloadData];
	
	[self loadDataInTableView:[request responseData]];

	[self.loadingView setHidden:YES];

	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:            
			[self.maintenanceView setText:self.statusMessage];
			[self.maintenanceView setHidden:NO];
			[self.topicsTableView setHidden:YES];
			break;
		default:
			[self.topicsTableView reloadData];			
			[self.topicsTableView setHidden:NO];			
			break;
	}

	
	[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:YES];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{

	[self.loadingView setHidden:YES];
	[self.maintenanceView setHidden:YES];
	
	[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:667];
	[alert show];
	[alert release];	
}


#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		NSLog(@"initWithNibName TTVC");
		
        self.selectedFlagIndex = 0;
        
    }
    return self;
}

-(void)loadDataInTableView:(NSData *)contentData
{
	
	[self.view removeGestureRecognizer:swipeLeftRecognizer];
	[self.view removeGestureRecognizer:swipeRightRecognizer];	
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];

	//NSLog(@"rawContentsOfNode %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));
	
	if (![bodyNode getAttributeNamed:@"id"]) {
		//NSLog(@"kNoResults"); 
		if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
			//NSLog(@"p");
			
			self.status = kMaintenance;
			self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			[myParser release];
			return;
		}
		
		self.status = kNoAuth;
		self.statusMessage = [[[bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[myParser release];
		return;		
	}

	
	//MP
	BOOL needToUpdateMP = NO;
	HTMLNode *MPNode = [bodyNode findChildOfClass:@"none"]; //Get links for cat	
	NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
	
	if (temporaryMPArray.count == 3) {
		
		NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";			
		NSString *myMPNumber = [[[temporaryMPArray objectAtIndex:1] allContents] stringByReplacingOccurrencesOfRegex:regExMP
																										  withString:@"$1"];
		
		[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
	}
	else {
		if ([self isKindOfClass:[HFRMPViewController class]]) {
			needToUpdateMP = YES;
		}
	}
	//MP

	//On remplace le numéro de page dans le titre
	NSString *regexString  = @".*page=([^&]+).*";
	NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
	NSRange   searchRange = NSMakeRange(0, self.currentUrl.length);
	NSError  *error2        = NULL;
	//int numPage;
	
	matchedRange = [self.currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
	
	if (matchedRange.location == NSNotFound) {
		NSRange rangeNumPage =  [[self currentUrl] rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
		self.pageNumber = [[self.currentUrl substringWithRange:rangeNumPage] intValue];
	}
	else {
		self.pageNumber = [[self.currentUrl substringWithRange:matchedRange] intValue];
		
	}
	
	//[(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.forumName, numPage]];
	//NSLog(@"forumUrl %@ — %d", [self forumName], numPage); 
	
	
	//New Topic URL
	HTMLNode * forumNewTopicNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"md_btn_new_topic" allowPartial:NO];
	forumNewTopicUrl = [[forumNewTopicNode getAttributeNamed:@"href"] retain];

	if(forumNewTopicUrl.length > 0) self.navigationItem.rightBarButtonItem.enabled = YES;
	//-

	//Filtres
	HTMLNode *FiltresNode =		[bodyNode findChildWithAttribute:@"class" matchingName:@"cadreonglet" allowPartial:NO];
	
	if([FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet1" allowPartial:NO]) self.forumBaseURL = [[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet1" allowPartial:NO] getAttributeNamed:@"href"];
	if ([[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet2" allowPartial:NO] getAttributeNamed:@"href"]) {
		if(!self.forumFavorisURL)	self.forumFavorisURL = [[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet2" allowPartial:NO] getAttributeNamed:@"href"];
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:YES forSegmentAtIndex:1];		
	}
	else {
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:NO forSegmentAtIndex:1];
	}

	if ([[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet3" allowPartial:NO] getAttributeNamed:@"href"]) {
		if(!self.forumFlag1URL)		self.forumFlag1URL = [[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet3" allowPartial:NO] getAttributeNamed:@"href"];
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:YES forSegmentAtIndex:2];		
	}
	else {
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:NO forSegmentAtIndex:2];
	}	

	if ([[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet4" allowPartial:NO] getAttributeNamed:@"href"]) {
		if(!self.forumFlag0URL)		self.forumFlag0URL = [[FiltresNode findChildWithAttribute:@"id" matchingName:@"onglet4" allowPartial:NO] getAttributeNamed:@"href"];
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:YES forSegmentAtIndex:3];
	}
	else {
		[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setEnabled:NO forSegmentAtIndex:3];
	}
	//NSLog(@"Filtres1Node %@", rawContentsOfNode([Filtres1Node _node], [myParser _doc]));
	//-- FIN Filtre

	HTMLNode * pagesTrNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum1PagesHaut" allowPartial:YES];

	
	if(pagesTrNode)
	{	
		HTMLNode * pagesLinkNode = [pagesTrNode findChildWithAttribute:@"class" matchingName:@"left" allowPartial:NO];
		
		//NSLog(@"pagesLinkNode %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));

		if (pagesLinkNode) {
			//NSLog(@"pagesLinkNode %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));
			
			//NSArray *temporaryNumPagesArray = [[NSArray alloc] init];
			NSArray *temporaryNumPagesArray = [pagesLinkNode children];
			
			[self setFirstPageNumber:[[[temporaryNumPagesArray objectAtIndex:2] contents] intValue]];
			
			if ([self pageNumber] == [self firstPageNumber]) {
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setFirstPageUrl:newFirstPageUrl];
				[newFirstPageUrl release];
			}
			else {
				NSString *newFirstPageUrl;
				
				if ([[[temporaryNumPagesArray objectAtIndex:2] tagName] isEqualToString:@"span"]) {
					newFirstPageUrl = [[NSString alloc] initWithString:[[[temporaryNumPagesArray objectAtIndex:2] className] decodeSpanUrlFromString2]];
				}
				else {
					newFirstPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray objectAtIndex:2] getAttributeNamed:@"href"]];
				}
				
				[self setFirstPageUrl:newFirstPageUrl];
				[newFirstPageUrl release];
			}
			
			[self setLastPageNumber:[[[temporaryNumPagesArray lastObject] contents] intValue]];
			
			if ([self pageNumber] == [self lastPageNumber]) {
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setLastPageUrl:newLastPageUrl];
				[newLastPageUrl release];
			}
			else {
				NSString *newLastPageUrl;
				
				if ([[[temporaryNumPagesArray lastObject] tagName] isEqualToString:@"span"]) {
					newLastPageUrl = [[NSString alloc] initWithString:[[[temporaryNumPagesArray lastObject] className] decodeSpanUrlFromString2]];
				}
				else {
					newLastPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray lastObject] getAttributeNamed:@"href"]];
				}
				
				[self setLastPageUrl:newLastPageUrl];
				[newLastPageUrl release];
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

			UIBarButtonItem *systemItemNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowforward"] 
																			   style:UIBarButtonItemStyleBordered 
																			  target:self 
																			  action:@selector(nextPage:)];

			
			//systemItemNext.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);
			
			UIBarButtonItem *systemItemPrevious = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowback"] 
																			   style:UIBarButtonItemStyleBordered 
																			  target:self 
																			  action:@selector(previousPage:)];	

			//systemItemPrevious.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);


			
			
			UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowbegin"] 
																				   style:UIBarButtonItemStyleBordered 
																				  target:self 
																				  action:@selector(firstPage:)];	
			
			//systemItem1.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);

			if ([self pageNumber] == [self firstPageNumber]) {
				[systemItem1 setEnabled:NO];
				[systemItemPrevious setEnabled:NO];
			}
			
			UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowend"] 
																			style:UIBarButtonItemStyleBordered 
																		   target:self 
																		   action:@selector(lastPage:)];	
			
			//systemItem2.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);

			if ([self pageNumber] == [self lastPageNumber]) {
				[systemItem2 setEnabled:NO];
				[systemItemNext setEnabled:NO];
			}		

			UIButton *labelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			labelBtn.frame = CGRectMake(0, 0, 130, 44);
			[labelBtn addTarget:self action:@selector(choosePage) forControlEvents:UIControlEventTouchUpInside];
			[labelBtn setTitle:[NSString stringWithFormat:@"%d/%d", [self pageNumber], [self lastPageNumber]] forState:UIControlStateNormal];
			[[labelBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0]];

			UIBarButtonItem *systemItem3 = [[UIBarButtonItem alloc] initWithCustomView:labelBtn];
			
			//Use this to put space in between your toolbox buttons
			UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];
			UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																					  target:nil
																					  action:nil];
			fixItem.width = 0.0;
			
			//Add buttons to the array
			NSArray *items = [NSArray arrayWithObjects: systemItem1, fixItem, systemItemPrevious, flexItem, systemItem3, flexItem, systemItemNext, fixItem, systemItem2, nil];
			
			//release buttons
			[systemItem1 release];
			[systemItem2 release];
			[systemItem3 release];
			[systemItemNext release];
			[systemItemPrevious release];
			
			[flexItem release];
			
			[fixItem release];	
			
			//add array of buttons to toolbar
			[tmptoolbar setItems:items animated:NO];
			
			if ([self firstPageNumber] != [self lastPageNumber]) {
				self.topicsTableView.tableFooterView = tmptoolbar;
			}
			else {
				self.topicsTableView.tableFooterView = nil;
			}

			//self.aToolbar = tmptoolbar;
			[tmptoolbar release];
			
		}
		else {
			//self.aToolbar = nil;
			//NSLog(@"pas de pages");
			
		}
		
		//Gestion des pages
		NSArray *temporaryPagesArray = [pagesTrNode findChildrenWithAttribute:@"class" matchingName:@"pagepresuiv" allowPartial:YES];
			
		if(temporaryPagesArray.count != 2)
		{
			//NSLog(@"pas 2");	
		}
		else {
			
			HTMLNode *nextUrlNode = [[temporaryPagesArray objectAtIndex:0] findChildWithAttribute:@"class" matchingName:@"md_cryptlink" allowPartial:YES];

			if (nextUrlNode) {
				
				self.nextPageUrl = [[nextUrlNode className] decodeSpanUrlFromString2];
				[self.view addGestureRecognizer:swipeLeftRecognizer];
				//NSLog(@"nextPageUrl = %@", self.nextPageUrl);

			}
			else {
				self.nextPageUrl = @"";
			}
			
			HTMLNode *previousUrlNode = [[temporaryPagesArray objectAtIndex:1] findChildWithAttribute:@"class" matchingName:@"md_cryptlink" allowPartial:YES];
			
			if (previousUrlNode) {
				
				self.previousPageUrl = [[previousUrlNode className] decodeSpanUrlFromString2];
				[self.view addGestureRecognizer:swipeRightRecognizer];
				//NSLog(@"previousPageUrl = %@", self.previousPageUrl);

			}
			else {
				self.previousPageUrl = @"";
			}

		}
		//-- Gestion des pages
			
		
	}

	
	NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"sujet ligne_booleen" allowPartial:YES]; //Get links for cat

	if (temporaryTopicsArray.count == 0) {
		//NSLog(@"Aucun nouveau message %d", self.arrayDataID.count);
		self.status = kNoResults;
		self.statusMessage = @"Aucun message";
		[myParser release];
		return;
	}
	
	
	//Date du jour
	NSDate *nowTopic = [[NSDate alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd-MM-yyyy"];
	NSString *theDate = [dateFormat stringFromDate:nowTopic];
	
	int countViewed = 0;
	

	for (HTMLNode * topicNode in temporaryTopicsArray) { //Loop through all the tags
        
		NSAutoreleasePool * pool2 = [[NSAutoreleasePool alloc] init];

		Topic *aTopic = [[Topic alloc] init];
		
		//Title & URL
		HTMLNode * topicTitleNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase3" allowPartial:NO];

		NSString *aTopicAffix = [[NSString alloc] init];
		NSString *aTopicSuffix = [[NSString alloc] init];

		
		if ([[topicNode className] rangeOfString:@"ligne_sticky"].location != NSNotFound) {
			aTopicAffix = [aTopicAffix stringByAppendingString:@""];//➫ ➥▶✚
		}
		if ([topicTitleNode findChildWithAttribute:@"alt" matchingName:@"closed" allowPartial:NO]) {
			aTopicAffix = [aTopicAffix stringByAppendingString:@""];
		}
		
		if (aTopicAffix.length > 0) {
			aTopicAffix = [aTopicAffix stringByAppendingString:@" "];
		}

		NSString *aTopicTitle = [[NSString alloc] initWithFormat:@"%@%@%@", aTopicAffix, [[topicTitleNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], aTopicSuffix];
		[aTopic setATitle:aTopicTitle];
		[aTopicTitle release];

		NSString *aTopicURL = [[NSString alloc] initWithString:[[topicTitleNode findChildTag:@"a"] getAttributeNamed:@"href"]];
		[aTopic setAURL:aTopicURL];
		[aTopicURL release];

		//Answer Count
		HTMLNode * numRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase7" allowPartial:NO];
		[aTopic setARepCount:[[numRepNode contents] intValue]];


		//Setup of Flag		
		HTMLNode * topicFlagNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase5" allowPartial:NO];
		HTMLNode * topicFlagLinkNode = [topicFlagNode findChildTag:@"a"];
		if (topicFlagLinkNode) {
			HTMLNode * topicFlagImgNode = [topicFlagLinkNode firstChild];

			NSString *aURLOfFlag = [[NSString alloc] initWithString:[topicFlagLinkNode getAttributeNamed:@"href"]];
			[aTopic setAURLOfFlag:aURLOfFlag];
			[aURLOfFlag release];
			
			NSString *imgFlagSrc = [[NSString alloc] initWithString:[topicFlagImgNode getAttributeNamed:@"src"]];
			
			if (!([imgFlagSrc rangeOfString:@"flag0.gif"].location == NSNotFound)) {
				[aTopic setATypeOfFlag:@"red"];
			}
			else if (!([imgFlagSrc rangeOfString:@"flag1.gif"].location == NSNotFound)) {
				[aTopic setATypeOfFlag:@"blue"];
			}
			else if (!([imgFlagSrc rangeOfString:@"favoris.gif"].location == NSNotFound)) {
				[aTopic setATypeOfFlag:@"yellow"];
			}
		
			[imgFlagSrc release];
		}
		else {
			[aTopic setAURLOfFlag:@""];
			[aTopic setATypeOfFlag:@""];
		}

		//Viewed?
		[aTopic setIsViewed:YES];
		HTMLNode * viewedNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase1" allowPartial:YES];
		HTMLNode * viewedFlagNode = [viewedNode findChildTag:@"img"];
		if (viewedFlagNode) {
			NSString *viewedFlagAlt = [viewedFlagNode getAttributeNamed:@"alt"];
		
			if ([viewedFlagAlt isEqualToString:@"On"]) {
				[aTopic setIsViewed:NO];
				countViewed++;
			}

		}


		//aAuthorOrInter
		HTMLNode * interNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase6" allowPartial:YES];	
                
		if ([[interNode findChildTag:@"a"] contents]) {
			NSString *aAuthorOrInter = [[NSString alloc] initWithFormat:@"%@", [[interNode findChildTag:@"a"] contents]];
            [aTopic setAAuthorOrInter:aAuthorOrInter];
			[aAuthorOrInter release];
		}
		else if ([[interNode findChildTag:@"span"] contents]) {
			NSString *aAuthorOrInter = [[NSString alloc] initWithFormat:@"%@", [[interNode findChildTag:@"span"] contents]];
			[aTopic setAAuthorOrInter:aAuthorOrInter];
			[aAuthorOrInter release];
		}
		else {
			[aTopic setAAuthorOrInter:@""];
		}



		//Author & Url of Last Post & Date
		HTMLNode * lastRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase9" allowPartial:YES];		
		HTMLNode * linkLastRepNode = [lastRepNode firstChild];
        
        if ([[linkLastRepNode findChildTag:@"b"] contents]) {
            NSString *aAuthorOfLastPost = [[NSString alloc] initWithFormat:@"%@", [[linkLastRepNode findChildTag:@"b"] contents]];
            [aTopic setAAuthorOfLastPost:aAuthorOfLastPost];
            [aAuthorOfLastPost release];
        }
		else {
			[aTopic setAAuthorOfLastPost:@""];
		}
		
		NSString *aURLOfLastPost = [[NSString alloc] initWithString:[linkLastRepNode getAttributeNamed:@"href"]];
		[aTopic setAURLOfLastPost:aURLOfLastPost];
		[aURLOfLastPost release];
		

		NSString *maDate = [linkLastRepNode contents];
		if ([theDate isEqual:[maDate substringToIndex:10]]) {
			[aTopic setADateOfLastPost:[maDate substringFromIndex:13]];
		}
		else {
			[aTopic setADateOfLastPost:[NSString stringWithFormat:@"%@/%@/%@", [maDate substringWithRange:NSMakeRange(0, 2)]
								  , [maDate substringWithRange:NSMakeRange(3, 2)]
								  , [maDate substringWithRange:NSMakeRange(8, 2)]]];
		}

		//URL of Last Page & maxPage
		HTMLNode * topicLastPageNode = [[topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase4" allowPartial:NO] findChildTag:@"a"];
		if (topicLastPageNode) {
			NSString *aURLOfLastPage = [[NSString alloc] initWithString:[topicLastPageNode getAttributeNamed:@"href"]];
			[aTopic setAURLOfLastPage:aURLOfLastPage];
			[aURLOfLastPage release];
            [aTopic setMaxTopicPage:[[topicLastPageNode contents] intValue]];

		}
		else {
			[aTopic setAURLOfLastPage:[aTopic aURL]];
            [aTopic setMaxTopicPage:1];
            
		}
        
		[self.arrayData addObject:aTopic];

		[aTopic release];		
		[pool2 drain];
		
	}
	
	if (needToUpdateMP) {
		//NSLog(@"J'update avec countViewed");
		[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:[NSString stringWithFormat:@"%d", countViewed]];
	}
	
	[dateFormat release];
	[nowTopic release];
	[myParser release];
	
	//NSDate *now = [NSDate date]; // Create a current date
	
	//NSLog(@"TOPICS Time elapsed initWithContentsOfURL : %f", [then0 timeIntervalSinceDate:then]);
	//NSLog(@"TOPICS Time elapsed initWithData          : %f", [then1 timeIntervalSinceDate:then0]);
	//NSLog(@"TOPICS Time elapsed myParser              : %f", [then2 timeIntervalSinceDate:then1]);
	//NSLog(@"TOPICS Time elapsed arraydata             : %f", [now timeIntervalSinceDate:then2]);
	//NSLog(@"TOPICS Time elapsed Total                 : %f", [now timeIntervalSinceDate:then]);
	self.status = kComplete;

}

-(void)reset
{
	NSLog(@"TOPIC RESET");
	//[self viewDidUnload];
	[self.arrayData removeAllObjects];
	
	[self.topicsTableView reloadData];
	
	[self.topicsTableView setHidden:YES];
	[self.maintenanceView setHidden:YES];	
	[self.loadingView setHidden:YES];		
}

-(NSString *)newTopicTitle
{
	return @"Nouv. Sujet";	
}

-(void)newTopic
{
	//[[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", forumNewTopicUrl]];

	NewMessageViewController *editMessageViewController = [[NewMessageViewController alloc]
															initWithNibName:@"AddMessageViewController" bundle:nil];
	editMessageViewController.delegate = self;
	[editMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", kForumURL, forumNewTopicUrl]];
	editMessageViewController.title = [self newTopicTitle];
	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:editMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
	
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[editMessageViewController release];

}

-(void)loadSubCat
{
    [_popover dismissPopoverAnimated:YES];
    
	//NSLog(@"curName %@", self.forumName);
	
	//NSLog(@"newName %@", [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle]);

	if (![self.forumName isEqualToString:[[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle]]) {
		//NSLog(@"On switch");
		self.currentUrl = [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aURL];
		self.forumName = [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle];
		self.forumBaseURL = self.currentUrl;

		self.forumFavorisURL = nil;
		self.forumFlag1URL = nil;
		self.forumFlag0URL = nil;	
			
		self.title = forumName;
		
		if ([(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] selectedSegmentIndex] == 0) {
			[self segmentFilterAction];
		}
		else {
			[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setSelectedSegmentIndex:0];
		}
	}
	else {
		
	}
	
	[self dismissActionSheet];

}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = forumName;
    
    NSLog(@"viewDidLoad %d", selectedFlagIndex);
    
          
	//NSLog(@"viewDidLoad %@ - %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSubCat) name:@"SubCatSelected" object:nil];
        
	//Gesture
	UIGestureRecognizer *recognizer;
	
	//De Gauche à droite
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRight:)];
	self.swipeRightRecognizer = (UISwipeGestureRecognizer *)recognizer;
	
	[self.view addGestureRecognizer:swipeRightRecognizer];
	
	self.swipeRightRecognizer = (UISwipeGestureRecognizer *)recognizer;
	[recognizer release];	
	
	//De Droite à gauche
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToLeft:)];
	self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
	swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	
	[self.view addGestureRecognizer:swipeLeftRecognizer];
	
	self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
	[recognizer release];
	//-- Gesture

	//Filtres
	// "Segmented" control to the right
	//Title View
	self.navigationItem.titleView = [[UIView alloc] init];//WithFrame:CGRectMake(0, 0, 120, self.navigationController.navigationBar.frame.size.height - 14)];
	
	//Filter Control
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"global.gif"],
											 [UIImage imageNamed:@"multiplefavoris.gif"],
											 [UIImage imageNamed:@"multipleflag1.gif"],
											 [UIImage imageNamed:@"multipleflag0.gif"],												 
											 nil]];

	[segmentedControl addTarget:self action:@selector(segmentFilterAction) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;

	//NSLog(@"sg	%@", segmentedControl);
	[self.navigationItem.titleView insertSubview:segmentedControl atIndex:1];

	//SubCats Control
	UISegmentedControl *segmentedControl2 = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"icon_list_bullets.png"],
											 nil]];
	
    [segmentedControl2 setUserInteractionEnabled:NO];
    
	[segmentedControl2 addTarget:self action:@selector(segmentCatAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl2.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl2.momentary = YES;
	
	segmentedControl2.frame = CGRectMake(segmentedControl.frame.size.width + 15, 0, segmentedControl2.frame.size.width, segmentedControl2.frame.size.height);
	segmentedControl.frame = CGRectMake(5, 0, segmentedControl.frame.size.width, segmentedControl.frame.size.height);

	if (self.pickerViewArray.count == 0) {
		segmentedControl2.enabled = NO;
		segmentedControl2.alpha = 0.3;		
	}
	
	//NSLog(@"sg2	%@", segmentedControl2);
	[self.navigationItem.titleView insertSubview:segmentedControl2 atIndex:1];

	
	self.navigationItem.titleView.frame = CGRectMake(0, 0, segmentedControl.frame.size.width + 20 + segmentedControl2.frame.size.width, segmentedControl.frame.size.height);
	//NSLog(@"tv	%@", self.navigationItem.titleView);
	//NSLog(@"tv	%d", self.navigationItem.titleView.subviews.count);
	
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	segmentedControl2.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	self.navigationItem.titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

	
	[segmentedControl2 release];
	[segmentedControl release];

	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newTopic)];
    segmentBarItem.enabled = NO;
	
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	

	[(ShakeView*)self.view setShakeDelegate:self];

	self.arrayData = [[NSMutableArray alloc] init];
	self.statusMessage = [[NSString alloc] init];
	
	self.forumNewTopicUrl = [[NSString alloc] init];
	
	self.imageForUnselectedRow = [UIImage imageNamed:@"selectedrow"];
	self.imageForSelectedRow = [UIImage imageNamed:@"unselectedrow"];
	
	self.imageForRedFlag = [UIImage imageNamed:@"flagred"];
	self.imageForYellowFlag = [UIImage imageNamed:@"flagyellow"];
	self.imageForBlueFlag = [UIImage imageNamed:@"flagblue2"];
	
	
	//self.forumBaseURL = self.currentUrl;

	
	if([self isKindOfClass:[HFRMPViewController class]]) [(UISegmentedControl *)self.navigationItem.titleView setHidden:YES];

	self.topicsTableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
	
	//NSLog(@"%f", self.searchDisplayController.searchBar.frame.size.height);
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	
	myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	//myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	
	myPickerView.showsSelectionIndicator = YES;
	myPickerView.dataSource = self;
	myPickerView.delegate = self;
	
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
	
    [(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setSelectedSegmentIndex:self.selectedFlagIndex];

    // Fix iOS 5 : setSelectedSegmentIndex not working.
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        [self goFlag];
    }
    
}

- (void)goFlag {
    [(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:NO];

	switch (self.selectedFlagIndex) {
		case 0:
			self.currentUrl = self.forumBaseURL;
			break;
		case 1:
			self.currentUrl = self.forumFavorisURL;   
			break;			
		case 2:
			self.currentUrl = self.forumFlag1URL;
			break;
		case 3:
			self.currentUrl = self.forumFlag0URL;  
			break;			
		default:
			self.currentUrl = self.forumBaseURL;  
			break;
	}
    
    
	[self fetchContent];

}

- (void)segmentFilterAction
{
	switch ([(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] selectedSegmentIndex]) {
		case 0:
            self.selectedFlagIndex = 0;
			break;
		case 1:
            self.selectedFlagIndex = 1;            
			break;			
		case 2:
            self.selectedFlagIndex = 2;            
			break;
		case 3:
            self.selectedFlagIndex = 3;            
			break;			
		default:
            self.selectedFlagIndex = 0;            
			break;
	}
    
	[self goFlag];


}

- (IBAction)segmentCatAction:(id)sender
{
	
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	//NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);
	
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			//NSLog(@"segmentCatAction");
			[self showPicker:sender];
			break;		
		default:
			break;
	}
	
	
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.view becomeFirstResponder];

	
	if (self.messagesTableViewController) {
		//NSLog(@"viewWillAppear Topics Table View Dealloc MTV");

		self.messagesTableViewController = nil;
	}
    
    if (self.pressedIndexPath) 
    {
		self.pressedIndexPath = nil;
    }    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	[self.view resignFirstResponder];
	
	//Topic *aTopic = [arrayData objectAtIndex:indexPath.row];
	
	//NSLog(@"TT viewDidDisappear %@ - %@", self.topicsTableView.indexPathForSelectedRow, self.pressedIndexPath);

	if (self.pressedIndexPath) {
		NSLog(@"TT pressedIndexPath");
		
		[[self.arrayData objectAtIndex:[self.pressedIndexPath row]] setIsViewed:YES];
		[self.topicsTableView reloadData];
		
				NSLog(@"TT pressedIndexPath2");
	}
	
	if (self.topicsTableView.indexPathForSelectedRow) {
		NSLog(@"TT indexPathForSelectedRow");
		[[self.arrayData objectAtIndex:[self.topicsTableView.indexPathForSelectedRow row]] setIsViewed:YES];
		[self.topicsTableView reloadData];
	}
	
	/*[[(TopicCellView *)[topicsTableView cellForRowAtIndexPath:topicsTableView.indexPathForSelectedRow] titleLabel]setFont:[UIFont systemFontOfSize:13]];
	[topicsTableView deselectRowAtIndexPath:topicsTableView.indexPathForSelectedRow animated:NO];*/

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
	[self shakeHappened:nil];
	[self.navigationController popToViewController:self animated:NO];
	
	
}

#pragma mark -
#pragma mark Gestures
-(void) shakeHappened:(ShakeView*)view
{
	//NSLog(@"shakeHappened");
	if (![request inProgress]) {
		[self fetchContent];
	}
}

- (void)handleSwipeToLeft:(UISwipeGestureRecognizer *)recognizer {
	[self nextPage:recognizer];
}

- (void)handleSwipeToRight:(UISwipeGestureRecognizer *)recognizer {
	[self previousPage:recognizer];
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 23;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	//NSLog(@"viewForHeaderInSection %d", section);
	// create the parent view that will hold header Label

	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,23)] autorelease];
	customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// create the label objects
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	headerLabel.font = [UIFont boldSystemFontOfSize:15]; //18
	headerLabel.frame = CGRectMake(10,0,249,23);
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.shadowColor = [UIColor darkGrayColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	headerLabel.text = [self forumName];
	
	UIButton *detailLabel = [UIButton buttonWithType:UIButtonTypeCustom];
	detailLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	detailLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	detailLabel.frame = CGRectMake(260, 0, 50, 23);
	[detailLabel addTarget:self action:@selector(choosePage) forControlEvents:UIControlEventTouchUpInside];
	[detailLabel setTitle:[NSString stringWithFormat:@"page %d", self.pageNumber] forState:UIControlStateNormal];
	[[detailLabel titleLabel] setFont:[UIFont boldSystemFontOfSize:10]];
	[[detailLabel titleLabel] setTextColor:[UIColor whiteColor]];
	[[detailLabel titleLabel] setTextAlignment:UITextAlignmentRight];
	[[detailLabel titleLabel] setBackgroundColor:[UIColor clearColor]];
	[[detailLabel titleLabel] setShadowColor:[UIColor darkGrayColor]];
	[[detailLabel titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
	[[detailLabel titleLabel] setFrame:CGRectMake(260, 0, 50, 23)];

	
	/*
	UILabel *detailLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	detailLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

	detailLabel.font = [UIFont boldSystemFontOfSize:10];
	detailLabel.frame = CGRectMake(260,0,50,23);
	detailLabel.textColor = [UIColor whiteColor];
	detailLabel.textAlignment = UITextAlignmentRight;
	detailLabel.backgroundColor = [UIColor clearColor];
	detailLabel.shadowColor = [UIColor darkGrayColor];
	detailLabel.shadowOffset = CGSizeMake(0.0, 1.0);	
	
	detailLabel.text = [NSString stringWithFormat:@"page %d", self.pageNumber];
		*/
	
	// create image object
	UIImage *myImage = [UIImage imageNamed:@"bar2.png"];
	// create the imageView with the image in it
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
	imageView.alpha = 0.9;
	imageView.frame = CGRectMake(0,0,320,23);
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	
	[customView addSubview:imageView];
	[customView addSubview:headerLabel];
	
	if ([(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] selectedSegmentIndex] == 0) {
		[customView addSubview:detailLabel];
	}
	
	return customView;
 
 }

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrayData.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

/*
	TopicsCell *cell = (TopicsCell *)[tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[TopicsCell alloc] initWithStyle:UITableViewCellStyleSubtitle
													 reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;	
		
		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] 
															 initWithTarget:self action:@selector(handleLongPress:)];
		[cell addGestureRecognizer:longPressRecognizer];
		[longPressRecognizer release];		
	}
	*/
		
	static NSString *CellIdentifier = @"ApplicationCell";
    
    TopicCellView *cell = (TopicCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {

        [[NSBundle mainBundle] loadNibNamed:@"TopicCellView" owner:self options:nil];
        cell = tmpCell;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;	

		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] 
															 initWithTarget:self action:@selector(handleLongPress:)];
		[cell addGestureRecognizer:longPressRecognizer];
		[longPressRecognizer release];	
		
        self.tmpCell = nil;
		
	}
		 

	Topic *aTopic = [arrayData objectAtIndex:indexPath.row];

	/*
	[(UILabel *)[cell.contentView viewWithTag:999] setText:[aTopic aTitle]];
	
	if (aTopic.aRepCount == 0) {
		[(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d message", (aTopic.aRepCount + 1)]];
	}
	else {
		[(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d messages", (aTopic.aRepCount + 1)]];
	}
	[(UILabel *)[cell.contentView viewWithTag:997] setText:[NSString stringWithFormat:@"%@ - %@", [aTopic aAuthorOfLastPost], [aTopic aDateOfLastPost]]];
	*/
	//NSLog(@"Cell Origin %f %f", cell.contentView.frame.origin.x, cell.contentView.frame.origin.y);
	//NSLog(@"Cell Size %f %f", cell.contentView.frame.size.width, cell.contentView.frame.size.height);
	

	
	[cell.titleLabel setText:[aTopic aTitle]];
	 
	if (aTopic.aRepCount == 0) {
	 [cell.msgLabel setText:[NSString stringWithFormat:@"%d message", (aTopic.aRepCount + 1)]];
	}
	else {
	 [cell.msgLabel setText:[NSString stringWithFormat:@"%d messages", (aTopic.aRepCount + 1)]];
	}
	
	[cell.timeLabel setText:[NSString stringWithFormat:@"%@ - %@", [aTopic aAuthorOfLastPost], [aTopic aDateOfLastPost]]];

	if ([aTopic isViewed]) {
		[[cell titleLabel] setFont:[UIFont systemFontOfSize:13]];
	}
	else {
		[[cell titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		
	}	

	//Flag
	if ([aTopic aTypeOfFlag].length > 0) {
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		CGRect frame = CGRectMake(0.0, 0.0, 45, 50);
		button.frame = frame;	// match the button's size with the image size

		if([[aTopic aTypeOfFlag] isEqualToString:@"red"]) {
			[button setBackgroundImage:imageForRedFlag forState:UIControlStateNormal];
			[button setBackgroundImage:imageForRedFlag forState:UIControlStateHighlighted];
		}
		else if ([[aTopic aTypeOfFlag] isEqualToString:@"blue"]) {
			[button setBackgroundImage:imageForBlueFlag forState:UIControlStateNormal];
			[button setBackgroundImage:imageForBlueFlag forState:UIControlStateHighlighted];
		}
		else if ([[aTopic aTypeOfFlag] isEqualToString:@"yellow"]) {
			[button setBackgroundImage:imageForYellowFlag forState:UIControlStateNormal];
			[button setBackgroundImage:imageForYellowFlag forState:UIControlStateHighlighted];
		}

		// set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
		[button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		cell.accessoryView = button;
	}
	else {
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	
		CGRect frame = CGRectMake(0.0, 0.0, imageForSelectedRow.size.width, imageForSelectedRow.size.height);
		//CGRect frame = CGRectMake(0.0, 0.0, 45, 50);
		button.frame = frame;	// match the button's size with the image size
		
		[button setBackgroundImage:imageForSelectedRow forState:UIControlStateNormal];
		[button setBackgroundImage:imageForUnselectedRow forState:UIControlStateHighlighted];
		[button setUserInteractionEnabled:NO];
		
		cell.accessoryView = button;
		
	}
	//Flag	

	return cell;
	
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
	
    NSIndexPath * indexPath = [self.topicsTableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.topicsTableView]];
    if ( indexPath == nil )
        return;
	else {
		[self setPressedIndexPath:[indexPath retain]];
		//self.pressedIndexPath = [indexPath autorelease];
	}

	
	
	//NSLog(@"url %@", [[arrayData objectAtIndex:self.pressedIndexPath.row] aURLOfFlag]);

	//if (self.messagesTableViewController == nil) {
	MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:indexPath.row] aURLOfFlag]];
	self.messagesTableViewController = aView;
	[aView release];
	//}
	
	//setup the URL

	self.messagesTableViewController.topicName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

	[self pushTopic];
    //[self.navigationController pushViewController:messagesTableViewController animated:YES];


}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.topicsTableView];
		self.pressedIndexPath = [[self.topicsTableView indexPathForRowAtPoint:longPressLocation] copy];
				
		UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Aller à..."
																delegate:self cancelButtonTitle:@"Annuler"
												  destructiveButtonTitle:nil
													   otherButtonTitles:	@"la dernière page", @"la dernière réponse", @"la page numéro...",
									 nil,
									 nil];
		
		// use the same style as the nav bar
		styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
        CGPoint longPressLocation2 = [longPressRecognizer locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = CGRectMake( longPressLocation2.x, longPressLocation2.y, 0, 0);

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [styleAlert showFromRect:origFrame inView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view] animated:YES];
        }
        else    
            [styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
        
        
        [styleAlert release];

	}
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

            [self pushTopic];
            //[self.navigationController pushViewController:messagesTableViewController animated:YES];			
			//NSLog(@"url pressed last page: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]);
			break;
		}
		case 1:
		{
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPost]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

            [self pushTopic];
			//NSLog(@"url pressed last post: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPost]);
			break;
			
		}
		case 2:
		{
			NSLog(@"page numero");
            [self chooseTopicPage];
			break;
			
		}
			
	}
}

- (void)pushTopic {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:messagesTableViewController animated:YES];
    }
    else {
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:messagesTableViewController, nil] animated:YES];
        
//        [[HFRplusAppDelegate sharedAppDelegate] setDetailNavigationController:messagesTableViewController];
        
    }    
    
}

#pragma mark -
#pragma mark chooseTopicPage

-(void)chooseTopicPage {
    NSLog(@"chooseTopicPage");


    
    
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aller à la page" message:[NSString stringWithFormat:@"\n\n(numéro entre 1 et %d)\n", [[arrayData objectAtIndex:pressedIndexPath.row] maxTopicPage]]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"OK", nil];
	
	pageNumberField = [[UITextField alloc] initWithFrame:CGRectZero];
	[pageNumberField setBackgroundColor:[UIColor whiteColor]];
	[pageNumberField setPlaceholder:@"numéro de la page"];
	//pageNumberField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;    

    
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
	[pageNumberField addTarget:self action:@selector(textFieldTopicDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[alert setTag:669];
	[alert addSubview:pageNumberField];
    
	
	[alert show];
    

	//pageNumberField.frame = CGRectMake(12.0, , 260.0, 30.0);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UILabel* tmpLbl = [alert.subviews objectAtIndex:1];
        pageNumberField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        pageNumberField.frame = CGRectMake(12.0, tmpLbl.frame.origin.y + tmpLbl.frame.size.height + 10, 260.0, 30.0);
    }
    else {
        pageNumberField.frame = CGRectMake(12.0, 50.0, 260.0, 30.0);
    }
	
	[alert release];
     
}

-(void)textFieldTopicDidChange:(id)sender {
	//NSLog(@"textFieldDidChange %d %@", [[(UITextField *)sender text] intValue], sender);	
	
	
	if ([[(UITextField *)sender text] length] > 0) {
		int val; 
		if ([[NSScanner scannerWithString:[(UITextField *)sender text]] scanInt:&val]) {
			//NSLog(@"int %d %@ %@", val, [(UITextField *)sender text], [NSString stringWithFormat:@"%d", val]);
			
			if (![[(UITextField *)sender text] isEqualToString:[NSString stringWithFormat:@"%d", val]]) {
				//NSLog(@"pas int");
				[sender setText:[NSString stringWithFormat:@"%d", val]];
			}
			else if ([[(UITextField *)sender text] intValue] < 1) {
				//NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
				[sender setText:[NSString stringWithFormat:@"%d", 1]];
				//NSLog(@"ERROR NOW %d", [[(UITextField *)sender text] intValue]);
				
			}
			else if ([[(UITextField *)sender text] intValue] > [[arrayData objectAtIndex:pressedIndexPath.row] maxTopicPage]) {
				//NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
				[sender setText:[NSString stringWithFormat:@"%d", [[arrayData objectAtIndex:pressedIndexPath.row] maxTopicPage]]];
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

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	[super didPresentAlertView:alertView];
    
	//NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 669)) {
		[pageNumberField becomeFirstResponder];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView willDismissWithButtonIndex:buttonIndex];
    
	//NSLog(@"willDismissWithButtonIndex PT %@", alertView);
	if (([alertView tag] == 669)) {
		[self.pageNumberField resignFirstResponder];
		self.pageNumberField = nil;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
	
	if (buttonIndex == 1 && alertView.tag == 669) {
        NSLog(@"goto topic page %d", [[pageNumberField text] intValue]);
        NSString * newUrl = [[NSString alloc] initWithString:[[arrayData objectAtIndex:pressedIndexPath.row] aURL]];
       
        NSLog(@"newUrl %@", newUrl);

        newUrl = [newUrl stringByReplacingOccurrencesOfString:@"_1.htm" withString:[NSString stringWithFormat:@"_%d.htm", [[pageNumberField text] intValue]]];
        newUrl = [newUrl stringByReplacingOccurrencesOfString:@"page=1&" withString:[NSString stringWithFormat:@"page=%d&", [[pageNumberField text] intValue]]];
        
        NSLog(@"newUrl %@", newUrl);

        //if (self.messagesTableViewController == nil) {
		MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:newUrl];
		self.messagesTableViewController = aView;
		[aView release];
        //}
        
        
        
        //NSLog(@"%@", self.navigationController.navigationBar);
        

        //setup the URL
        self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
        self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	
        
        [self pushTopic];
        //[self.navigationController pushViewController:messagesTableViewController animated:YES];
    
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	//NSLog(@"did Select row Topics table views: %d", indexPath.row);

	//if (self.messagesTableViewController == nil) {
		MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:indexPath.row] aURL]];
		self.messagesTableViewController = aView;
		[aView release];
	//}
	
	//NSLog(@"%@", self.navigationController.navigationBar);
    NSLog(@"b4 %@", self.navigationController);

	//setup the URL
    
    [self.messagesTableViewController setTopicName:[[arrayData objectAtIndex:indexPath.row] aTitle]];
	self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:indexPath.row] isViewed];	
    
    NSLog(@"pushTopic");
    [self pushTopic];
	//[self.navigationController pushViewController:messagesTableViewController animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myPickerView)	// don't show selection for the custom picker
	{
		// report the selection to the UI label
		//label.text = [NSString stringWithFormat:@"%@ - %d",
		//			  [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]],
		//			  [pickerView selectedRowInComponent:1]];
		
		NSLog(@"%@", [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]]);
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
    NSLog(@"NOC");
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

-(void)showPicker:(id)sender {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //NSLog(@"TT %@", [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle]);
        
        SubCatTableViewController *subCatTableViewController = [[[SubCatTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        subCatTableViewController.suPicker = myPickerView;
        subCatTableViewController.arrayData = pickerViewArray;
        subCatTableViewController.notification = @"SubCatSelected";
        
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:subCatTableViewController] autorelease];
        
        //CGPoint senderPoint = [sender locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = [(UISegmentedControl *)sender frame];
        //origFrame.origin.x += 80;
        
        
        origFrame.origin.x += 75;
        origFrame.origin.y += 10;
        
        [_popover presentPopoverFromRect:origFrame inView:[[self navigationController] view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        
     
    } else {
        CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
        myPickerView.frame = [self pickerFrameWithSize:pickerSize];
        
        [actionSheet showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
        
        CGRect curFrame = [[actionSheet viewWithTag:546] frame];
        curFrame.origin.x =  self.view.frame.size.width - curFrame.size.width - 10;
        [[actionSheet viewWithTag:546] setFrame:curFrame];
        
        [UIView beginAnimations:nil context:nil];
        [actionSheet setFrame:CGRectMake(0, [[[HFRplusAppDelegate sharedAppDelegate] rootController] tabBar].frame.size.height + self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height + 20 - myPickerView.frame.size.height - 44,
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
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
	//NSLog(@"mem warning TTV");
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	//NSLog(@"viewDidUnload");
		
	self.loadingView = nil;
	self.topicsTableView = nil;
	self.maintenanceView = nil;
	self.swipeLeftRecognizer = nil;
	self.swipeRightRecognizer = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	//NSLog(@"dealloc Topics Table View");
	
	[self viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SubCatSelected" object:nil];

	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	//NSLog(@"dealloc Topics Table View 2");

	self.forumName = nil;

	self.forumNewTopicUrl = nil;

	self.forumBaseURL = nil;
	self.forumFavorisURL = nil;
	self.forumFlag1URL = nil;
	self.forumFlag0URL = nil;
	
	[self.arrayData release], self.arrayData = nil;
	
	if(self.messagesTableViewController) self.messagesTableViewController = nil;
	
	self.pressedIndexPath = nil;

	self.imageForUnselectedRow = nil;
	self.imageForSelectedRow = nil;

	//Gesture
	[swipeLeftRecognizer release];
	[swipeRightRecognizer release];
	
	//Picker
	self.myPickerView = nil;
	self.actionSheet = nil;
	self.pickerViewArray = nil;

	self.statusMessage = nil;
	
	[super dealloc];

}


@end

