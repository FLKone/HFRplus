//
//  FavoritesTableViewController.m
//  HFRplus
//
//  Created by FLK on 05/07/10.
//

#import "HFRplusAppDelegate.h"

#import "FavoritesTableViewController.h"
#import "MessagesTableViewController.h"

#import "HTMLParser.h"
#import	"RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "ShakeView.h"

#import "Topic.h"
#import "Catcounter.h"
#import "FavoriteCell.h"

#import "Favorite.h"
#import "UIImage+Resize.h"

#import "AKSingleSegmentedControl.h"
#import "TopicsTableViewController.h"

#import "UIScrollView+SVPullToRefresh.h"
#import "PullToRefreshErrorViewController.h"

@implementation FavoritesTableViewController
@synthesize pressedIndexPath, favoritesTableView, loadingView, showAll;
@synthesize arrayData, arrayNewData, arrayCategories; //v2 remplace arrayData, arrayDataID, arrayDataID2, arraySection
@synthesize messagesTableViewController;

@synthesize request;

@synthesize status, statusMessage, maintenanceView, topicActionSheet;

#pragma mark -
#pragma mark Data lifecycle

-(void) showAll:(id)sender {
    
    NSLog(@"showAll %d", self.showAll);

    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:237];
    UIButton *btn2 = (UIButton *)[self.navigationController.navigationBar viewWithTag:238];
    
    if (self.showAll) {
        self.showAll = NO;
        [btn setSelected:NO];
        //[btn setHighlighted:NO];
        
        [btn2 setSelected:NO];
        //[btn2 setHighlighted:NO];
        
        //On réaffiche le header
        if (self.childViewControllers.count > 0) {
            [self.favoritesTableView setTableHeaderView:((PullToRefreshErrorViewController *)[self.childViewControllers objectAtIndex:0]).view];
        }
        
    }
    else {
        self.showAll = YES;
        [btn setSelected:YES];
        //[btn setHighlighted:YES];
        
        [btn2 setSelected:YES];
        //[btn2 setHighlighted:YES];
        
        [self.favoritesTableView setTableHeaderView:nil];
    }

    if(self.status == kNoResults)
    {
        if (self.showAll) {
            //[self.favoritesTableView setHidden:NO];
            //[self.maintenanceView setHidden:YES];
        }
        else {
            //[self.favoritesTableView setHidden:YES];
            //[self.maintenanceView setHidden:NO];
        }
    }
    
    if (![self.favoritesTableView isHidden]) {
        [self.favoritesTableView reloadData];
    }
    
}

- (void)cancelFetchContent
{
    //[self.favoritesTableView.pullToRefreshView stopAnimating];
    [request cancel];
}

