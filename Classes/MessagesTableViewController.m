//
//  MessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 07/07/10.
//

#import <unistd.h>

#import "MessagesTableViewController.h"
#import "MessagesSearchTableViewController.h"
#import "MessageDetailViewController.h"
#import "TopicsTableViewController.h"
#import "PollTableViewController.h"


#import "RegexKitLite.h"
#import "HTMLParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "ASIDownloadCache.h"

#import "UIWebView+Tools.h"

#import "ShakeView.h"
//#import "UIImageView+WebCache.h"
#import "RangeOfCharacters.h"
#import "NSData+Base64.h"
#import "HFRMenuItem.h"
#import "LinkItem.h"
#import <CommonCrypto/CommonDigest.h>

#import "ProfilViewController.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "BlackList.h"

@implementation MessagesTableViewController
@synthesize loaded, isLoading, _topicName, topicAnswerUrl, loadingView, errorLabelView, messagesWebView, arrayData, updatedArrayData, detailViewController, messagesTableViewController, pollNode;
@synthesize swipeLeftRecognizer, swipeRightRecognizer, overview, arrayActionsMessages, lastStringFlagTopic;
@synthesize searchBg, searchBox, searchKeyword, searchPseudo, searchFilter, searchFromFP, searchInputData, isSearchInstra;

@synthesize queue; //v3
@synthesize stringFlagTopic;
@synthesize editFlagTopic;
@synthesize arrayInputData;
@synthesize aToolbar, styleAlert;

@synthesize isFavoritesOrRead, isRedFlagged, isUnreadable, isAnimating, isViewed;

@synthesize request, arrayAction, curPostID;

@synthesize firstDate;

- (void)setTopicName:(NSString *)n {
    [_topicName release];
    _topicName = [[n filterTU] retain];
    
    
}
//Getter method
- (NSString*) topicName {
    //NSLog(@"Returning name: %@", _aTitle);
    return _topicName;
}



#pragma mark -
#pragma mark Data lifecycle

- (void)setProgress:(float)newProgress{
	//NSLog(@"Progress %f%", newProgress*100);
}

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent:(int)from
{
    //self.firstDate = [NSDate date];
    
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
    //self.currentUrl = @"/forum2.php?config=hfr.inc&cat=25&post=1711&page=301&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t530526";
    
    
    //self.currentUrl = @"/forum2.php?config=hfr.inc&cat=25&post=5925&page=1&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t535660";
    
    
    //NSLog(@"URL %@", [self currentUrl]);
    
    //NSLog(@"[self currentUrl] %@", [self currentUrl]);
    //NSLog(@"[self stringFlagTopic] %@", [self stringFlagTopic]);
    
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]]]];
	[request setDelegate:self];
    [request setShowAccurateProgress:YES];
    
	//[request setCachePolicy:ASIReloadIfDifferentCachePolicy];
	//[request setDownloadCache:[ASIDownloadCache sharedCache]];
	
    [request setDownloadProgressDelegate:self];
    
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
    
	[self.view removeGestureRecognizer:swipeLeftRecognizer];
	[self.view removeGestureRecognizer:swipeRightRecognizer];
	
	if ([NSThread isMainThread]) {
        [self.messagesWebView setHidden:YES];
    }

    //NSLog(@"from %d", from);
    
    [self.errorLabelView setHidden:YES];

    if(from == kNewMessageFromNext) self.stringFlagTopic = @"#bas";
    
    switch (from) {
        case kNewMessageFromShake:
        case kNewMessageFromUpdate:
        case kNewMessageFromEditor:
            //NSLog(@"hidden");
            [self.loadingView setHidden:YES];
            break;
        default:
            //NSLog(@"not hidden");
            [self.loadingView setHidden:NO];
            [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
            break;
    }
    
	[request startAsynchronous];
}


- (void)fetchContent
{
    [self fetchContent:kNewMessageFromUnkwn];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//--
	//NSLog(@"fetchContentStarted");
    
    if (![self.currentUrl isEqualToString:[theRequest.url.absoluteString stringByReplacingOccurrencesOfString:kForumURL withString:@""]]) {
        //NSLog(@"not equal ==");
        self.currentUrl = [theRequest.url.absoluteString stringByReplacingOccurrencesOfString:kForumURL withString:@""];
    }

}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentComplete");
	
	// create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];

    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
	
	//MaJ de la puce MP
	if (!self.isViewed) {
		//NSLog(@"pas lu");
		[[HFRplusAppDelegate sharedAppDelegate] readMPBadge];
	}
	
	
	//MaJ de la puce MP
	
    //NSLog(@"%@", [request responseString]);
    
    ParseMessagesOperation *parser = [[ParseMessagesOperation alloc] initWithData:[request responseData] index:0 reverse:NO delegate:self];
	
    [queue addOperation:parser]; // this will start the "ParseOperation"
    
    [parser release];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	
	[self.loadingView setHidden:YES];
	
    //NSLog(@"theRequest.error %@", theRequest.error);
    //NSLog(@"theRequest.url %@", theRequest.url);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
    
    [alert setTag:667];
	//[alert show];
	//[alert release];
}

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
            self.pageNumber = [[self.currentUrl substringWithRange:rangeNumPage] intValue];
        }
        else {
            self.pageNumber = [[self.currentUrl substringWithRange:matchedRange] intValue];
            
        }
        //On check si y'a page=2323
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
    }

    //NSLog(@"pageNumber %d", self.pageNumber);

    if (self.isSearchInstra) {
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"Recherche | %@", self.topicName]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
        
    }
    
	//self.title = [NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber];
    
	//[self navigationItem].titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	
}

-(void)setupPageToolbar:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser;
{
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
				[newFirstPageUrl release];
			}
			else {
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray objectAtIndex:2] getAttributeNamed:@"href"]];
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
                //NSLog(@"lastObject %@", [[temporaryNumPagesArray lastObject] allContents]);
                
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray lastObject] getAttributeNamed:@"href"]];
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
			
			[label release];
			
			
			
			
			//Use this to put space in between your toolbox buttons
			UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];

			//Add buttons to the array
			NSArray *items = [NSArray arrayWithObjects: systemItem1, flexItem, systemItem3, flexItem, systemItem2, nil];
			
			//release buttons
			[systemItem1 release];
			[systemItem2 release];
			[systemItem3 release];
			[flexItem release];
			
			//add array of buttons to toolbar
			[tmptoolbar setItems:items animated:NO];
			
			self.aToolbar = tmptoolbar;
			[tmptoolbar release];
			
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
		
        if (self.isSearchInstra) {
            [self.view addGestureRecognizer:swipeLeftRecognizer];
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
                [self.view addGestureRecognizer:swipeLeftRecognizer];
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
                [self.view addGestureRecognizer:swipeRightRecognizer];
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

-(void)setupPoll:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    self.pollNode = nil;
    
	HTMLNode * tmpPollNode = [[bodyNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO] retain];
	if(tmpPollNode)
    {
        [self setPollNode:rawContentsOfNode([tmpPollNode _node], [myParser _doc])];
    }
}

