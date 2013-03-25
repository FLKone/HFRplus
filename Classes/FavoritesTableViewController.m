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

@implementation FavoritesTableViewController
@synthesize pressedIndexPath, favoritesTableView, loadingView, showAll;
@synthesize arrayNewData; //v2 remplace arrayData, arrayDataID, arrayDataID2, arraySection
@synthesize messagesTableViewController;

@synthesize request;

@synthesize status, statusMessage, maintenanceView, pageNumberField, topicActionSheet;

#pragma mark -
#pragma mark Data lifecycle

-(void) showAll:(id)sender {
    
    //NSLog(@"showAll %d", self.showAll);
    if (self.showAll) {
        self.showAll = NO;
    }
    else {
        self.showAll = YES;
    }

    if (![self.favoritesTableView isHidden]) {
        [self.favoritesTableView beginUpdates];
        [self.favoritesTableView reloadData];
        [self.favoritesTableView endUpdates];
    }
    
}

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];

    
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
	
	[self.maintenanceView setHidden:YES];
	[self.favoritesTableView setHidden:YES];
	[self.loadingView setHidden:NO];	
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentComplete");

	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[self.arrayNewData removeAllObjects];
	
	//[self.favoritesTableView reloadData];
	
	[self loadDataInTableView:[request responseData]];
	
	[self.loadingView setHidden:YES];	
    
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:            
			[self.maintenanceView setText:self.statusMessage];
			[self.maintenanceView setHidden:NO];
			[self.favoritesTableView setHidden:YES];
			break;
		default:
			[self.favoritesTableView reloadData];			
			[self.favoritesTableView setHidden:NO];			
			break;
	}
	
	//NSLog(@"fetchContentCompletefetchContentCompletefetchContentComplete");
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[self.loadingView setHidden:YES];
	
	//NSLog(@"theRequest.error %@", theRequest.error);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert show];
	[alert release];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1 && alertView.tag == 669) {
        
        NSIndexPath *path = self.pressedIndexPath;
        Topic *aTopic = [[[self.arrayNewData objectAtIndex:[path section]] topics] objectAtIndex:[path row]];
        
        NSString * newUrl = [aTopic aURL];
        
        //NSLog(@"newUrl %@", newUrl);
        
        //On remplace le numéro de page dans le titre
        int number = [[pageNumberField text] intValue];
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
        
        //newUrl = [newUrl stringByReplacingOccurrencesOfString:@"_1.htm" withString:[NSString stringWithFormat:@"_%d.htm", [[pageNumberField text] intValue]]];
        //newUrl = [newUrl stringByReplacingOccurrencesOfString:@"page=1&" withString:[NSString stringWithFormat:@"page=%d&", [[pageNumberField text] intValue]]];
        
        
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
		[self fetchContent];
	}
}

-(void)reset {
	/*
	[self fetchContent];
	*/
	[self.arrayNewData removeAllObjects];
	
	[self.favoritesTableView reloadData];
	[self.favoritesTableView setHidden:YES];
	[self.maintenanceView setHidden:YES];	
	[self.loadingView setHidden:YES];
	
}
//-- V2

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData {

	[self.arrayNewData removeAllObjects];
	
    NSLog(@"loadDataInTableView");

	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];

	if (![bodyNode getAttributeNamed:@"id"]) {
		if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
			NSLog(@"p");
			
			self.status = kMaintenance;
			self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			[myParser release];
			return;
		}
		
		NSLog(@"id");
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
		needToUpdateMP = YES;
	}
	//MP
	
	//v1
    NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"sujet ligne_booleen" allowPartial:YES]; //Get topics for cat
    
	if (temporaryTopicsArray.count == 0) {
		//NSLog(@"Aucun nouveau message %d", self.arrayDataID.count);
		self.status = kNoResults;
		self.statusMessage = @"Aucun nouveau message";
		[myParser release];
		return;
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
                [self.arrayNewData addObject:aFavorite];
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
        [self.arrayNewData addObject:aFavorite];
        [aFavorite release];
    }
    
	[myParser release];
	self.status = kComplete;

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
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad ftv");
    [super viewDidLoad];
	
	self.title = @"Vos Sujets";
    self.showAll = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrientationChanged)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
	// reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];		
    
    // showAll
    AKSingleSegmentedControl* segmentedControl = [[AKSingleSegmentedControl alloc] initWithItems:[NSArray array]];
    //[segmentedControl setMomentary:YES];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"icon_list_bullets"] atIndex:0 animated:NO];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem * segmentBarItem2 = [[UIBarButtonItem alloc] initWithCustomView: segmentedControl];
    self.navigationItem.leftBarButtonItem = segmentBarItem2;
    
	//segmentedControl2.segmentedControlStyle = UISegmentedControlStyleBar;
	//segmentedControl2.momentary = YES;
	    
    
    /*
    UIBarButtonItem *segmentBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_bullets.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showAll:)];
	self.navigationItem.leftBarButtonItem = segmentBarItem2;
    [segmentBarItem2 release];
      */  
    
	[(ShakeView*)self.view setShakeDelegate:self];
	
    self.arrayNewData = [[NSMutableArray alloc] init];
    
	self.statusMessage = [[NSString alloc] init];
	
	//NSLog(@"viewDidLoad %d", self.arrayDataID.count);

	[self fetchContent];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.view becomeFirstResponder];

	if (self.messagesTableViewController) {
		//NSLog(@"viewWillAppear Favorites Table View Dealloc MTV");
		
		self.messagesTableViewController = nil;
	}
    
    if (self.pressedIndexPath) 
    {
		self.pressedIndexPath = nil;
    }
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


