//
//  ForumsTableViewController.m
//  HFR+
//
//  Created by Lace on 06/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HFRplusAppDelegate.h"

#import "ForumsTableViewController.h"
#import "TopicsTableViewController.h"

#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "ShakeView.h"

#import "Forum.h"

@implementation ForumsTableViewController
@synthesize request;
@synthesize forumsTableView, loadingView, arrayData, topicsTableViewController;
@synthesize status, statusMessage, maintenanceView;
#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	
	self.status = kIdle;	
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
	
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:kForumURL]]];
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
	[self.forumsTableView setHidden:YES];
	[self.loadingView setHidden:NO];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[self.arrayData removeAllObjects];
	[self.forumsTableView reloadData];
	
	[self loadDataInTableView:[request responseData]];

	[self.loadingView setHidden:YES];

	switch (self.status) {
		case kMaintenance:
		case kNoResults:
			[self.maintenanceView setText:self.statusMessage];
			[self.maintenanceView setHidden:NO];
			[self.forumsTableView setHidden:YES];
			break;
		default:
			[self.forumsTableView reloadData];			
			[self.forumsTableView setHidden:NO];			
			break;
	}
	
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[self.loadingView setHidden:YES];

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

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData
{
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
	//NSLog(@"bodyNode %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));	
	
	HTMLNode *hash_check = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
	NSLog(@"hash_check %@", rawContentsOfNode([hash_check _node], [myParser _doc]));
	
	NSArray *temporaryForumsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cat" allowPartial:YES];

	//NSLog(@"temporaryForumsArray %d", [temporaryForumsArray count]);	

	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
		self.status = kMaintenance;
		self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[myParser release];
		return;
	}
	
	
	for (HTMLNode * forumNode in temporaryForumsArray) {

		if (![[forumNode tagName] isEqualToString:@"tr"]) {
			continue;
		}

		
		NSArray *temporaryForumArray = [forumNode findChildTags:@"td"];


		Forum *aForum = [[Forum alloc] init];
		
		
		//Title
		HTMLNode * topicNode = [temporaryForumArray objectAtIndex:1];		
		NSString *aForumTitle = [[NSString alloc] initWithString:[[[topicNode findChildTag:@"b"] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		[aForum setATitle:aForumTitle];
		[aForumTitle release];

		//URL
		NSString *aForumURL = [[NSString alloc] initWithString:[[topicNode findChildWithAttribute:@"class" matchingName:@"cCatTopic" allowPartial:YES] getAttributeNamed:@"href"]];
		
		if ([aForumURL isEqualToString:@"/hfr/AchatsVentes/Hardware/liste_sujet-1.htm"]) {
			[aForum setAURL:@"/hfr/AchatsVentes/liste_sujet-1.htm"];
		}
		else {
			[aForum setAURL:aForumURL];
		}
	
		// Sous categories
		NSArray *temporaryCatsArray = [topicNode findChildrenWithAttribute:@"class" matchingName:@"Tableau" allowPartial:NO];
		if ([temporaryCatsArray count] > 0) {
			NSMutableArray *tmpSubCatArray = [[NSMutableArray alloc] init];
			
			Forum *aSubForum = [[Forum alloc] init];
			
			//Title
			[aSubForum setATitle:[aForum aTitle]];
			
			//URL
			[aSubForum setAURL:[aForum aURL]];
			
			[tmpSubCatArray addObject:aSubForum];
			
			[aSubForum release];	

			
			for (HTMLNode * subForumNode in temporaryCatsArray) {
				Forum *aSubForum = [[Forum alloc] init];

				//Title
				NSString *aSubForumTitle = [[NSString alloc] initWithString:[[subForumNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				[aSubForum setATitle:aSubForumTitle];
				[aSubForumTitle release];

				//URL
				NSString *aSubForumURL = [[NSString alloc] initWithString:[subForumNode getAttributeNamed:@"href"]];
				[aSubForum setAURL:aSubForumURL];
				[aSubForumURL release];
				
				[tmpSubCatArray addObject:aSubForum];
				
				[aSubForum release];		

			}
			
			[aForum setSubCats:tmpSubCatArray];

			[tmpSubCatArray release];
		}
		//--- Sous categories

		
		
		
		//NSLog(@"aForumURL %@", aForumURL);

		if ([aForumURL rangeOfString:@"cat=prive"].location == NSNotFound) {
			[arrayData addObject:aForum];
		}
		else {
			//NSLog(@"else %@", [[topicNode findChildWithAttribute:@"class" matchingName:@"cCatTopic" allowPartial:YES] contents]);
			NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";			
			NSString *myMPNumber = [[[topicNode findChildWithAttribute:@"class" matchingName:@"cCatTopic" allowPartial:YES] contents] stringByReplacingOccurrencesOfRegex:regExMP
																  withString:@"$1"];
			
			[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
		}
		[aForumURL release];

		[aForum release];		

	}
	
	[myParser release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Forums";

	//Bouton Reload
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	

	[(ShakeView*)self.view setShakeDelegate:self];

	self.arrayData = [[NSMutableArray alloc] init];
	self.statusMessage = [[NSString alloc] init];

	[self fetchContent];
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"viewWillAppear Forums Table View");

	
    [super viewWillAppear:animated];
	[self.view becomeFirstResponder];

	if (self.topicsTableViewController) {
		//NSLog(@"viewWillAppear Forums Table View RELEASE");

		self.topicsTableViewController = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[self.view resignFirstResponder];

	[forumsTableView deselectRowAtIndexPath:forumsTableView.indexPathForSelectedRow animated:NO];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//NSLog(@"Count Forums Table View: %d", arrayData.count);
	
    return arrayData.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[arrayData objectAtIndex:indexPath.row] aTitle], [[[arrayData objectAtIndex:indexPath.row] subCats] count]];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSLog(@"did Select row forum table views");

	if (self.topicsTableViewController == nil) {
		TopicsTableViewController *aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
		self.topicsTableViewController = aView;
		[aView release];
	}
/*	
	self.navigationItem.backBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"Forums"
									 style: UIBarButtonItemStyleBordered
									target:nil
									action:nil];
	
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 44)];
	[label setFont:[UIFont boldSystemFontOfSize:16.0]]; //16
	[label setAdjustsFontSizeToFitWidth:YES];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextAlignment:UITextAlignmentCenter];
	
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(0.0, -1.0);
	
	[label setTextColor:[UIColor whiteColor]];
	[label setNumberOfLines:2];
	[label setText:[[arrayData objectAtIndex:indexPath.row] aTitle]];
	
	[topicsTableViewController.navigationItem setTitleView:label];
	[label release];	
*/
	//setup the URL
	self.topicsTableViewController.currentUrl = [[arrayData objectAtIndex:indexPath.row] aURL];	
	self.topicsTableViewController.forumName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.topicsTableViewController.pickerViewArray = [[arrayData objectAtIndex:indexPath.row] subCats];	

	[self.navigationController pushViewController:topicsTableViewController animated:YES];

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
		if (![[GANTracker sharedTracker] trackEvent:@"forums"
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
		if (![[GANTracker sharedTracker] trackEvent:@"forums"
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
	//NSLog(@"viewDidUnload forums");
	
	self.forumsTableView = nil;
	self.loadingView = nil;	
	self.maintenanceView = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	//NSLog(@"dealloc Forums Table View");
	[self viewDidUnload];
	
	[[GANTracker sharedTracker] stopTracker];

	self.arrayData = nil;

	[request cancel];
	[request setDelegate:nil];
	self.request = nil;

	self.statusMessage = nil;
	
	if (self.topicsTableViewController) {
		self.topicsTableViewController = nil;
	}
	
    [super dealloc];

}

@end