-(void)setupIntrSearch:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    HTMLNode * tmpSearchNode = [[bodyNode findChildWithAttribute:@"action" matchingName:@"/transsearch.php" allowPartial:NO] retain];
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
                        NSLog(@"FILTER ON");
                        [self.searchFilter setOn:YES animated:NO];
                    }
                    else {
                        NSLog(@"FILTER OFF");
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




-(void)loadDataInTableView:(HTMLParser *)myParser
{    
	[self setupScrollAndPage];

	//NSLog(@"name topicName %@", self.topicName);
	
	HTMLNode * bodyNode = [myParser body]; //Find the body tag

	//MP
	BOOL needToUpdateMP = NO;
	HTMLNode *MPNode = [bodyNode findChildOfClass:@"none"]; //Get links for cat	
	NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
	//NSLog(@"temporaryMPArray count %d", temporaryMPArray.count);
	
	if (temporaryMPArray.count == 3) {
		//NSLog(@"MPNode allContents %@", [[temporaryMPArray objectAtIndex:1] allContents]);
		
		NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";			
		NSString *myMPNumber = [[[temporaryMPArray objectAtIndex:1] allContents] stringByReplacingOccurrencesOfRegex:regExMP
																										  withString:@"$1"];
		
		[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
	}
	else {
		needToUpdateMP = YES;
	}
	
	//MP

	//Answer Topic URL
	HTMLNode * topicAnswerNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"repondre_form" allowPartial:NO];
	topicAnswerUrl = [[NSString alloc] init];
	topicAnswerUrl = [[[topicAnswerNode findChildTag:@"a"] getAttributeNamed:@"href"] retain];
	//NSLog(@"new answer: %@", topicAnswerUrl);
	
	//form to fast answer
	[self setupFastAnswer:bodyNode];

    //prep' Poll view
    [self setupPoll:bodyNode andP:myParser];
    [self setupIntrSearch:bodyNode andP:myParser];

	//if(topicAnswerUrl.length > 0) 
	//-	

	//--Pages
	[self setupPageToolbar:bodyNode andP:myParser];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization
        //NSLog(@"init %@", theTopicUrl);
		self.currentUrl = [theTopicUrl copy];	
		self.loaded = NO;
		self.isViewed = YES;
        [self setIsSearchInstra:NO];


	}
	return self;
}

- (void)viewWillDisappear:(BOOL)animated {
	//NSLog(@"viewWillDisappear");
	
    [super viewWillDisappear:animated];
	self.isAnimating = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"viewDidAppear");
    
	[super viewDidAppear:animated];
	self.isAnimating = NO;
    
}

- (void)VisibilityChanged:(NSNotification *)notification {
   // NSLog(@"VisibilityChanged %@", notification);

    if ([[notification valueForKey:@"object"] isEqualToString:@"SHOW"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
        [self editMenuHidden:nil];
    }
    //[self resignFirstResponder];
}

-(void)textQuote:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];

    NSString *baseElem = @"window.getSelection().anchorNode";
    while (![[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] isEqualToString:@"message"]) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);
        
        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    int curMsg = [[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]] intValue];

    NSLog(@"theSelectedText %@", theSelectedText);
    
    //int curMsg = [[NSNumber numberWithInt:curPostID] intValue];
        
    [self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText];
}

-(void)textQuoteBold:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];
    
    NSString *baseElem = @"window.getSelection().anchorNode";
    while (![[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] isEqualToString:@"message"]) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);
        
        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    int curMsg = [[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]] intValue];

    NSLog(@"theSelectedText Bold %@", theSelectedText);
    
    //int curMsg = [[NSNumber numberWithInt:curPostID] intValue];
    
    [self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText withBold:YES];
    

}

- (void)editMenuHidden:(id)sender {
    //NSLog(@"editMenuHidden %@ NOMBRE %lu", sender, [UIMenuController sharedMenuController].menuItems.count);
    
    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgQuoteB = [UIImage imageNamed:@"BoldFilled-20"];
    
    
    UIMenuItem *textQuotinuum = [[[UIMenuItem alloc] initWithTitle:@"Citerexclu" action:@selector(textQuote:) image:menuImgQuote] autorelease];
    UIMenuItem *textQuotinuumBis = [[[UIMenuItem alloc] initWithTitle:@"Citergras" action:@selector(textQuoteBold:) image:menuImgQuoteB] autorelease];

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObjects:textQuotinuum, textQuotinuumBis, nil]];
    //[self resignFirstResponder];
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad %@", self.topicName);

    [super viewDidLoad];
	self.isAnimating = NO;

	self.title = self.topicName;  

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisibilityChanged:) name:@"VisibilityChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTextSizeDidChange) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
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
    [label release];

    // fond blanc WebView
    [self.messagesWebView hideGradientBackground];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.messagesWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
    else
    {
        [self.messagesWebView setBackgroundColor:[UIColor whiteColor]];
    }
    
	//Gesture
	UIGestureRecognizer *recognizer;

	//De Gauche à droite
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRight:)];
	self.swipeRightRecognizer = (UISwipeGestureRecognizer *)recognizer;
	[recognizer release];	
	
	//De Droite à gauche
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToLeft:)];
	self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
	[recognizer release];
	//-- Gesture


	//Bouton Repondre message
    
    if (self.isSearchInstra) {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchTopic)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        [optionsBarItem release];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    else {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionsTopic:)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        [optionsBarItem release];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    

	[(ShakeView*)self.view setShakeDelegate:self];
	
    
    
    
	self.arrayAction = [[NSMutableArray alloc] init];
	self.arrayActionsMessages = [[NSMutableArray alloc] init];
    
	self.arrayData = [[NSMutableArray alloc] init];
	self.updatedArrayData = [[NSMutableArray alloc] init];
	self.arrayInputData = [[NSMutableDictionary alloc] init];
	self.editFlagTopic = [[NSString	alloc] init];
	self.stringFlagTopic = [[NSString	alloc] init];
	self.lastStringFlagTopic = [[NSString	alloc] init];

	self.isFavoritesOrRead = [[NSString	alloc] init];
	self.isUnreadable = NO;
	self.curPostID = -1;
	
    if (!self.searchInputData) {
        NSLog(@"NO searchInputData");
        self.searchInputData = [[NSMutableDictionary alloc] init];
    }

    
	[self setEditFlagTopic:nil];
	[self setStringFlagTopic:@""];

	[self fetchContent];
    [self editMenuHidden:nil];
    self.messagesWebView.controll = self;
}

-(void)fullScreen {
    [self fullScreen:nil];
}