- (void)fetchContent
{
    NSLog(@"fetchContent");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];

    if (self.showAll) {
        [self showAll:nil];
    }
    
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
	self.status = kIdle;
    
    switch (vos_sujets) {
        case 0:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=1", kForumURL]]]];
            break;
        case 1:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=3", kForumURL]]]];
            break;
        default:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=1", kForumURL]]]];
            break;
    }
    
	[request setDelegate:self];

	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentStarted");
	//Bouton Stop

	self.navigationItem.rightBarButtonItem = nil;	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];

    //[self.favoritesTableView.pullToRefreshView stopAnimating];

    /*
	[self.maintenanceView setHidden:YES];
	[self.favoritesTableView setHidden:YES];
	[self.loadingView setHidden:NO];	
     */
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentComplete");

	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	//[self.arrayNewData removeAllObjects];
    //[self.arrayCategories removeAllObjects];

	//[self.favoritesTableView reloadData];
	
	[self loadDataInTableView:[theRequest responseData]];
	
    [self.arrayData removeAllObjects];
    
    self.arrayData = [NSMutableArray arrayWithArray:self.arrayNewData];
    
    [self.arrayNewData removeAllObjects];
    
	[self.favoritesTableView reloadData];
    
    [self.favoritesTableView.pullToRefreshView stopAnimating];
    [self.favoritesTableView.pullToRefreshView setLastUpdatedDate:[NSDate date]];
    
    /*
	[self.loadingView setHidden:YES];

	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:
            [self.maintenanceView setText:self.statusMessage];

            [self.loadingView setHidden:YES];
			[self.maintenanceView setHidden:NO];
			[self.favoritesTableView setHidden:YES];
			break;
		default:
            [self.favoritesTableView reloadData];

            [self.loadingView setHidden:YES];
            [self.maintenanceView setHidden:YES];
			[self.favoritesTableView setHidden:NO];
			break;
	}
	*/
	//NSLog(@"fetchContentCompletefetchContentCompletefetchContentComplete");
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentFailed");

	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
    [self.maintenanceView setText:@"oops :o"];
    
    //[self.loadingView setHidden:YES];
    //[self.maintenanceView setHidden:NO];
    //[self.favoritesTableView setHidden:YES];
	
	//NSLog(@"theRequest.error %@", theRequest.error);
    [self.favoritesTableView.pullToRefreshView stopAnimating];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert show];
	[alert release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1 && alertView.tag == 669) {
        
        NSIndexPath *path = self.pressedIndexPath;
        Topic *aTopic = [[[self.arrayData objectAtIndex:[path section]] topics] objectAtIndex:[path row]];
        
        NSString * newUrl = [aTopic aURL];
        
        //NSLog(@"newUrl %@", newUrl);
        
        //On remplace le numéro de page dans le titre
        int number = [[[alertView textFieldAtIndex:0] text] intValue];
        NSString *regexString  = @".*page=([^&]+).*";
        NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
        NSRange   searchRange = NSMakeRange(0, newUrl.length);
        NSError  *error2        = NULL;
        //int numPage;
        
        matchedRange = [newUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
        
        if (matchedRange.location == NSNotFound) {
            NSRange rangeNumPage =  [newUrl rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
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

        //NSLog(@"newUrl %@", newUrl);

        //if (self.messagesTableViewController == nil) {
		MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:newUrl];
		self.messagesTableViewController = aView;
		[aView release];
        //}
        
        
        
        //NSLog(@"%@", self.navigationController.navigationBar);
        
        
        //setup the URL
        self.messagesTableViewController.topicName = [aTopic aTitle];	
        
        //NSLog(@"push message liste");
        [self pushTopic];
        
    }    
	else if (buttonIndex == 1) {
		[self.favoritesTableView triggerPullToRefresh];
	}
}

#pragma mark - PullTableViewDelegate



-(void)reset {
	/*
	[self fetchContent];
	*/
	[self.arrayData removeAllObjects];
	
	[self.favoritesTableView reloadData];
	//[self.favoritesTableView setHidden:YES];
	//[self.maintenanceView setHidden:YES];
	//[self.loadingView setHidden:YES];
	
}
//-- V2

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData {

	//[self.arrayNewData removeAllObjects];
	[self.arrayCategories removeAllObjects];
	
    NSLog(@"loadDataInTableView");

	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];

	if (![bodyNode getAttributeNamed:@"id"]) {
        NSDictionary *notif;
        
		if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
            
            notif = [NSDictionary dictionaryWithObjectsAndKeys:   [NSNumber numberWithInt:kMaintenance], @"status",
                     [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"message", nil];

		}
        else {
            notif = [NSDictionary dictionaryWithObjectsAndKeys:   [NSNumber numberWithInt:kNoAuth], @"status",
                     [[[bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"message", nil];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusChangedNotification object:self userInfo:notif];

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
		needToUpdateMP = YES;
	}
	//MP
	
	//v1
    NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"sujet ligne_booleen" allowPartial:YES]; //Get topics for cat
    
	if (temporaryTopicsArray.count == 0) {

        NSLog(@"kNoResults");
        
        NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:   [NSNumber numberWithInt:kNoResults], @"status",
                 @"Aucun nouveau message", @"message", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusChangedNotification object:self userInfo:notif];

	}
	
	//hash_check
	HTMLNode *hash_check = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
	[[HFRplusAppDelegate sharedAppDelegate] setHash_check:[hash_check getAttributeNamed:@"value"]];
	//NSLog(@"hash_check %@", [hash_check getAttributeNamed:@"value"]);
	
    //v2
	HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"main" allowPartial:NO]; //Get favs for cat
	NSArray *temporaryFavoriteArray = [tableNode findChildTags:@"tr"];
    
    BOOL first = YES;
    Favorite *aFavorite;
    NSLog(@"run");
    for (HTMLNode * trNode in temporaryFavoriteArray) { //Loop through all the tags
        
        
        if ([[trNode className] rangeOfString:@"fondForum1fCat"].location != NSNotFound) {
            //NSLog(@"HEADER // SECTION");

            if (!first) {
                if (aFavorite.topics.count > 0) {
                    [self.arrayNewData addObject:aFavorite];
                }
                [self.arrayCategories addObject:aFavorite];
                [aFavorite release];
            }

            aFavorite = [[Favorite alloc] init];
            [aFavorite parseNode:trNode];  
            first = NO;
            
        }
        else if ([[trNode className] rangeOfString:@"ligne_booleen"].location != NSNotFound) {
            //NSLog(@"TOPIC // ROW");
            
            [aFavorite addTopicWithNode:trNode];
        }
        else {
            //NSLog(@"ELSE");
        }
    }
    NSLog(@"run2");
    if (!first) {
        if (aFavorite.topics.count > 0) {
            [self.arrayNewData addObject:aFavorite];
        }
        [self.arrayCategories addObject:aFavorite];
        [aFavorite release];
    }
    
	[myParser release];
	if (self.status != kNoResults) {
        
        NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:   [NSNumber numberWithInt:kComplete], @"status", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusChangedNotification object:self userInfo:notif];
    }
    
    //NSLog(@"self.arrayCategories %@", self.arrayCategories);

}
-(NSString*)wordAfterString:(NSString*)searchString inString:(NSString*)selfString
{
    NSRange searchRange, foundRange, foundRange2, resultRange;//endRange
	
    foundRange = [selfString rangeOfString:searchString];
    //endRange = [selfString rangeOfString:@"&subcat"];
	
    if ((foundRange.length == 0) ||
        (foundRange.location == 0))
    {
        // searchString wasn't found or it was found first in the string
        return @"";
    }
    // start search before the found string
    //searchRange = NSMakeRange(foundRange.location, endRange.location-foundRange.location);
	
	searchRange.location = foundRange.location;
	searchRange.length = foundRange.length + 4;
	
	//NSLog (@"URLS: %@", selfString);
	//NSLog (@"URLS: %@", arrayFavs3);
	
	foundRange2 = [selfString rangeOfString:@"&" options:NSBackwardsSearch range:searchRange];
	
	
    resultRange = NSMakeRange(foundRange.location+foundRange.length, foundRange2.location-foundRange.location-foundRange.length);
	
    return [selfString substringWithRange:resultRange];
}