- (void)loadCatForType:(id)sender {
    
    
    //NSLog(@"loadCatForType %d", [sender tag]);
    int section = [sender tag];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];
    
    TopicsTableViewController *aView;
    
    //NSLog(@"aURL %@", [[[arrayNewData objectAtIndex:section] forum] aURL]);
    
    switch (vos_sujets) {
        case 0:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:2];
            aView.forumFlag1URL = [[[arrayNewData objectAtIndex:section] forum] aURL];
            break;
        case 1:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:1];
            aView.forumFavorisURL = [[[arrayNewData objectAtIndex:section] forum] aURL];
            break;
        default:
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:2];
            aView.forumFlag1URL = [[[arrayNewData objectAtIndex:section] forum] aURL];            
            break;
    }

	aView.forumName = [[[arrayNewData objectAtIndex:section] forum] aTitle];	
	//aView.pickerViewArray = [[arrayNewData objectAtIndex:section] forum] subCats];	
    
	[self.navigationController pushViewController:aView animated:YES];
    
}

#pragma mark -
#pragma mark Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.showAll) {
        return 23;
    }
    else {
        if ([[self.arrayNewData objectAtIndex:section] topics].count > 0) {
            return 23;
        }
    }
    return 0;
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
	

    //NSLog(@"%@", [[self.arrayNewData objectAtIndex:section] forum]);
    Forum *tmpForum = [[self.arrayNewData objectAtIndex:section] forum];
	headerLabel.text = [tmpForum aTitle];
												   
	// create image object
	UIImage *myImage = [UIImage imageNamed:@"bar2.png"];
    
	// create the imageView with the image in it
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
	imageView.alpha = 0.9;
	imageView.frame = CGRectMake(0,0,320,23);
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// create the imageView with the image in it
	UIImageView *imageView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowR"]] autorelease];
	imageView2.alpha = 1;
	imageView2.frame = CGRectMake(295,5,15,15);
	imageView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
	[customView addSubview:imageView];
    
    UIImage *backButton = [[UIImage imageNamed:@"arrowR"] scaleToSize:CGSizeMake(15, 15)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
    [button setTag:section];
    [button setTitle:[tmpForum aTitle] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (self.showAll) {
        [button setImage:backButton forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(2, 297, 0, 0)]; 
    }
    else {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    }
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]]; //18
    [button.titleLabel setShadowColor:[UIColor darkGrayColor]]; //18
    [button.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)]; //18
    [button addTarget:self action:@selector(loadCatForType:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [customView addSubview:button];

	//[customView addSubview:imageView2];
    
	//[customView addSubview:headerLabel];
	
	//if ([(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] selectedSegmentIndex] == 0) {
	//	[customView addSubview:detailLabel];
	//}
	
	return customView;
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//NSLog(@"NB Section %d", self.arrayNewData.count);
	
    return self.arrayNewData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//NSLog(@"%d", section);
	//NSLog(@"titleForHeaderInSection %d %@", section, [[self.arrayNewData objectAtIndex:section] aTitle]);
	return [[[self.arrayNewData objectAtIndex:section] forum] aTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	//NSLog(@"Nb Dans la Section %d %d", section, [[[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:section]] length] intValue]);
	
	
	//return [arrayDataID objectForKey:[arrayDataID2 objectAtIndex:section]];
	
	//NSLog(@"numberOfRowsInSection %d %d", section, [[self.arrayNewData objectAtIndex:section] topics].count);
	
    return [[self.arrayNewData objectAtIndex:section] topics].count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FavoriteCell";
	
    
	
    FavoriteCell *cell = (FavoriteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
    if (cell == nil) {
        cell = [[[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] 
															 initWithTarget:self action:@selector(handleLongPress:)];
		[cell addGestureRecognizer:longPressRecognizer];
		[longPressRecognizer release];		
    }
    	
    Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
	
    // Configure the cell...
	[(UILabel *)[cell.contentView viewWithTag:999] setText:[tmpTopic aTitle]];
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

	if ([tmpTopic isViewed]) {
		[(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont systemFontOfSize:13]];
	}
	else {
		[(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont boldSystemFontOfSize:13]];
		
	}	

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Topic *aTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
    
	MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[aTopic aURL]];
	self.messagesTableViewController = aView;
	[aView release];
	
	//setup the URL
	self.messagesTableViewController.topicName = [aTopic aTitle];	
	
	//NSLog(@"push message liste");
	 [self pushTopic];
	
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
													   otherButtonTitles:	@"la dernière page", @"la dernière réponse", @"la page numéro...",
									 nil,
									 nil];
		
		// use the same style as the nav bar
		self.topicActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
        CGPoint longPressLocation2 = [longPressRecognizer locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = CGRectMake( longPressLocation2.x, longPressLocation2.y, 0, 0);
        
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
            Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
            
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
            Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
            
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
        default:
        {
            NSLog(@"default");
            self.pressedIndexPath = nil;
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
    
    [self setTopicViewed];
    
    
}

-(void)setTopicViewed {
    
	if (self.favoritesTableView.indexPathForSelectedRow && self.arrayNewData.count > 0) {

        NSIndexPath *path = self.favoritesTableView.indexPathForSelectedRow;
        [[[[self.arrayNewData objectAtIndex:[path section]] topics] objectAtIndex:[path row]] setIsViewed:YES];

        NSArray* rowsToReload = [NSArray arrayWithObjects:self.favoritesTableView.indexPathForSelectedRow, nil];
        [self.favoritesTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        
		//[self.favoritesTableView reloadData];
	}
    else if (pressedIndexPath && self.arrayNewData.count > 0) 
    {
        NSIndexPath *path = self.pressedIndexPath;
        [[[[self.arrayNewData objectAtIndex:[path section]] topics] objectAtIndex:[path row]] setIsViewed:YES];
		
        NSArray* rowsToReload = [NSArray arrayWithObjects:self.pressedIndexPath, nil];
        [self.favoritesTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];

    }
    
}

#pragma mark -
#pragma mark chooseTopicPage

-(void)chooseTopicPage {
    //NSLog(@"chooseTopicPage Favs");

    NSIndexPath *indexPath = self.pressedIndexPath;
    Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aller à la page" message:[NSString stringWithFormat:@"\n\n(numéro entre 1 et %d)\n", [tmpTopic maxTopicPage]]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"OK", nil];
	
	pageNumberField = [[UITextField alloc] initWithFrame:CGRectZero];
	[pageNumberField setBackgroundColor:[UIColor whiteColor]];
	[pageNumberField setPlaceholder:@"numéro de la page"];
	//pageNumberField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
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
	
    NSIndexPath *indexPath = self.pressedIndexPath;
    Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];

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
		[pageNumberField becomeFirstResponder];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{    
	//NSLog(@"willDismissWithButtonIndex PT %@", alertView);
    
	if (([alertView tag] == 669)) {
		[self.pageNumberField resignFirstResponder];
		self.pageNumberField = nil;
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

        Topic *tmpTopic = [[[self.arrayNewData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
        
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [tmpTopic postID]] forKey:@"topic0"];
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [tmpTopic catID]] forKey:@"valuecat0"];
		
		[arequest setPostValue:@"hardwarefr" forKey:@"valueforum0"];
		[arequest startAsynchronous]; 
        
        [[[self.arrayNewData objectAtIndex:indexPath.section] topics] removeObjectAtIndex:indexPath.row];
        [self.favoritesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if ([[self.arrayNewData objectAtIndex:indexPath.section] topics].count == 0) {
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


	[self fetchContent];
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

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];

	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	self.statusMessage = nil;
	
    self.topicActionSheet = nil;
    
	self.arrayNewData = nil;
	
    [super dealloc];
}


@end