-(void)fullScreen:(id)sender {
    
    if ([(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController respondsToSelector:@selector(MoveRightToLeft)]) {
        [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController MoveRightToLeft];
    }
    
}
-(void)optionsTopic:(id)sender
{
    
    [self.arrayActionsMessages removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if(self.topicAnswerUrl.length > 0)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"answerTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_firstpage   = [defaults boolForKey:@"actionsmesages_firstpage"];
    if(actionsmesages_firstpage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Première page", @"firstPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_lastpage    = [defaults boolForKey:@"actionsmesages_lastpage"];
    if(actionsmesages_lastpage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière page", @"lastPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_lastanswer  = [defaults boolForKey:@"actionsmesages_lastanswer"];
    if(actionsmesages_lastanswer) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière réponse", @"lastAnswer", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_pagenumber  = [defaults boolForKey:@"actionsmesages_pagenumber"];
    if(actionsmesages_pagenumber && ([self lastPageNumber] > [self firstPageNumber])) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Page Numéro...", @"choosePage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_toppage     = [defaults boolForKey:@"actionsmesages_toppage"];
    if(actionsmesages_toppage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Haut de la page", @"goToPagePositionTop", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_bottompage  = [defaults boolForKey:@"actionsmesages_bottompage"];
    if(actionsmesages_bottompage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Bas de la page", @"goToPagePositionBottom", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_poll  = [defaults boolForKey:@"actionsmesages_poll"];
    if(actionsmesages_poll && self.pollNode)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Sondage", @"showPoll", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_unread      = [defaults boolForKey:@"actionsmesages_unread"];
    if(actionsmesages_unread && self.isUnreadable) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Marquer comme non lu", @"markUnread", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    if (self.arrayActionsMessages.count == 0) {
        return;
    }
    
    [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Rechercher", @"searchTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.parentViewController isMemberOfClass:[UINavigationController class]]) {
        
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Navigateur✚", @"fullScreen", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
        
    }
    //UIActionSheet *styleAlert;


    /*NSMutableArray *optionsList = [NSMutableArray arrayWithObjects:@"Première page", @"Dernière page", nil];

	if(topicAnswerUrl.length > 0) {
        [optionsList addObject:@"Répondre"];
    }
    
    if (self.isUnreadable) {
        [optionsList addObject:@"Marquer comme non lu"];
    } 
    
    
     */
    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:styleAlert.numberOfButtons-1 animated:YES];
        return;
    }
    else {
        [styleAlert release];
        styleAlert = [[UIActionSheet alloc] init];
    }
    
    
    
    //styleAlert = [[UIActionSheet alloc] init];
	styleAlert.delegate = self;
    
	styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    for( NSDictionary *dico in arrayActionsMessages)  
        [styleAlert addButtonWithTitle:[dico valueForKey:@"title"]]; 

    [styleAlert addButtonWithTitle:@"Annuler"]; 
    styleAlert.cancelButtonIndex = styleAlert.numberOfButtons-1;
    
    // use the same style as the nav bar
    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [styleAlert showFromBarButtonItem:sender animated:YES];
    
    //[styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
    //[styleAlert release];    
    
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

-(void)showPoll {
    
    PollTableViewController *pollVC = [[PollTableViewController alloc] initWithPollNode:self.pollNode];
    pollVC.delegate = self;
    
    // Set options
    pollVC.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)

    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:pollVC];
    //nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentModalViewController:nc animated:YES];
    [nc release];
    
    
    //[self.navigationController pushViewController:browser animated:YES];
    
    [pollVC release];
    
}

-(void)markUnread {
    ASIHTTPRequest  *delrequest =  
    [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, self.isFavoritesOrRead]]] autorelease];
    //delete
    
    [delrequest startSynchronous];
    
    //NSLog(@"arequest: %@", [arequest url]);
    
    if (delrequest) {
        if ([delrequest error]) {
            //NSLog(@"error: %@", [[arequest error] localizedDescription]);
        }
        else if ([delrequest responseString])
        {
            //NSLog(@"responseString: %@", [arequest responseString]);
            
            //[self reload];
            [[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] popViewControllerAnimated:YES];
            [(TopicsTableViewController *)[[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] visibleViewController] fetchContent];
        }
    }
    //NSLog(@"nonlu %@", self.isFavoritesOrRead);
}

-(void)goToPagePosition:(NSString *)position{
    NSString *script;
    
    if ([position isEqualToString:@"top"])
        script = @"$('html, body').animate({scrollTop:0}, 'slow');";
    else if ([position isEqualToString:@"bottom"])
        script = @"$('html, body').animate({scrollTop:$(document).height()}, 'slow');";
    else {
        script = @"";
    }

    [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
}
    
-(void)goToPagePositionTop{
    [self goToPagePosition:@"top"];
}
-(void)goToPagePositionBottom{
    [self goToPagePosition:@"bottom"];    
}


-(void)answerTopic
{
	
	while (self.isAnimating) {
        //NSLog(@"isAnimating");
		//return;
	}
    //NSLog(@"isOK");

	NewMessageViewController *addMessageViewController = [[NewMessageViewController alloc]
														   initWithNibName:@"AddMessageViewController" bundle:nil];
	addMessageViewController.delegate = self;
	[addMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", kForumURL, topicAnswerUrl]];
	addMessageViewController.title = @"Nouv. Réponse";
	
	
	// Create the navigation controller and present it modally.
	HFRNavigationController *navigationController = [[HFRNavigationController alloc]
													initWithRootViewController:addMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
    
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[addMessageViewController release];

	//[[HFR_AppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", topicAnswerUrl]];

	//[[UIApplication sharedApplication] open-URL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]];
	
/*
	HFR_AppDelegate *mainDelegate = (HFR_AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[mainDelegate rootController] setSelectedIndex:3];		
	[[(BrowserViewController *)[[mainDelegate rootController] selectedViewController] webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]]];		
 */
}



-(void)searchTopic {

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    

    [self toggleSearch];

}

-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected withBold:(BOOL)boldSelection {
    if (self.isAnimating) {
        return;
    }
    
    QuoteMessageViewController *quoteMessageViewController = [[QuoteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
    quoteMessageViewController.delegate = self;
    [quoteMessageViewController setUrlQuote:quoteUrl];
    [quoteMessageViewController setTextQuote:selected];
    [quoteMessageViewController setBoldQuote:boldSelection];
    
    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:quoteMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
    [navigationController release];
    [quoteMessageViewController release];
}

-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected {
    [self quoteMessage:quoteUrl andSelectedText:selected withBold:NO];
}

-(void)quoteMessage:(NSString *)quoteUrl
{
    [self quoteMessage:quoteUrl andSelectedText:@""];
}

-(void)editMessage:(NSString *)editUrl
{
	if (self.isAnimating) {
		return;
	}
	
	EditMessageViewController *editMessageViewController = [[EditMessageViewController alloc]
															  initWithNibName:@"AddMessageViewController" bundle:nil];
	editMessageViewController.delegate = self;
	[editMessageViewController setUrlQuote:editUrl];
	
	// Create the navigation controller and present it modally.
	HFRNavigationController *navigationController = [[HFRNavigationController alloc]
													initWithRootViewController:editMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
    
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[editMessageViewController release];
	
}



/*
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

	//NSLog(@"toscroll, %d", messageToScroll);
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.view becomeFirstResponder];

	
	if(self.detailViewController) self.detailViewController = nil;
	if(self.messagesTableViewController) self.messagesTableViewController = nil;
 
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
}
*/


- (void)viewDidDisappear:(BOOL)animated {
	//NSLog(@"viewDidDisappear");

    [super viewDidDisappear:animated];
	[self.view resignFirstResponder];
	
}
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


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

- (void)didSelectMessage:(int)index
{
	{
		// Navigation logic may go here. Create and push another view controller.

		 if (self.detailViewController == nil) {
			 MessageDetailViewController *aView = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewControllerv2" bundle:nil];
			 self.detailViewController = aView;
			 [aView release];
		 }
		 
		 
		 // ...
		 // Pass the selected object to the new view controller.
		 self.navigationItem.backBarButtonItem =
		 [[UIBarButtonItem alloc] initWithTitle:@"Retour"
		 style: UIBarButtonItemStyleBordered
		 target:nil
		 action:nil];
		
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }
        
		///===
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
        //label.frame = CGRectMake(0, 0, 500, self.navigationBar.frame.size.height - 4);
        
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // 
        
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
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
        
        

        
        
        [label setNumberOfLines:0];
        
		[label setText:[NSString stringWithFormat:@"Page: %d — %d/%d", self.pageNumber, index + 1, arrayData.count]];
        
		[self.detailViewController.navigationItem setTitleView:label];
        [label release];
		///===
		
		 //setup the URL
		 //detailViewController.topicName = [[arrayData objectAtIndex:indexPath.row] name];	
		 
		 //NSLog(@"push message details");
		 // andContent:[arrayData objectAtIndex:indexPath.section]
		 
		 self.detailViewController.arrayData = arrayData;	
		 self.detailViewController.curMsg = index;	
		 self.detailViewController.pageNumber = self.pageNumber;	
		 self.detailViewController.parent = self;	
		 self.detailViewController.messageTitleString = self.topicName;	
		 
		 [self.navigationController pushViewController:detailViewController animated:YES];

	}
}

- (void) didSelectImage:(int)index withUrl:(NSString *)selectedURL {
	if (self.isAnimating) {
		return;
	}
	
	//On récupe les images du message:
	//NSLog(@"%@", [[arrayData objectAtIndex:index] toHTML:index]);
	//NSLog(@"selectedURL %@", selectedURL);
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithString:[[arrayData objectAtIndex:index] toHTML:index] error:NULL];
	HTMLNode * msgNode = [myParser doc]; //Find the body tag

	NSArray * tmpImageArray =  [msgNode findChildrenWithAttribute:@"class" matchingName:@"hfrplusimg" allowPartial:NO];
	//NSLog(@"%d", [tmpImageArray count]);
	
	NSMutableArray * imageArray = [[NSMutableArray alloc] init];
	int selectedIndex = 0;
    
	for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
		//NSLog(@"======\nalt %@", [imgNode getAttributeNamed:@"alt"]);
        //NSLog(@"longdesc %@", [imgNode getAttributeNamed:@"longdesc"]);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/"]]]];
        else
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/preview/"]]]];
            
            
        if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
            selectedIndex = [imageArray count] - 1;
        }
        
        /*
        
		[imageArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"alt"], [imgNode getAttributeNamed:@"longdesc"], nil]  forKeys:[NSArray arrayWithObjects:@"alt", @"longdesc", nil]]];
        if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
            selectedIndex = [imageArray count] - 1;
        }
         */
        
	}
	
	//NSLog(@"selectedIndex %d", selectedIndex);
	// Create the root view controller for the navigation controller
	// The new view controller configures a Cancel and Done button for the
	// navigation bar.
	

	
    /*
    PhotoViewController *photoViewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController-iPad" bundle:nil];        
    else
        photoViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
    
	photoViewController.delegate = self;
	[photoViewController setImageURL:selectedURL];
	[photoViewController setImageData:imageArray];
	[photoViewController setSelectedIndex:selectedIndex];
	[imageArray release];
    	
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[photoViewController release];
    */
    
    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:imageArray];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:selectedIndex]; // Example: allows second image to be presented first
    // Present

    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [nc release];    
    
    
    //[self.navigationController pushViewController:browser animated:YES];
    
    [browser release];
    [imageArray release];
	[myParser release];
}