-(void)OrientationChanged
{
    
    if (self.topicActionSheet) {
        [self.topicActionSheet dismissWithClickedButtonIndex:[self.topicActionSheet cancelButtonIndex] animated:YES];
    }
    
    
    if (self.navigationController.visibleViewController == self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UIView *btn;
            UIView *btn2;
            
            UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
            

            if (UIDeviceOrientationIsLandscape(o)) {
                NSLog(@"LAND IPHONE");
                btn = [self.navigationController.navigationBar viewWithTag:238];
                btn2 = [self.navigationController.navigationBar viewWithTag:237];
                
            }
            else {
                btn = [self.navigationController.navigationBar viewWithTag:237];
                btn2 = [self.navigationController.navigationBar viewWithTag:238];
                
            }
            
            [btn2 setHidden:YES];
            [btn setHidden:NO];
            
            CGRect frame = btn.frame;

            if (UIDeviceOrientationIsLandscape(o)) {
                frame.origin.y = (32 - frame.size.height)/2;
            }
            else {
                frame.origin.y = (44 - frame.size.height)/2;
            }
            
            btn.frame = frame;
            
        }
        
    }


//    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setFrame:CGRect]
}

-(void)StatusChanged:(NSNotification *)notification {
    
    if ([[notification object] class] != [self class]) {
        //NSLog(@"KO");
        return;
    }
    
    NSDictionary *notif = [notification userInfo];
    
    self.status = [[notif valueForKey:@"status"] intValue];
    
    //NSLog(@"StatusChanged %d = %u", self.childViewControllers.count, self.status);

    //on vire l'eventuel header actuel
    if (self.childViewControllers.count > 0) {
        [[self.childViewControllers objectAtIndex:0] removeFromParentViewController];
        self.favoritesTableView.tableHeaderView = nil;
    }
    
    if (self.status == kComplete || self.status == kIdle) {
        NSLog(@"COMPLETE %d", self.childViewControllers.count);

    }
    else
    {
        PullToRefreshErrorViewController *ErrorVC = [[PullToRefreshErrorViewController alloc] initWithNibName:nil bundle:nil andDico:notif];
        [self addChildViewController:ErrorVC];
        
        self.favoritesTableView.tableHeaderView = ErrorVC.view;
        [ErrorVC sizeToFit];
    }
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithNibName");
    
    
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        

    }
    
    return self;
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad ftv");
    [super viewDidLoad];

	self.title = @"Vos Sujets";
    self.showAll = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrientationChanged)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(StatusChanged:)
                                                 name:kStatusChangedNotification
                                               object:nil];
    
	// reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    //UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"categories"] style:UIBarButtonItemStyleBordered target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];		
    
    // showAll
    /*
 //   UIBarButtonItem *segmentBarItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(reload)];

    UIBarButtonItem *segmentBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"categories"] landscapeImagePhone:[UIImage imageNamed:@"categories"] style:UIBarButtonItemStyleDone target:self action:@selector(showAll:)];
    //segmentBarItem2.frame = CGRectMake(0, 0, 40, 40);
	self.navigationItem.leftBarButtonItem = segmentBarItem2;
    [segmentBarItem2 release];
   */
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
    
        UIImage *buttonImage2 = [UIImage imageNamed:@"all_categories_land"];
        UIButton *aButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [aButton2 setAdjustsImageWhenHighlighted:NO];
        
        [aButton2 setImage:buttonImage2 forState:UIControlStateNormal];
        [aButton2 setImage:buttonImage2 forState:UIControlStateSelected];
        [aButton2 setImage:buttonImage2 forState:UIControlStateHighlighted];
        [aButton2 setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateSelected];
        [aButton2 setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateHighlighted];
        //[aButton setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateNormal];
        
        
        
        aButton2.frame = CGRectMake(12.0f,(self.navigationController.navigationBar.frame.size.height - buttonImage2.size.height)/2,buttonImage2.size.width,buttonImage2.size.height);
        aButton2.tag = 238;
        
        [aButton2 addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar insertSubview:aButton2 atIndex:1];
        
        
        
        UIImage *buttonImage = [UIImage imageNamed:@"all_categories"];
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aButton setAdjustsImageWhenHighlighted:NO];
        
        [aButton setImage:buttonImage forState:UIControlStateNormal];
        [aButton setImage:buttonImage forState:UIControlStateSelected];
        [aButton setImage:buttonImage forState:UIControlStateHighlighted];
        [aButton setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateSelected];
        [aButton setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateHighlighted];
        //[aButton setBackgroundImage:[UIImage imageNamed:@"lightBlue.png"] forState:UIControlStateNormal];
        
        
        
        aButton.frame = CGRectMake(8.0f,(self.navigationController.navigationBar.frame.size.height - buttonImage.size.height)/2,buttonImage.size.width,buttonImage.size.height);
        aButton.tag = 237;
        
        [aButton addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar insertSubview:aButton atIndex:1];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIDeviceOrientationIsLandscape(o)) {
                NSLog(@"LAND IPHONE");
                [[self.navigationController.navigationBar viewWithTag:237] setHidden:YES];
                [[self.navigationController.navigationBar viewWithTag:238] setHidden:NO];
            }
            else {
                [[self.navigationController.navigationBar viewWithTag:237] setHidden:NO];
                [[self.navigationController.navigationBar viewWithTag:238] setHidden:YES];
            }
            
        }
        else
        {
            [[self.navigationController.navigationBar viewWithTag:238] setHidden:YES];
        }
        
        /*
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        backButton.customView.frame = CGRectMake(-10.0f,0.0f,backButton.customView.frame.size.width,backButton.customView.frame.size.height);
        NSLog(@"frame %@", NSStringFromCGRect(self.navigationItem.leftBarButtonItem.customView.frame));

        self.navigationItem.leftBarButtonItem = backButton;
        //backButton.customView.frame = CGRectMake(0.0f,0.0f,backButton.customView.frame.size.width,backButton.customView.frame.size.height);

        NSLog(@"frame %@", NSStringFromCGRect(self.navigationItem.leftBarButtonItem.customView.frame));
        //NSLog(@"frame %@", NSStringFromCGRect(self.navigationItem.rightBarButtonItem.frame));
         */
    }
    else
    {
        AKSingleSegmentedControl* segmentedControl = [[AKSingleSegmentedControl alloc] initWithItems:[NSArray array]];
        //[segmentedControl setMomentary:YES];
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon_list_bullets"] atIndex:0 animated:NO];
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segmentedControl addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventValueChanged];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            segmentedControl.tintColor = [UIColor colorWithRed:156/255.f green:161/255.f blue:167/255.f alpha:1.00];
        }
        
        UIBarButtonItem * segmentBarItem2 = [[UIBarButtonItem alloc] initWithCustomView: segmentedControl];
        self.navigationItem.leftBarButtonItem = segmentBarItem2;
        
        [segmentBarItem2 release];
    }
