//
//  FavoritesTableViewController.m
//  HFR+
//
//  Created by Lace on 05/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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


@implementation FavoritesTableViewController
@synthesize pressedIndexPath, favoritesArray, arrayData, arrayDataID, arrayDataID2, favoritesTableView, loadingView, arraySection;
@synthesize messagesTableViewController;

@synthesize request;

@synthesize status, statusMessage, maintenanceView;

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
	self.status = kIdle;
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=1", kForumURL]]]];
	[request setDelegate:self];

	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
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
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[self.arrayDataID removeAllObjects];
	[self.arrayData removeAllObjects];
	
	[self.arrayDataID2 removeAllObjects];
	[self.arraySection removeAllObjects];
	
	//[self.favoritesTableView reloadData];
	
	[self loadDataInTableView:[request responseData]];
	
	[self.loadingView setHidden:YES];	

	switch (self.status) {
		case kMaintenance:
		case kNoResults:
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
	if (buttonIndex == 1) {
		[self fetchContent];
	}
}

-(void)reset {
	/*
	[self fetchContent];
	*/
	[self.arrayDataID removeAllObjects];
	[self.arrayData removeAllObjects];
	
	[self.arrayDataID2 removeAllObjects];
	[self.arraySection removeAllObjects];
	
	[self.favoritesTableView reloadData];
	[self.favoritesTableView setHidden:YES];
	[self.maintenanceView setHidden:YES];	
	[self.loadingView setHidden:YES];
	
}
//-- V2

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData {

	[self.arrayDataID removeAllObjects];
	[self.arrayData removeAllObjects];
	
	[self.arrayDataID2 removeAllObjects];
	[self.arraySection removeAllObjects];
	
	//NSDate *then = [NSDate date]; // Create a current date

	int globalCounter = -1;	
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];

	//NSLog(@"rawContentsOfNode %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));
	
	if (![bodyNode getAttributeNamed:@"id"]) {
		if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
			NSLog(@"p");
			
			self.status = kMaintenance;
			self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			[myParser release];
			return;
		}
		
		NSLog(@"id");
		self.status = kNoResults;
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
	
	NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"sujet ligne_booleen" allowPartial:YES]; //Get links for cat

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
	
	//Date du jour
	NSDate *nowTopic = [[NSDate alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd-MM-yyyy"];
	NSString *theDate = [dateFormat stringFromDate:nowTopic];
	
	for (HTMLNode * topicNode in temporaryTopicsArray) { //Loop through all the tags
		globalCounter += 1;

		Topic *aTopic = [[Topic alloc] init];

		//POSTID/CATID
		HTMLNode * catIDNode = [topicNode findChildWithAttribute:@"name" matchingName:@"valuecat" allowPartial:YES];
		[aTopic setCatID:[[catIDNode getAttributeNamed:@"value"] intValue]];
		
		HTMLNode * postIDNode = [topicNode findChildWithAttribute:@"name" matchingName:@"topic" allowPartial:YES];
		[aTopic setPostID:[[postIDNode getAttributeNamed:@"value"] intValue]];
		
		//NSLog(@"%d - %d", [[catIDNode getAttributeNamed:@"value"] intValue], [[postIDNode getAttributeNamed:@"value"] intValue]);
		
		//Title
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
		

		
		//URL
		HTMLNode * topicFlagNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase5" allowPartial:NO];
		HTMLNode * topicFlagLinkNode = [topicFlagNode findChildTag:@"a"];

		NSString *aTopicURL = [[NSString alloc] initWithString:[topicFlagLinkNode getAttributeNamed:@"href"]];
		[aTopic setAURL:aTopicURL];
		[aTopicURL release];

		//Answer Count
		HTMLNode * numRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase7" allowPartial:NO];
		[aTopic setARepCount:[[numRepNode contents] intValue]];
		
		//Author & Url of Last Post & Date
		HTMLNode * lastRepNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase9" allowPartial:YES];		
		HTMLNode * linkLastRepNode = [lastRepNode firstChild];
		NSString *aAuthorOfLastPost = [[NSString alloc] initWithString:[[linkLastRepNode findChildTag:@"b"] contents]];
		[aTopic setAAuthorOfLastPost:aAuthorOfLastPost];
		[aAuthorOfLastPost release];
		
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
		
		//URL of Last Page
		HTMLNode * topicLastPageNode = [[topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase4" allowPartial:NO] findChildTag:@"a"];
		if (topicLastPageNode) {
			NSString *aURLOfLastPage = [[NSString alloc] initWithString:[topicLastPageNode getAttributeNamed:@"href"]];
			[aTopic setAURLOfLastPage:aURLOfLastPage];
			[aURLOfLastPage release];
		}
		else {
			[aTopic setAURLOfLastPage:[aTopic aURL]];
		}
		
		
		[arrayData addObject:aTopic];

		[aTopic release];

		//NSString *myString = [[NSString alloc] init];
		NSString *myString = aTopic.aURL;
		//NSLog(@"NAME : %@", fasTest.name);
		
		myString = [self wordAfterString:@"cat=" inString:myString];
		//NSLog(@"CATID: %@", myString);
		
		
		//NEW CAT OR OLD CAT ?
		
		if([arrayDataID objectForKey:myString])
		{
			//NSLog(@"old");
			Catcounter *myCounter;// = [[Catcounter alloc] init];
			
			myCounter = [arrayDataID objectForKey:myString];
			//myCounter.length = [NSNumber numberWithInteger:[[myCounter length] integerValue] + 1];
			myCounter.length += 1;
			[arrayDataID setObject:myCounter forKey:myString];
			
			//NSLog (@"OLD Counter: %@ %@", myCounter.id, myCounter.length);
			
			//[myCounter release];
		}
		else {
			//NSLog(@"new");
			
			Catcounter *myCounter = [[Catcounter alloc] init];
						
			NSNumber* stringNumber = [NSNumber numberWithInteger:[myString integerValue]];
			myCounter.id = stringNumber;
			//[stringNumber release];
			
			myCounter.length = 1;
			
			myCounter.lengthB4 = globalCounter;
			
			
			[arrayDataID setObject:myCounter forKey:myString];
			[arrayDataID2 addObject:myString];
			
			[myCounter release];
		}
		
		
	}
	
	[dateFormat release];
	[nowTopic release];
	
	//arrayOf Section
	//NSArray *temporarySectionArray = [[NSArray alloc] init];
	
	NSArray *temporarySectionArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO]; //Get links for cat

	
	for (HTMLNode * sectionNode in temporarySectionArray) { //Loop through all the tags
//		[arraySection setObject:[NSString stringWithFormat:@"%@", [obj3 valueForKey:@"nodeContent"]] forKey:[self wordAfterString:@"cat=" inString:[obj4 valueForKey:@"nodeContent"]]];
		[arraySection setObject:[sectionNode contents] forKey:[self wordAfterString:@"cat=" inString:[sectionNode getAttributeNamed:@"href"]]];

	}	

	[myParser release];
	self.status = kComplete;
	//NSDate *now = [NSDate date]; // Create a current date
	//NSLog(@"FAVORITES Time elapsed: %f", [now timeIntervalSinceDate:then]);	
	
	
	//NSLog(@"arrayData %@", arrayData);
	//NSLog(@"arraySection %@", arraySection);
	//NSLog(@"arrayDataID %@", arrayDataID);
	//NSLog(@"arrayDataID2 %@", arrayDataID2);
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

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad ftv");
    [super viewDidLoad];
	
	self.title = @"Vos Sujets";

	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];		

	[(ShakeView*)self.view setShakeDelegate:self];

	self.arrayData = [[NSMutableArray alloc] init];
	self.arrayDataID = [[NSMutableDictionary alloc] init];
	self.arrayDataID2 = [[NSMutableArray alloc] init];
	self.arraySection = [[NSMutableDictionary alloc] init];
	
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
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.view resignFirstResponder];

	//[(UILabel *)[[favoritesTableView cellForRowAtIndexPath:favoritesTableView.indexPathForSelectedRow].contentView viewWithTag:999] setFont:[UIFont systemFontOfSize:13]];

	int theRow = [favoritesTableView.indexPathForSelectedRow row];
	
	theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:[favoritesTableView.indexPathForSelectedRow section]]] lengthB4];	
	
	[[arrayData objectAtIndex:theRow] setIsViewed:YES];

	[favoritesTableView reloadData];
	//[favoritesTableView deselectRowAtIndexPath:favoritesTableView.indexPathForSelectedRow animated:NO];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//NSLog(@"NB Section %d", arrayDataID.count);
	
    return arrayDataID.count;
}

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
	
	headerLabel.text = [arraySection objectForKey:[arrayDataID2 objectAtIndex:section]];
												   
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
	
	//if ([(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] selectedSegmentIndex] == 0) {
	//	[customView addSubview:detailLabel];
	//}
	
	return customView;
	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//NSLog(@"%d", section);
	//NSLog(@"%@", [arrayDataID2 objectAtIndex:section]);
	return [arraySection objectForKey:[arrayDataID2 objectAtIndex:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	//NSLog(@"Nb Dans la Section %d %d", section, [[[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:section]] length] intValue]);
	
	
	//return [arrayDataID objectForKey:[arrayDataID2 objectAtIndex:section]];
	
	//NSLog(@"Length %@", );
	
    return [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:section]] length];
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
	
	
    
	/*
	 static NSString *CellIdentifier = @"Cell";
	 
	 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	 if (cell == nil) {
	 cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	 }
	 */
	
	int theRow = indexPath.row;
	
	theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:indexPath.section]] lengthB4];
	
	//NSLog(@"row %d", indexPath.row);
	//NSLog(@"theRow %d", theRow);
	//NSLog(@"theRow %d", [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:indexPath.section]] lengthB4]);
	
    // Configure the cell...
	[(UILabel *)[cell.contentView viewWithTag:999] setText:[[arrayData objectAtIndex:theRow] aTitle]];
	[(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d messages", ([[arrayData objectAtIndex:theRow] aRepCount] + 1)]];
	[(UILabel *)[cell.contentView viewWithTag:997] setText:[NSString stringWithFormat:@"%@ - %@", [[arrayData objectAtIndex:theRow] aAuthorOfLastPost], [[arrayData objectAtIndex:theRow] aDateOfLastPost]]];

	if ([[arrayData objectAtIndex:theRow] isViewed]) {
		[(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont systemFontOfSize:13]];
	}
	else {
		[(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont boldSystemFontOfSize:13]];
		
	}	
	//[(UILabel *)[cell.contentView viewWithTag:999] setFont:[UIFont boldSystemFontOfSize:13]];	
	
	/*
	 if (cell.badgeNumber == 0) {
	 [(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d message", (cell.badgeNumber + 1)]];
	 }
	 else {
	 [(UILabel *)[cell.contentView viewWithTag:998] setText:[NSString stringWithFormat:@"%d messages", (cell.badgeNumber + 1)]];
	 }
	 [(UILabel *)[cell.contentView viewWithTag:997] setText:[NSString stringWithFormat:@"%@ - %@", [[arrayData objectAtIndex:indexPath.row] messageAuteur], [[arrayData objectAtIndex:indexPath.row] messageDate]]];
	 */
	
	
	//cell.textLabel.text = [[arrayData objectAtIndex:theRow] name];
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//cell.textLabel.numberOfLines = 2;
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int theRow = indexPath.row;
	
	theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:indexPath.section]] lengthB4];
	
	MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:theRow] aURL]];
	self.messagesTableViewController = aView;
	[aView release];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[label setFont:[UIFont boldSystemFontOfSize:13.0]];
	[label setAdjustsFontSizeToFitWidth:YES];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextAlignment:UITextAlignmentCenter];
	[label setLineBreakMode:UILineBreakModeMiddleTruncation];
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(0.0, -1.0);
	[label setTextColor:[UIColor whiteColor]];
	[label setNumberOfLines:0];
	
	[label setText:[[arrayData objectAtIndex:theRow] aTitle]];
	
	[messagesTableViewController.navigationItem setTitleView:label];
	[label release];	
	
	//setup the URL
	self.messagesTableViewController.topicName = [[arrayData objectAtIndex:theRow] aTitle];	
	
	//NSLog(@"push message liste");
	[self.navigationController pushViewController:messagesTableViewController animated:YES];
	
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.favoritesTableView];
		self.pressedIndexPath = [[self.favoritesTableView indexPathForRowAtPoint:longPressLocation] copy];
		
		//NSLog(@"pressedIndexPath %d -- %d", pressedIndexPath.row, pressedIndexPath.section);
		
		UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Aller à..."
																delegate:self cancelButtonTitle:@"Annuler"
												  destructiveButtonTitle:nil
													   otherButtonTitles:	@"la dernière page", @"la dernière réponse",
									 nil,
									 nil];
		
		// use the same style as the nav bar
		styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
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
			int theRow = pressedIndexPath.row;
			
			theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:pressedIndexPath.section]] lengthB4];

			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:theRow] aURLOfLastPage]];
			self.messagesTableViewController = aView;
			[aView release];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			
			[label setFont:[UIFont boldSystemFontOfSize:13.0]];
			[label setAdjustsFontSizeToFitWidth:YES];
			[label setBackgroundColor:[UIColor clearColor]];
			[label setTextAlignment:UITextAlignmentCenter];
			[label setLineBreakMode:UILineBreakModeMiddleTruncation];
			label.shadowColor = [UIColor darkGrayColor];
			label.shadowOffset = CGSizeMake(0.0, -1.0);
			[label setTextColor:[UIColor whiteColor]];
			[label setNumberOfLines:0];
			
			
			[label setText:[[arrayData objectAtIndex:theRow] aTitle]];
			
			[messagesTableViewController.navigationItem setTitleView:label];
			[label release];	
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:theRow] aTitle];	
			
			[self.navigationController pushViewController:messagesTableViewController animated:YES];	

			//NSLog(@"url pressed last page: %@", [[arrayData objectAtIndex:theRow] lastPageUrl]);
			break;
		}
		case 1:
		{
			int theRow = pressedIndexPath.row;
			
			theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:pressedIndexPath.section]] lengthB4];

			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:theRow] aURLOfLastPost]];
			self.messagesTableViewController = aView;
			[aView release];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			
			[label setFont:[UIFont boldSystemFontOfSize:13.0]];
			[label setAdjustsFontSizeToFitWidth:YES];
			[label setBackgroundColor:[UIColor clearColor]];
			[label setTextAlignment:UITextAlignmentCenter];
			[label setLineBreakMode:UILineBreakModeMiddleTruncation];
			label.shadowColor = [UIColor darkGrayColor];
			label.shadowOffset = CGSizeMake(0.0, -1.0);
			[label setTextColor:[UIColor whiteColor]];
			[label setNumberOfLines:0];
			
			[label setText:[[arrayData objectAtIndex:theRow] aTitle]];
			
			[messagesTableViewController.navigationItem setTitleView:label];
			[label release];	
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:theRow] aTitle];	
			
			[self.navigationController pushViewController:messagesTableViewController animated:YES];	

			//NSLog(@"url pressed last post: %@", [[arrayData objectAtIndex:pressedIndexPath.row] lastPostUrl]);
			break;
			
		}
			
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

		
		int theRow = indexPath.row;
		
		theRow += [[arrayDataID objectForKey:[arrayDataID2 objectAtIndex:indexPath.section]] lengthB4];
		
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [[arrayData objectAtIndex:theRow] postID]] forKey:@"topic0"];
		[arequest setPostValue:[NSString stringWithFormat:@"%d", [[arrayData objectAtIndex:theRow] catID]] forKey:@"valuecat0"];
		
		[arequest setPostValue:@"hardwarefr" forKey:@"valueforum0"];

		
		//NSLog(@"%d - %d", [[arrayData objectAtIndex:theRow] postID], [[arrayData objectAtIndex:theRow] catID]);
		
		[arequest startSynchronous];

		//NSLog(@"arequest: %@", [arequest url]);

		if (arequest) {
			if ([arequest error]) {
				//NSLog(@"error: %@", [[arequest error] localizedDescription]);
			}
			else if ([arequest responseString])
			{
				//NSLog(@"responseString: %@", [arequest responseString]);
				
				[self reload];

			}
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
		[[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-18984614-1"
											   dispatchPeriod:kGANDispatchPeriodSec
													 delegate:nil];
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"sujets"
											 action:@"reload"
											  label:@"manual"
											  value:-1
										  withError:&error]) {
			// Handle error here
		}
		
	}


	[self fetchContent];
}


-(void) shakeHappened:(ShakeView*)view
{
	if (![request inProgress]) {
		
		[[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-18984614-1"
											   dispatchPeriod:kGANDispatchPeriodSec
													 delegate:nil];
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"sujets"
											 action:@"reload"
											  label:@"shake"
											  value:-1
										  withError:&error]) {
			// Handle error here
		}
		
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

	[[GANTracker sharedTracker] stopTracker];

	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	self.statusMessage = nil;
	
	[self.arrayDataID release];
	self.arrayData = nil;

	[self.arrayDataID2 release];
	[self.arraySection release];
	
    [super dealloc];
}


@end