#pragma mark -
#pragma mark searchNewMessages

-(void)searchNewMessages:(int)from {
    
	if (![self.messagesWebView isLoading]) {	
		[self.messagesWebView stringByEvaluatingJavaScriptFromString:@"$('#actualiserbtn').addClass('loading');"];
		[self performSelectorInBackground:@selector(fetchContentinBackground:) withObject:[NSNumber numberWithInt:from]];
	}    
}

-(void)searchNewMessages {
	
	[self searchNewMessages:kNewMessageFromUnkwn];
    
}

- (void)fetchContentinBackground:(id)from {
    
    
	NSAutoreleasePool * pool2;
    
    pool2 = [[NSAutoreleasePool alloc] init];

    int intfrom = [from intValue];
    
    switch (intfrom) {
        case kNewMessageFromShake:
            [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
            break;
        case kNewMessageFromUpdate:
            [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
            break;
        case kNewMessageFromEditor:
            // le flag est mis à jour depuis l'editeur.
            break;
        default:
            [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
            break;
    }
    
	[self fetchContent:intfrom];
	
	[pool2 drain];
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
    
    if (self.isSearchInstra) {
        NSLog(@"isSearchInstra");

        [self searchSubmit:nil];
    }
    else {
        NSLog(@"NEXT");

        [self nextPage:recognizer];
    }
}
- (void)handleSwipeToRight:(UISwipeGestureRecognizer *)recognizer {
    if (!self.isSearchInstra && (self.searchBg.alpha == 0.0 || self.searchBg.hidden == YES)) {
        [self previousPage:recognizer];
    }
}

#pragma mark -
#pragma mark Photo Delegate

- (void)photoViewControllerDidFinish:(PhotoViewController *)controller {
   // NSLog(@"photoViewControllerDidFinish");

	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark AlerteModo Delegate

- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinish");
    [self dismissModalViewControllerAnimated:YES];
}
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinishOK");
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark AddMessage Delegate
-(BOOL) canBeFavorite{
	if ([self isUnreadable]) {
		return NO;
	}
	
	
	return YES;
}

-(void)setupFastAnswer:(HTMLNode*)bodyNode
{
	HTMLNode * fastAnswerNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hop" allowPartial:NO];
	NSArray *temporaryInputArray = [fastAnswerNode findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:YES];
	
	//HTMLNode * inputNode;
	for (HTMLNode * inputNode in temporaryInputArray) { //Loop through all the tags
		//NSLog(@"inputNode: %@ - value: %@", [inputNode getAttributeNamed:@"name"], [inputNode getAttributeNamed:@"value"]);
		[self.arrayInputData setObject:[inputNode getAttributeNamed:@"value"] forKey:[inputNode getAttributeNamed:@"name"]];
		
	}
	
	self.isRedFlagged = NO;
	
	//Fav/Unread
	HTMLNode * FlagNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"delflag" allowPartial:YES];
	self.isFavoritesOrRead =  @"";

	if (FlagNode) {
		self.isFavoritesOrRead = [FlagNode getAttributeNamed:@"href"];
		if ([FlagNode findChildWithAttribute:@"src" matchingName:@"flagn0.gif" allowPartial:YES]) {
			self.isRedFlagged = YES;
		}
        
        //NSLog(@"FlagNode %d", self.isRedFlagged);
	}
	else {
		HTMLNode * ReadNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"nonlu" allowPartial:YES];
		if (ReadNode) {
			self.isFavoritesOrRead = [ReadNode getAttributeNamed:@"href"];
			self.isUnreadable = YES;			
		}
		else {
			self.isFavoritesOrRead =  @"";	
		}
        
        //NSLog(@"!FlagNode %@", self.isFavoritesOrRead);
        //NSLog(@"!FlagNode %d", self.isUnreadable);
	}
}
//--form to fast answer	

- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    //NSLog(@"addMessageViewControllerDidFinish %@", self.editFlagTopic);
	
	[self setEditFlagTopic:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
	//NSLog(@"addMessageViewControllerDidFinishOK");
    
	[self dismissModalViewControllerAnimated:YES];
    
    if (self.arrayData.count > 0) {
		//NSLog(@"curid %d", self.curPostID);
		NSString *components = [[[self.arrayData objectAtIndex:0] quoteJS] substringFromIndex:7];
		components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
		components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		NSArray *quoteComponents = [components componentsSeparatedByString:@","];
		
		NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
		
		[self EffaceCookie:nameCookie];
	}
    
	self.curPostID = -1;
	
    [self setStringFlagTopic:[[controller refreshAnchor] copy]];
    
    NSLog(@"addMessageViewControllerDidFinishOK stringFlagTopic %@", self.stringFlagTopic);
    
    
	[self searchNewMessages:kNewMessageFromEditor];
	[self.navigationController popToViewController:self animated:NO];


}

#pragma mark -
#pragma mark Parse Operation Delegate

// -------------------------------------------------------------------------------
//	handleLoadedApps:notif
// -------------------------------------------------------------------------------

- (void)handleLoadedApps:(NSArray *)loadedItems
{
    
	[self.arrayData removeAllObjects];
	[self.arrayData addObjectsFromArray:loadedItems];


	NSString *tmpHTML = [[[NSString alloc] initWithString:@""] autorelease];
	
    
    NSLog(@"COUNT = %lu", (unsigned long)[self.arrayData count]);
    
    if (self.isSearchInstra && self.arrayData.count == 0) {
        NSLog(@"BZAAAAA %@", self.currentUrl);
        [self.loadingView setHidden:YES];
        [self.messagesWebView setHidden:YES];
        [self.errorLabelView setText:@"Désolé aucune réponse n'a été trouvée"];
        [self.errorLabelView setHidden:NO];
        [self toggleSearch:YES];
    }
    else {
        int i;
        NSLog(@"OLD %@", self.stringFlagTopic);

        NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        int currentFlagValue = [[self.stringFlagTopic stringByTrimmingCharactersInSet:nonDigits] intValue];
        bool ifCurrentFlag = NO;
        int closePostID = 0;
        
        if(!currentFlagValue) { //si pas de value on cherche soit le premier message (pas de flag) soit le dernier (#bas)
            NSLog(@"!currentFlagValue");
            
            ifCurrentFlag = YES;
        }

        NSLog(@"Looking for %d", currentFlagValue);
        //NSLog(@"==============");

        for (i = 0; i < [self.arrayData count]; i++) { //Loop through all the tags
            tmpHTML = [tmpHTML stringByAppendingString:[[self.arrayData objectAtIndex:i] toHTML:i]];
            
            if (!ifCurrentFlag) {

                int tmpFlagValue = [[[[self.arrayData objectAtIndex:i] postID] stringByTrimmingCharactersInSet:nonDigits] intValue];

                if (tmpFlagValue == currentFlagValue) {
                    //NSLog(@"TROUVE");
                    ifCurrentFlag = YES;
                    closePostID = tmpFlagValue;
                }

                //NSLog(@"pas encore trouvé");
                
                if (closePostID && currentFlagValue && tmpFlagValue >= currentFlagValue) {
                    //NSLog(@"On a trouvé plus grand, on set");
                    closePostID = tmpFlagValue;
                    ifCurrentFlag = YES;
                }
                else {
                    //NSLog(@"0, on set le premier");
                    closePostID = tmpFlagValue;
                }
                
                //NSLog(@"-- curFlagID = %d", tmpFlagValue);
            }

        }
        
        if (closePostID) {
            //NSLog(@"On remplace au plus proche");
            self.stringFlagTopic = [NSString stringWithFormat:@"#t%d", closePostID];
        }
        
        NSLog(@"NEW %@", self.stringFlagTopic);

        
        NSString *refreshBtn = [[[NSString alloc] initWithString:@""] autorelease];
        
        //on ajoute le bouton actualiser si besoin
        if (([self pageNumber] == [self lastPageNumber]) || ([self lastPageNumber] == 0)) {
            //NSLog(@"premiere et unique ou dernier");
            //'before'
            refreshBtn = @"<div id=\"actualiserbtn\">Actualiser</div>";
            
        }
        else {
            //NSLog(@"autre");
        }
        
        NSString *tooBar = [[[NSString alloc] initWithString:@""] autorelease];
        
        //Toolbar;
        if (self.aToolbar && !self.isSearchInstra) {
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
        else if (self.isSearchInstra) {
            tooBar = [NSString stringWithFormat:@"<a href=\"oijlkajsdoihjlkjasdoauto://submitsearch\" id=\"searchintra_nextbutton\">Résultats suivants &raquo;</a>"];
        }
        
        
        
        NSString *customFontSize = [self userTextSizeDidChange];
        
        NSString *HTMLString = [NSString
                                stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
                                <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">\
                                <head>\
                                <script type='text/javascript' src='jquery-2.1.1.min.js'></script>\
                                <script type='text/javascript' src='jquery.doubletap.js'></script>\
                                <script type='text/javascript' src='jquery.base64.js'></script>\
                                <meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no' />\
                                <link type='text/css' rel='stylesheet' href='style-liste.css'/>\
                                <link type='text/css' rel='stylesheet' href='style-liste-retina.css' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\
                                <style type='text/css'>\
                                %@\
                                </style>\
                                </head><body class='iosversion'><a name='top'></a>\
                                <div class='bunselected nosig' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'>%@</div>\
                                %@\
                                %@\
                                <div id='endofpage'></div>\
                                <div id='endofpagetoolbar'></div>\
                                <a name='bas'></a>\
                                <script type='text/javascript'>\
                                document.addEventListener('DOMContentLoaded', loadedML);\
                                document.addEventListener('touchstart', touchstart);\
                                function loadedML() { document.location.href = 'oijlkajsdoihjlkjasdopreloaded://preloaded'; setTimeout(function() {document.location.href = 'oijlkajsdoihjlkjasdoloaded://loaded';},700); };\
                                function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; }\
                                function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; }\
                                function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}}\
                                $('img').error(function(){ $(this).attr('src', 'photoDefaultfailmini.png');});\
                                function touchstart() { document.location.href = 'oijlkajsdoihjlkjasdotouch://touchstart'};\
                                </script>\
                                </body></html>", customFontSize, tmpHTML, refreshBtn, tooBar];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            if (self.isSearchInstra) {
                HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7 searchintra"];
            }
            else {
                HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
            }
        }
        //  HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"hfrplusiosversion" withString:@""];
        
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        //NSLog(@"baseURL %@", baseURL);
        
        //NSLog(@"======================================================================================================");
        //NSLog(@"HTMLString %@", HTMLString);
        //NSLog(@"======================================================================================================");
        //NSLog(@"baseURL %@", baseURL);
        //NSLog(@"======================================================================================================");
        
        self.loaded = NO;
        [self.messagesWebView loadHTMLString:HTMLString baseURL:baseURL];
        
        [self.messagesWebView setUserInteractionEnabled:YES];
    }
 

	//[HTMLString release];
	//[tmpHTML release];

}
- (void)handleLoadedParser:(HTMLParser *)myParser
{
	[self loadDataInTableView:myParser];
}	

// -------------------------------------------------------------------------------
//	didFinishParsing:appList
// -------------------------------------------------------------------------------
- (void)didStartParsing:(HTMLParser *)myParser
{
    [self performSelectorOnMainThread:@selector(handleLoadedParser:) withObject:myParser waitUntilDone:NO];
}

- (void)didFinishParsing:(NSArray *)appList
{
    [self performSelectorOnMainThread:@selector(handleLoadedApps:) withObject:appList waitUntilDone:NO];
    [self.queue release], self.queue = nil;
}

#pragma mark -
#pragma mark WebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//NSLog(@"== webViewDidStartLoad");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishPreLoadDOM {
    //NSLog(@"== webViewDidFinishPreLoadDOM");

    [self userTextSizeDidChange];
}