/*


     //segmentedControl2.segmentedControlStyle = UISegmentedControlStyleBar;
	//segmentedControl2.momentary = YES;
	    
    */
    /*
    UIBarButtonItem *segmentBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_bullets.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showAll:)];
	self.navigationItem.leftBarButtonItem = segmentBarItem2;
    [segmentBarItem2 release];
      */  
    
    //Supprime les lignes vides à la fin de la liste
    self.favoritesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
	[(ShakeView*)self.view setShakeDelegate:self];
	
    self.arrayData = [[NSMutableArray alloc] init];
    self.arrayNewData = [[NSMutableArray alloc] init];
    self.arrayCategories = [[NSMutableArray alloc] init];
    
	self.statusMessage = [[NSString alloc] init];
	
	//NSLog(@"viewDidLoad %d", self.arrayDataID.count);

    // setup pull-to-refresh
    
    [self.favoritesTableView addPullToRefreshWithActionHandler:^{
        //NSLog(@"=== BEGIN");
        [self fetchContent];
        //NSLog(@"=== END");
    }];
    
    [self.favoritesTableView triggerPullToRefresh];
    
    //[self fetchContent];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	//[self.view becomeFirstResponder];

	if (self.messagesTableViewController) {
		//NSLog(@"viewWillAppear Favorites Table View Dealloc MTV");
		
		self.messagesTableViewController = nil;
	}
    
    if (self.pressedIndexPath) 
    {
		self.pressedIndexPath = nil;
    }
    
    if (favoritesTableView.indexPathForSelectedRow) {
        [favoritesTableView deselectRowAtIndexPath:favoritesTableView.indexPathForSelectedRow animated:NO];
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
        UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIDeviceOrientationIsLandscape(o)) {
            [[self.navigationController.navigationBar viewWithTag:237] setHidden:YES];
            [[self.navigationController.navigationBar viewWithTag:238] setHidden:NO];
        }
        else
        {
            [[self.navigationController.navigationBar viewWithTag:237] setHidden:NO];
            [[self.navigationController.navigationBar viewWithTag:238] setHidden:YES];
        }
    }
    else {
        [[self.navigationController.navigationBar viewWithTag:237] setHidden:NO];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    [[self.navigationController.navigationBar viewWithTag:237] setHidden:YES];
    [[self.navigationController.navigationBar viewWithTag:238] setHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	//NSLog(@"FT viewDidDisappear %@", self.favoritesTableView.indexPathForSelectedRow);

	[super viewDidDisappear:animated];
	[self.view resignFirstResponder];
	//[(UILabel *)[[favoritesTableView cellForRowAtIndexPath:favoritesTableView.indexPathForSelectedRow].contentView viewWithTag:999] setFont:[UIFont systemFontOfSize:13]];

    
	//[favoritesTableView deselectRowAtIndexPath:favoritesTableView.indexPathForSelectedRow animated:NO];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadCatForSection:(int)section {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];
    
    TopicsTableViewController *aView;
    
    //NSLog(@"aURL %@", [[[arrayNewData objectAtIndex:section] forum] aURL]);
    
    switch (vos_sujets) {
        case 0:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:2];
            aView.forumFlag1URL = [[[arrayCategories objectAtIndex:section] forum] aURL];
            break;
        case 1:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:1];
            aView.forumFavorisURL = [[[arrayCategories objectAtIndex:section] forum] aURL];
            break;
        default:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:2];
            aView.forumFlag1URL = [[[arrayCategories objectAtIndex:section] forum] aURL];
            break;
    }
    
	aView.forumName = [[[arrayCategories objectAtIndex:section] forum] aTitle];
	//aView.pickerViewArray = [[arrayNewData objectAtIndex:section] forum] subCats];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                     style: UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.navigationItem.backBarButtonItem.title = @" ";
    }
    
	[self.navigationController pushViewController:aView animated:YES];
}