- (void)webViewDidFinishLoadDOM
{
    //NSLog(@"== webViewDidFinishLoadDOM");
    if (self.loaded) {
        //NSLog(@"deja DOMed");
        return;
    }
    
    self.loaded = YES;
    
    //Position du Flag
    //NSString* jsString10 = [NSString stringWithFormat:@"window.location.hash='#top';"];
    //[self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString10];
    
    //NSString* jsString11 = [NSString stringWithFormat:@"window.location.hash='%@';", self.stringFlagTopic];
    //[self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString11];
    
    //bug iOS9--
    //if (SYSTEM_VERSION_LESS_THAN(@"9")) {
        NSString* jsString2 = @"window.location.hash='#bas';";
        NSString* jsString3 = [NSString stringWithFormat:@"window.location.hash='%@'", ![self.stringFlagTopic isEqualToString:@""] ? self.stringFlagTopic : @"#top"];
    
        [self.messagesWebView stringByEvaluatingJavaScriptFromString:[jsString2 stringByAppendingString:jsString3]];
//        [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString3];
    //}
    //Position du Flag
    
	NSString *jsString = [[[NSString alloc] initWithString:@""] autorelease];
    
    NSLog(@"jsString2 %@", jsString2);
    NSLog(@"jsString3 %@", jsString3);
    
    
	//on ajoute le bouton actualiser si besoin
	if (([self pageNumber] == [self lastPageNumber]) || ([self lastPageNumber] == 0)) {
		//NSLog(@"premiere et unique ou dernier");
		//'before'
		jsString = [jsString stringByAppendingString:[NSString stringWithFormat:@"$('#actualiserbtn').click( function(){ window.location = 'oijlkajsdoihjlkjasdorefresh://data'; });"]];
		
	}
	
	jsString = [jsString stringByAppendingString:@"$('.message').addSwipeEvents().bind('doubletap', function(evt, touch) { window.location = 'oijlkajsdoihjlkjasdodetails://'+this.id; });"];
	jsString = [jsString stringByAppendingString:@"$('.header').click(function(event) { var offset = $(this).offset(); event.stopPropagation(); window.location = 'oijlkajsdoihjlkjasdopopup://'+(offset.top-window.pageYOffset)+'/'+this.parentNode.id; });"];
	
	jsString = [jsString stringByAppendingString:@"$('.hfrplusimg').click(function() { window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); });"];

    [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString];

    [self.loadingView setHidden:YES];
    [self.messagesWebView setHidden:NO];

    self.lastStringFlagTopic = self.stringFlagTopic;
    self.stringFlagTopic = @"";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"== webViewDidFinishLoad");
    
    if (!self.loaded) {
        [self webViewDidFinishPreLoadDOM];
    }
    
    [self webViewDidFinishLoadDOM];
    
    [webView.scrollView setContentSize: CGSizeMake(300, webView.scrollView.contentSize.height)];
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    //NSLog(@"== webViewDidFinishLoad OK");

}
/*
//NSSelectorFromString([[[self arrayAction] objectAtIndex:curPostID] objectForKey:@"code"])
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    NSLog(@"=== %@ %d %@", NSStringFromSelector(selector), [UIMenuController sharedMenuController].menuItems.count, sender);

    
    //BOOL canI = [super canPerformAction:selector withSender:sender];
    
    //NSLog(@"canPerformAction %d %@", canI, NSStringFromSelector(selector));
    
    //return canI;
    
    //NSLog(@"editMenuHidden %@ %d", sender, [UIMenuController sharedMenuController].menuItems.count);

    
	for (id tmpAction in self.arrayAction) {
		if (selector == NSSelectorFromString([tmpAction objectForKey:@"code"])) {
            NSLog(@"YES");
			return YES;
		}
	}
	
    
	
	return NO;
}
*/
	 
- (BOOL) canBecomeFirstResponder {
	//NSLog(@"canBecomeFirstResponder");
	
    return YES;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%d, got:%d | url:%@", UIWebViewNavigationTypeLinkClicked, navigationType, [aRequest.URL absoluteString]);
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
                    
		if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoauto"]) {
			[self goToPage:[[aRequest.URL absoluteString] lastPathComponent]];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"file"]) {
            
            if ([[[aRequest.URL pathComponents] objectAtIndex:0] isEqualToString:@"/"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
                //NSLog(@"pas la meme page / topic");
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
                
                self.navigationItem.backBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                 style: UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                    self.navigationItem.backBarButtonItem.title = @" ";
                }
                
                //NSLog(@"push message liste");
                [self.navigationController pushViewController:messagesTableViewController animated:YES];  
            }
            

            
           // NSLog(@"clicked [[aRequest.URL absoluteString] %@", [aRequest.URL absoluteString]);
          //  NSLog(@"clicked [[aRequest.URL pathComponents] %@", [aRequest.URL pathComponents]);
          //  NSLog(@"clicked [[aRequest.URL path] %@", [aRequest.URL path]);
          //  NSLog(@"clicked [[aRequest.URL lastPathComponent] %@", [aRequest.URL lastPathComponent]);
            
			return NO;
		}
		else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
            
            //NSLog(@"%@", aRequest.URL);
            
            MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", kForumURL] withString:@""]];
            self.messagesTableViewController = aView;
            [aView release];
            
            //setup the URL
            self.messagesTableViewController.topicName = @"";
            self.messagesTableViewController.isViewed = YES;
            
            self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                             style: UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                self.navigationItem.backBarButtonItem.title = @" ";
            }
            
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
		if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdodetails"]) {
            //NSLog(@"details ==========");
			[self didSelectMessage:[[[aRequest.URL absoluteString] lastPathComponent] intValue]];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdotouch"]) {
			//NSLog(@"touch %@", [[aRequest.URL absoluteString] lastPathComponent]);
            if ([[[aRequest.URL absoluteString] lastPathComponent] isEqualToString:@"touchstart"]) {
                if ([UIMenuController sharedMenuController].isMenuVisible) {
                    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
                }
            }
			return NO;
		}
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopreloaded"]) {
            [self webViewDidFinishPreLoadDOM];
            return NO;
        }
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoloaded"]) {
			[self webViewDidFinishLoadDOM];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdorefresh"]) {
			[self searchNewMessages:kNewMessageFromUpdate];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopopup"]) {
			//NSLog(@"oijlkajsdoihjlkjasdopopup");
			int ypos = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] intValue];
			int curMsg = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:2] intValue];
			//NSLog(@"%d %d", ypos, curMsg);

			[self performSelector:@selector(showMenuCon:andPos:) withObject:[NSNumber numberWithInt:curMsg]  withObject:[NSNumber numberWithInt:ypos]];
			return NO;
		}
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoimbrows"]) {
            NSString *regularExpressionString = @"oijlkajsdoihjlkjasdoimbrows://[^/]+/(.*)";
            
            NSString *imgUrl = [[[[aRequest.URL absoluteString] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [self didSelectImage:[[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] intValue] withUrl:imgUrl];

            return NO;
        }
        
        
	}
    
	return YES;
}