- (void)loadCatForType:(id)sender {
    
    
    //NSLog(@"loadCatForType %d", [sender tag]);
    int section = [sender tag];
    
    [self loadCatForSection:section];

    
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showAll) {
        return 44;
    }
    else {
        return 50;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //
    if (self.showAll) {
        return 0;
    }
    else {
        if ([[self.arrayData objectAtIndex:section] topics].count > 0) {
            return HEIGHT_FOR_HEADER_IN_SECTION;
        }
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    //On récupère la section (forum)
    Forum *tmpForum = [[self.arrayData objectAtIndex:section] forum];
    CGFloat curWidth = self.view.frame.size.width;
    
    //UIView globale
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
	customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	//UIImageView de fond
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIImage *myImage = [UIImage imageNamed:@"bar2.png"];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
        imageView.alpha = 0.9;
        imageView.frame = CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [customView addSubview:imageView];
    }
    else {
        //bordures/iOS7
        UIView* borderView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,1/[[UIScreen mainScreen] scale])] autorelease];
        borderView.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView];
        
        UIView* borderView2 = [[[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT_FOR_HEADER_IN_SECTION-1/[[UIScreen mainScreen] scale],curWidth,1/[[UIScreen mainScreen] scale])] autorelease];
        borderView2.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView2];
        
    }
    
    //UIButton clickable pour accéder à la catégorie
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, curWidth, HEIGHT_FOR_HEADER_IN_SECTION)];
    [button setTag:[self.arrayCategories indexOfObject:[self.arrayData objectAtIndex:section]]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [button setTitleColor:[UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1] forState:UIControlStateNormal];
        [button setTitle:[[tmpForum aTitle] uppercaseString] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 0, 0)];
    }
    else
    {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [button setTitle:[tmpForum aTitle] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [button.titleLabel setShadowColor:[UIColor darkGrayColor]];
        [button.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    
    [button addTarget:self action:@selector(loadCatForType:) forControlEvents:UIControlEventTouchUpInside];
    
    [customView addSubview:button];
	
	return customView;
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//NSLog(@"NB Section %d", self.arrayNewData.count);

    if (self.showAll) {
        return 1;
    }
    else {
        return self.arrayData.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//NSLog(@"%d", section);
	//NSLog(@"titleForHeaderInSection %d %@", section, [[self.arrayNewData objectAtIndex:section] aTitle]);
    if (self.showAll) {
        return @"";
    }
    else {
        return [[[self.arrayData objectAtIndex:section] forum] aTitle];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.showAll) {
        return self.arrayCategories.count;
    }
    else {
        return [[self.arrayData objectAtIndex:section] topics].count;
    }
        
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.showAll) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[arrayCategories objectAtIndex:indexPath.row] forum] aTitle]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"FavoriteCell";
        
        
        
        FavoriteCell *cell = (FavoriteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        if (cell == nil) {
            cell = [[[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                 initWithTarget:self action:@selector(handleLongPress:)];
            [cell addGestureRecognizer:longPressRecognizer];
            [longPressRecognizer release];
        }
    	
        Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
        
        // Configure the cell...
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIFont *font1 = [UIFont boldSystemFontOfSize:13.0f];
            if ([tmpTopic isViewed]) {
                font1 = [UIFont systemFontOfSize:13.0f];
            }
            NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[tmpTopic aTitle] attributes: arialDict];
            
            NSString *aTopicAffix = @"";
            if (tmpTopic.isSticky) {
                aTopicAffix = [aTopicAffix stringByAppendingString:@" "];
            }
            if (tmpTopic.isClosed) {
                aTopicAffix = [aTopicAffix stringByAppendingString:@" "];
            }
            
            UIFont *font2 = [UIFont fontWithName:@"fontello" size:15];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:aTopicAffix attributes: arialDict2];
            
            
            [aAttrString2 appendAttributedString:aAttrString1];
            [(UILabel *)[cell.contentView viewWithTag:999] setAttributedText:aAttrString2];
            
        }
        else {
            [(UILabel *)[cell.contentView viewWithTag:999] setText:[tmpTopic aTitle]];
            
            if ([tmpTopic isViewed]) {
                [(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont systemFontOfSize:13]];
            }
            else {
                [(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont boldSystemFontOfSize:13]];
                
            }
        }
        
        
        
        
        //[(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d messages", ([[arrayData objectAtIndex:theRow] aRepCount] + 1)]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];
        
        switch (vos_sujets) {
            case 0:
                [(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"⚑ %d/%d", [tmpTopic curTopicPage], [tmpTopic maxTopicPage] ]];
                break;
            case 1:
                [(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"★ %d/%d", [tmpTopic curTopicPage], [tmpTopic maxTopicPage] ]];
                break;
            default:
                [(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"⚑ %d/%d", [tmpTopic curTopicPage], [tmpTopic maxTopicPage] ]];
                break;
        }
        
        [(UILabel *)[cell.contentView viewWithTag:997] setText:[NSString stringWithFormat:@"%@ - %@", [tmpTopic aAuthorOfLastPost], [tmpTopic aDateOfLastPost]]];
        

        
        return cell;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.showAll) {
        [self loadCatForSection:indexPath.row];
    }
    else {
        
        Topic *aTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
        
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[aTopic aURL]];
        self.messagesTableViewController = aView;
        [aView release];
        
        //setup the URL
        self.messagesTableViewController.topicName = [aTopic aTitle];
        
        //NSLog(@"push message liste");
        [self pushTopic];
        
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.favoritesTableView];
		self.pressedIndexPath = [[self.favoritesTableView indexPathForRowAtPoint:longPressLocation] copy];

        if (self.topicActionSheet != nil) {
            [self.topicActionSheet release], self.topicActionSheet = nil;
        }
        
		self.topicActionSheet = [[UIActionSheet alloc] initWithTitle:@"Aller à..."
																delegate:self cancelButtonTitle:@"Annuler"
												  destructiveButtonTitle:nil
													   otherButtonTitles:	@"la dernière page", @"la dernière réponse", @"la page numéro...", @"Copier le lien",
									 nil,
									 nil];
		
		// use the same style as the nav bar
		self.topicActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
        CGPoint longPressLocation2 = [longPressRecognizer locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = CGRectMake( longPressLocation2.x, longPressLocation2.y, 1, 1);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self.topicActionSheet showFromRect:origFrame inView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view] animated:YES];
        }
        else    
            [self.topicActionSheet showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
		
	}
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			NSIndexPath *indexPath = pressedIndexPath;
            Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
            
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[tmpTopic aURLOfLastPage]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [tmpTopic aTitle];	
			
			 [self pushTopic];	

			//NSLog(@"url pressed last page: %@", [[arrayData objectAtIndex:theRow] lastPageUrl]);
			break;
		}
		case 1:
		{
			NSIndexPath *indexPath = pressedIndexPath;
            Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
            
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[tmpTopic aURLOfLastPost]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [tmpTopic aTitle];	

			 [self pushTopic];	

			//NSLog(@"url pressed last post: %@", [[arrayData objectAtIndex:pressedIndexPath.row] lastPostUrl]);
			break;
			
		}
		case 2:
		{
			NSLog(@"page numero");
            [self chooseTopicPage];
			break;
			
		}
		case 3:
		{
			NSLog(@"copier lien page 1");
			NSIndexPath *indexPath = pressedIndexPath;
            Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"%@%@", kForumURL, [tmpTopic aURLOfFirstPage]];

			break;
			
		}
        default:
        {
            NSLog(@"default");
            self.pressedIndexPath = nil;
            break;
        }
			
	}
  
}