-(void) showMenuCon:(NSNumber *)curMsgN andPos:(NSNumber *)posN {
	
	[self.arrayAction removeAllObjects];
	
	int curMsg = [curMsgN intValue];
	int ypos = [posN intValue];
	
    
    NSString *answString = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        answString = @"Répondre";
    }
    else
    {
        answString = @"Rép.";
    }
    
    //UIImage *menuImgBan = [UIImage imageNamed:@"RemoveUserFilled-20"];
    UIImage *menuImgBan = [UIImage imageNamed:@"ThorHammer-20"];
    if ([[BlackList shared] isBL:[[arrayData objectAtIndex:curMsg] name]]) {
        menuImgBan = [UIImage imageNamed:@"ThorHammerFilled-20"];
    }

    UIImage *menuImgEdit = [UIImage imageNamed:@"EditColumnFilled-20"];
    UIImage *menuImgProfil = [UIImage imageNamed:@"ContactCardFilled-20"];
    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgMP = [UIImage imageNamed:@"MessageFilled-20"];
    UIImage *menuImgFav = [UIImage imageNamed:@"StarFilled-20"];

    //UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"QuoteFilled-20"];
    //UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"Quote-20"];

    UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"ReplyAllArrowFilled-20"];
    UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"ReplyAllArrow-20"];

    UIImage *menuImgDelete = [UIImage imageNamed:@"DeleteColumnFilled-20"];
    UIImage *menuImgAlerte = [UIImage imageNamed:@"HighPriorityFilled-20"];

	if([[arrayData objectAtIndex:curMsg] urlEdit]){
		//NSLog(@"urlEdit");
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Editer", @"EditMessage", menuImgEdit, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        
        if (curMsg) { //Pas de suppression du premier message d'un topic (curMsg = 0);
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Supprimer", @"actionSupprimer", menuImgDelete, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }

		if (self.navigationItem.rightBarButtonItem.enabled) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
		}
	}
	else {
		//NSLog(@"profil");
		if (self.navigationItem.rightBarButtonItem.enabled) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
		}


		

	}


	
	//"Citer ☑"@"Citer ☒"@"Citer ☐"	
	if([[arrayData objectAtIndex:curMsg] quoteJS] && self.navigationItem.rightBarButtonItem.enabled) {
		NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
		components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
		components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		NSArray *quoteComponents = [components componentsSeparatedByString:@","];
		
		NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
		NSString *quotes = [self LireCookie:nameCookie];
		
		if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☐", @"actionCiter", menuImgMultiQuoteUnchecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
			
		}
		else {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☑", @"actionCiter", menuImgMultiQuoteChecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
			
		}
		
	}


    if(![[arrayData objectAtIndex:curMsg] urlEdit]){
        
        if([[arrayData objectAtIndex:curMsg] MPUrl]){
            //NSLog(@"MPUrl");
            
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"MP", @"actionMessage", menuImgMP, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
        
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Blacklist", @"actionBL", menuImgBan, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Profil", @"actionProfil", menuImgProfil, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

        if([[arrayData objectAtIndex:curMsg] urlAlert]){

            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alerter", @"actionAlerter", menuImgAlerte, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
    }
    
    
    if ([self canBeFavorite]) {
        //NSLog(@"isRedFlagged ★");
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Favoris", @"actionFavoris", menuImgFav, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    }
    
	
	self.curPostID = curMsg;
	/*
	UIActionSheet *styleAlert = [[UIActionSheet alloc] init];
	for (id tmpAction in self.arrayAction) {
		[styleAlert addButtonWithTitle:[tmpAction valueForKey:@"title"]];
	}	
	
	[styleAlert addButtonWithTitle:@"Annuler"];
	
	styleAlert.cancelButtonIndex = self.arrayAction.count;
	styleAlert.delegate = self;
	
	styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
	//[styleAlert showFromTabBar:[[[HFRplusAppDelegate sharedAppDelegate] rootController] tabBar]];
	[styleAlert release];
	
	*/
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	//[menuController setMenuVisible:YES animated:YES];
	
	NSMutableArray *menuAction = [[NSMutableArray alloc] init];
	

    
	for (id tmpAction in self.arrayAction) {
		//NSLog(@"%@", [tmpAction objectForKey:@"code"]);
		
        if ([tmpAction objectForKey:@"image"] != nil) {
            UIMenuItem *tmpMenuItem2 = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"]) image:(UIImage *)[tmpAction objectForKey:@"image"]];
            [menuAction addObject:tmpMenuItem2];
        }
        else {
            UIMenuItem *tmpMenuItem = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"])];
            [menuAction addObject:tmpMenuItem];
        }

	}	
	[menuController setMenuItems:menuAction];
	[menuAction release];
	//NSLog(@"menuAction %d", menuAction.count);
	
	//NSLog(@"ypos %d", ypos);
	

    
	if (ypos < 40) {

		ypos +=34;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7,0")) {
            ypos +=10;
        }
		[menuController setArrowDirection:UIMenuControllerArrowUp];
	}
	else {
		[menuController setArrowDirection:UIMenuControllerArrowDown];
	}
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7,0")) {
        //ypos += 66;
    }
    
	//NSLog(@"oijlkajsdoihjlkjasdopopup 0");
	
	//CGRect myFrame = [[self.view superview] frame];
	//myFrame.size.width-20
	//NSLog(@"%f", myFrame.size.width);
	
	CGRect selectionRect = CGRectMake(38, ypos, 0, 0);
	
	
	[self.view setNeedsDisplayInRect:selectionRect];
	[menuController setTargetRect:selectionRect inView:self.view];
	//[menuController setMenuVisible:YES animated:YES];
	
	//[menuController setTargetRect:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) inView:self.view];
	
	[menuController setMenuVisible:YES animated:YES];
	//[menuController setMenuVisible:YES];
	//[menuController setMenuVisible:NO];
	
	//NSLog(@"oijlkajsdoihjlkjasdopopup");	
}
/*
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"MTV clickedButtonAtIndex %d %d", buttonIndex, curPostID);
	if (buttonIndex < [self.arrayAction count]) {
		
		
		[self performSelector:NSSelectorFromString([[self.arrayAction objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:[NSNumber numberWithInt:curPostID]];
	}
	
}
*/
#pragma mark -
#pragma mark sharedMenuController management


-(void)actionFavoris:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];

	//NSLog(@"actionFavoris %@", [[arrayData objectAtIndex:curMsg] addFlagUrl]);
	
	ASIHTTPRequest  *aRequest =  
	[[[ASIHTTPRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [[arrayData objectAtIndex:curMsg] addFlagUrl]]]] autorelease];
	[aRequest startSynchronous];
	
	if (request) {
		
		if ([aRequest error]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:[[request error] localizedDescription]
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
			
			//[responseView setText:[[request error] localizedDescription]];
		} else if ([aRequest responseString]) {
			NSString *responseString = [aRequest responseString];
			responseString = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			
			NSString *regExMsg = @".*<div class=\"hop\">([^<]+)</div>.*";
			NSPredicate *regExErrorPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExMsg];
			BOOL isRegExMsg = [regExErrorPredicate evaluateWithObject:responseString];
			
			if (isRegExMsg) {
				//KO
                //NSLog(@"%@", [responseString stringByMatching:regExMsg capture:1L]);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[responseString stringByMatching:regExMsg capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[alert release];
			}
		}
	}	
	
	
}
-(void)actionProfil:(NSNumber *)curMsgN {
    int curMsg = [curMsgN intValue];

    ProfilViewController *profilVC = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil andUrl:[[arrayData objectAtIndex:curMsg] urlProfil]];
    
    // Set options
    profilVC.wantsFullScreenLayout = YES;
    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:profilVC];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:nc animated:YES];
    [nc release];
    
    
	
}

-(void) actionAlerter:(NSNumber *)curMsgN {
    NSLog(@"actionAlerter %@", curMsgN);
    if (self.isAnimating) {
        return;
    }
    
    int curMsg = [curMsgN intValue];
    
    NSString *alertUrl = [NSString stringWithFormat:@"%@%@", kForumURL, [[arrayData objectAtIndex:curMsg] urlAlert]];
    
    AlerteModoViewController *alerteMessageViewController = [[AlerteModoViewController alloc]
                                                             initWithNibName:@"AlerteModoViewController" bundle:nil];
    alerteMessageViewController.delegate = self;
    [alerteMessageViewController setUrl:alertUrl];
    
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:alerteMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    [navigationController release];
    [alerteMessageViewController release];
    
    
}
-(void) actionSupprimer:(NSNumber *)curMsgN {
    NSLog(@"actionSupprimer %@", curMsgN);
    if (self.isAnimating) {
        return;
    }

    int curMsg = [curMsgN intValue];
    
    NSString *editUrl = [NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString]];

    DeleteMessageViewController *delMessageViewController = [[DeleteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
    delMessageViewController.delegate = self;
    [delMessageViewController setUrlQuote:editUrl];
    
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:delMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    [navigationController release];
    [delMessageViewController release];
}

-(void) actionBL:(NSNumber *)curMsgN {
    
    int curMsg = [curMsgN intValue];
    
    NSString *username = [[arrayData objectAtIndex:curMsg] name];
    NSString *promptMsg = @"";
    
    if ([[BlackList shared] removeWord:username]) {
        promptMsg = [NSString stringWithFormat:@"%@ a été supprimé de la liste noire", username];
    }
    else {
        [[BlackList shared] add:username];
        promptMsg = [NSString stringWithFormat:@"BIM! %@ ajouté à la liste noire", username];
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:promptMsg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

    
}

-(void)actionMessage:(NSNumber *)curMsgN {
	if (self.isAnimating) {
		return;
	}
	
	int curMsg = [curMsgN intValue];
	
	//NSLog(@"actionMessage %d = %@", curMsg, curMsgN);
	//[[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", forumNewTopicUrl]];
	
	NewMessageViewController *editMessageViewController = [[NewMessageViewController alloc]
														   initWithNibName:@"AddMessageViewController" bundle:nil];
	editMessageViewController.delegate = self;
	[editMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", kForumURL, [[arrayData objectAtIndex:curMsg] MPUrl]]];
	editMessageViewController.title = @"Nouv. Message";
	// Create the navigation controller and present it modally.
	HFRNavigationController *navigationController = [[HFRNavigationController alloc]
													initWithRootViewController:editMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
    
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
	[navigationController release];
	[editMessageViewController release];
}

-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur {
	//NSLog(@"EcrireCookie");
	
	NSMutableDictionary *	outDict = [NSMutableDictionary dictionaryWithCapacity:5];
	[outDict setObject:nom forKey:NSHTTPCookieName];
	[outDict setObject:valeur forKey:NSHTTPCookieValue];
	[outDict setObject:[[NSDate date] dateByAddingTimeInterval:(60*60)] forKey:NSHTTPCookieExpires];
	[outDict setObject:@".hardware.fr" forKey:NSHTTPCookieDomain];
	[outDict setObject:@"/" forKey:@"Path"];		// This does work.
	
	NSHTTPCookie	*	cookie = [NSHTTPCookie cookieWithProperties:outDict];
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[cookShared setCookie:cookie];
}

-(NSString *)LireCookie:(NSString *)nom {
	//NSLog(@"LireCookie");
	
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookShared cookies];
	
	for (NSHTTPCookie *aCookie in cookies) {
		if ([[aCookie name] isEqualToString:nom]) {
			
			if ([[NSDate date] timeIntervalSinceDate:[aCookie expiresDate]] <= 0) {
				return [aCookie value];
			}
			
		}
		
	}
	
	return @"";
	
}
-(void)  EffaceCookie:(NSString *)nom {
	//NSLog(@"EffaceCookie");
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookShared cookies];
	
	for (NSHTTPCookie *aCookie in cookies) {
		if ([[aCookie name] isEqualToString:nom]) {
			[cookShared deleteCookie:aCookie];
		}
		
	}
	
	return;
}


-(void)actionCiter:(NSNumber *)curMsgN {
	//NSLog(@"actionCiter %@", curMsgN);
	
	int curMsg = [curMsgN intValue];
	NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
	components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
	components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
	
	NSArray *quoteComponents = [components componentsSeparatedByString:@","];
	
	NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
	NSString *quotes = [self LireCookie:nameCookie];
	
	//NSLog(@"quotes APRES LECTURE %@", quotes);
	
	if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
		quotes = [quotes stringByAppendingString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]];
	}
	else {
		quotes = [quotes stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]] withString:@""];
	}
	
	
	if (quotes.length == 0) {
		//
		//NSLog(@"quote vide");
		[self EffaceCookie:nameCookie];
	}
	else
	{
		//NSLog(@"nameCookie %@", nameCookie);
		//NSLog(@"quotes %@", quotes);
		[self EcrireCookie:nameCookie withVal:quotes];
	}
	
	//[self.messageView stringByEvaluatingJavaScriptFromString:@"quoter('hardwarefr','prive',1556872,1962548600);"];
	//NSLog(@"actionCiter %@", [NSDate date]);
	
	//NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	//NSArray *cookies = [cookShared cookies];
	
	//for (NSHTTPCookie *aCookie in cookies) {
	//	NSLog(@"%@", aCookie);
	//}
	
	
}

-(void)EditMessage:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];
	
	[self setEditFlagTopic:[[arrayData objectAtIndex:curMsg] postID]];
	[self editMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString]]];
	
}

-(void)QuoteMessage:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];
	
	[self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]]];
}

-(void)actionFavoris {
	[self actionFavoris:[NSNumber numberWithInt:curPostID]];
	
}
-(void)actionProfil {
	[self actionProfil:[NSNumber numberWithInt:curPostID]];
	
}	
-(void)actionMessage {
	[self actionMessage:[NSNumber numberWithInt:curPostID]];
	
}
-(void)actionBL {
    [self actionBL:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionAlerter {
    [self actionAlerter:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionSupprimer {
    [self actionSupprimer:[NSNumber numberWithInt:curPostID]];
    
}

-(void)actionCiter {
	[self actionCiter:[NSNumber numberWithInt:curPostID]];
}

-(void)EditMessage {
	[self EditMessage:[NSNumber numberWithInt:curPostID]];	
}

-(void)QuoteMessage
{
	[self QuoteMessage:[NSNumber numberWithInt:curPostID]];
}

- (NSString *) userTextSizeDidChange {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_text"] isEqualToString:@"sys"]) {
        if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
            CGFloat userFontSize = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody].pointSize;
            userFontSize = floorf(userFontSize*0.90);
            NSString *script = [NSString stringWithFormat:@"$('.message .content .right').css('cssText', 'font-size:%fpx !important');", userFontSize];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right table.code *').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right p.editedhfrlink').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            
            [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
            
            return [NSString stringWithFormat:@".message .content .right { font-size:%fpx !important; }", userFontSize];
            
            //NSLog(@"userFontSize %@", script);
        }
    }
    
    return @"";
    
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	//NSLog(@"viewDidUnload Messages Table View");
	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.loadingView = nil;
    self.errorLabelView = nil;
    
	[self.messagesWebView stopLoading];
	self.messagesWebView.delegate = nil;
	self.messagesWebView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	

    [self setSearchFromFP:nil];
    [self setSearchFilter:nil];
	[super viewDidUnload];
	
	
}

- (void)dealloc {
	NSLog(@"dealloc Messages Table View");
	
	[self viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VisibilityChanged" object:nil];
    
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }


	[self.queue cancelAllOperations];
	[self.queue release];
	
	[request cancel];
	[request setDelegate:nil];
	self.request = nil;
	
	self.topicAnswerUrl = nil;
	self.topicName = nil;
	
    self.pollNode = nil;
    
	//[self.arrayData removeAllObjects];
	[self.arrayData release], self.arrayData = nil;
	[self.updatedArrayData release], self.updatedArrayData = nil;
	
	if(self.detailViewController) self.detailViewController = nil;
	
	self.swipeLeftRecognizer = nil;
	self.swipeRightRecognizer = nil;
	
    
    self.styleAlert = nil;
    
    self.lastStringFlagTopic = nil;
	self.stringFlagTopic = nil;
	self.arrayInputData = nil;
		
	self.aToolbar = nil;
	self.editFlagTopic = nil;
	
	self.isFavoritesOrRead = nil;
	self.arrayAction = nil;
    self.arrayActionsMessages = nil;
    
    self.searchInputData = nil;
    
    [super dealloc];
	
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

    ASIFormDataRequest  *arequest = [[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/transsearch.php", kForumURL]]] autorelease];
    
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
        [alert release];
        return;
    }
    
    [self toggleSearch:NO];

    if (self.isSearchInstra) {
        self.currentUrl = baseURL;
        [self fetchContent:kNewMessageFromUnkwn];
    }
    else {
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:baseURL];
        self.messagesTableViewController = aView;
        [aView release];
        
        //setup the URL
        [self.messagesTableViewController setTopicName:[NSString stringWithString:self.topicName]];
        self.messagesTableViewController.isViewed = YES;
        self.messagesTableViewController.isSearchInstra = YES;
        [self.messagesTableViewController setSearchInputData:[NSMutableDictionary dictionaryWithDictionary:self.searchInputData]];
        
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
                NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)[value objectForKey:subKey],
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8);
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)subValue,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8);
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else {
            NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)[params objectForKey:key],
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
            [escaped_value release];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}
@end