- (void)pushTopic {
    
    if (([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
        
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
    else {
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:messagesTableViewController, nil] animated:YES];
        
        if ([messagesTableViewController.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
            NSLog(@"PUSH ADD BTN");
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = messagesTableViewController.splitViewController.displayModeButtonItem;
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
        }
        
    }
    
    [self setTopicViewed];
    
}

-(void)setTopicViewed {
    
	if (self.favoritesTableView.indexPathForSelectedRow && self.arrayData.count > 0) {

        NSIndexPath *path = self.favoritesTableView.indexPathForSelectedRow;
        [[[[self.arrayData objectAtIndex:[path section]] topics] objectAtIndex:[path row]] setIsViewed:YES];

        //NSArray* rowsToReload = [NSArray arrayWithObjects:self.favoritesTableView.indexPathForSelectedRow, nil];
        //[self.favoritesTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        
		[self.favoritesTableView reloadData];
        
	}
    else if (pressedIndexPath && self.arrayData.count > 0)
    {
        NSIndexPath *path = self.pressedIndexPath;
        [[[[self.arrayData objectAtIndex:[path section]] topics] objectAtIndex:[path row]] setIsViewed:YES];
		
        //NSArray* rowsToReload = [NSArray arrayWithObjects:self.pressedIndexPath, nil];
        //[self.favoritesTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];

        [self.favoritesTableView reloadData];
    }
    
}

#pragma mark -
#pragma mark chooseTopicPage

-(void)chooseTopicPage {
    //NSLog(@"chooseTopicPage Favs");

    NSIndexPath *indexPath = self.pressedIndexPath;
    Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aller à la page" message:nil
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"OK", nil];
	
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = [NSString stringWithFormat:@"(numéro entre 1 et %d)", [tmpTopic maxTopicPage]];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self action:@selector(textFieldTopicDidChange:) forControlEvents:UIControlEventEditingChanged];
    textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
	[alert setTag:669];
	[alert show];
    
	[alert release];

}

-(void)textFieldTopicDidChange:(id)sender {
	//NSLog(@"textFieldDidChange %d %@", [[(UITextField *)sender text] intValue], sender);	
	
    NSIndexPath *indexPath = self.pressedIndexPath;
    Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];

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
			else if ([[(UITextField *)sender text] intValue] > [tmpTopic maxTopicPage]) {
				//NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
				[sender setText:[NSString stringWithFormat:@"%d", [tmpTopic maxTopicPage]]];
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
	//NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 669)) {

	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{    
	//NSLog(@"willDismissWithButtonIndex PT %@", alertView);
    
	if (([alertView tag] == 669)) {

	}
}

#pragma mark -
#pragma mark Delete

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		
		ASIFormDataRequest  *arequest =  
		[[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/modo/manageaction.php?config=hfr.inc&cat=0&type_page=forum1f&moderation=0", kForumURL]]] autorelease];
		//delete

		//NSLog(@"%@", [[HFRplusAppDelegate sharedAppDelegate] hash_check]);
		
		[arequest setPostValue:[[HFRplusAppDelegate sharedAppDelegate] hash_check] forKey:@"hash_check"];
		[arequest setPostValue:@"-1" forKey:@"topic1"];
		[arequest setPostValue:@"-1" forKey:@"topic_statusno1"];
		[arequest setPostValue:@"message_forum_delflags" forKey:@"action_reaction"];
		
		[arequest setPostValue:@"forum1f" forKey:@"type_page"];

        Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
        
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [tmpTopic postID]] forKey:@"topic0"];
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [tmpTopic catID]] forKey:@"valuecat0"];
		
		[arequest setPostValue:@"hardwarefr" forKey:@"valueforum0"];
		[arequest startAsynchronous]; 
        
        [[[self.arrayData objectAtIndex:indexPath.section] topics] removeObjectAtIndex:indexPath.row];
        [self.favoritesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if ([[self.arrayData objectAtIndex:indexPath.section] topics].count == 0) {
            [self.favoritesTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];

        }
		
	}
}

#pragma mark -
#pragma mark Reload

-(void)reload
{
	[self reload:NO];
}

-(void)reload:(BOOL)shake
{
	if (!shake) {

	}

    [self.favoritesTableView triggerPullToRefresh];

//	[self fetchContent];
}


-(void) shakeHappened:(ShakeView*)view
{
	if (![request inProgress]) {
		
		[self reload:YES];		
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.loadingView = nil;
	self.favoritesTableView = nil;
	self.maintenanceView = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	//NSLog(@"dealloc ftv");

	[self viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusChangedNotification object:nil];

	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	self.statusMessage = nil;
	
    self.topicActionSheet = nil;
    
	self.arrayNewData = nil;
    self.arrayData = nil;

    [super dealloc];
}


@end

