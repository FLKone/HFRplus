//
//  HFRSearchViewController.m
//  HFRplus
//
//  Created by Shasta on 04/11/10.
//  Copyright 2010 FLK. All rights reserved.
//

#import "HFRplusAppDelegate.h"

#import "HFRSearchViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"

@implementation HFRSearchViewController
@synthesize tableData;
@synthesize request;

@synthesize disableViewOverlay, loadingView;
@synthesize status, statusMessage, maintenanceView;

@synthesize theSearchBar;
@synthesize theTableView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/



#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"searchBar.text %@", self.theSearchBar.text);
	
	self.status = kIdle;
	[ASIFormDataRequest setDefaultTimeOutSeconds:kTimeoutMini];
	
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", kForumURL]]]];
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(onefetchContentStarted:)];
	[request setDidFinishSelector:@selector(onefetchContentComplete:)];
	[request setDidFailSelector:@selector(onefetchContentFailed:)];
	
	[request startAsynchronous];
	
	/*
	[self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", kForumURL]]]];
	[request setDelegate:self];

	[request setPostValue:@"1" forKey:@"recherches"];
	[request setPostValue:@"1" forKey:@"searchtype"];
	[request setPostValue:@"3" forKey:@"titre"];
	[request setPostValue:@"200" forKey:@"resSearch"];
	[request setPostValue:@"1" forKey:@"orderSearch"];
	[request setPostValue:@"hardwarefr.inc" forKey:@"config"];
	[request setPostValue:@"" forKey:@"hash_check"];
	[request setPostValue:@"2" forKey:@"x"];
	[request setPostValue:@"14" forKey:@"y"];

	[request setPostValue:@"test" forKey:@"search"];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	NSLog(@"%@", request.url);
	
	[request startAsynchronous];*/
}

- (void)onefetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"onefetchContentStarted");
	
	[self.maintenanceView setHidden:YES];
	[self.theTableView setHidden:YES];
	[self.loadingView setHidden:NO];
}
- (void)onefetchContentFailed:(ASIHTTPRequest *)theRequest
{
	[self.loadingView setHidden:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:111];
	[alert show];
	[alert release];
}
- (void)onefetchContentComplete:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"onefetchContentComplete");
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:[theRequest responseData] error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
	//NSLog(@"bodyNode %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));	
	
	HTMLNode *hash_check = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
	
	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
		self.status = kMaintenance;
		self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[myParser release];
		
		[self.maintenanceView setText:self.statusMessage];
		[self.maintenanceView setHidden:NO];
		[self.theTableView setHidden:YES];		
		return;
	}
	
	[self.loadingView setHidden:YES];
	

	[self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1.php", kForumURL]]]];
	[request setDelegate:self];
	
	[request setPostValue:@"1" forKey:@"recherches"];
	[request setPostValue:@"1" forKey:@"searchtype"];
	[request setPostValue:@"3" forKey:@"titre"];
	[request setPostValue:@"200" forKey:@"resSearch"];
	[request setPostValue:@"1" forKey:@"orderSearch"];
	[request setPostValue:@"hardwarefr.inc" forKey:@"config"];
	[request setPostValue:[hash_check getAttributeNamed:@"value"] forKey:@"hash_check"];
	[request setPostValue:@"2" forKey:@"x"];
	[request setPostValue:@"14" forKey:@"y"];
	
	[request setPostValue:self.theSearchBar.text forKey:@"search"];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	
	[request startAsynchronous];

	
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentStarted");
	
	[self.maintenanceView setHidden:YES];
	[self.theTableView setHidden:YES];
	[self.loadingView setHidden:NO];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	if (theRequest.responseStatusCode == 302) {
		NSString *url = [[NSString alloc] initWithFormat:@"%@%@", kForumURL, [[theRequest responseHeaders] objectForKey:@"Location"]];
		//NSLog(@"url %@", url);

		//NSString *url = [NSString stringWithFormat:@"%@%@", kForumURL, [[theRequest responseHeaders] objectForKey:@"Location"]];
		self.status = kIdle;
		
		//NSLog(@"URLWithString %@", [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]);
		
		//|1*hfr|16*hfr|15*hfr|23*hfr|2*hfr|25*hfr|3*hfr|14*hfr|5*hfr|4*hfr|22*hfr|21*hfr|11*hfr|10*hfr|26*hfr|12*hfr|6*hfr|8*hfr|9*hfr|13*hfr|24*hfr|

		[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]];
		[request setDelegate:self];
		[request setDidStartSelector:@selector(fetchContentStarted:)];
		[request setDidFinishSelector:@selector(fetchContentComplete:)];
		[request setDidFailSelector:@selector(fetchContentFailed:)];
		//NSLog(@"%@", url);
		
		[request startAsynchronous];

	}
	else {
		[self.loadingView setHidden:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
													   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
		[alert show];
		[alert release];
	}
	
	
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	[self.tableData removeAllObjects];
	[self.theTableView reloadData];
	
	NSLog(@"fetchContentComplete %@", [theRequest responseString]);
	
	
	
	//[self loadDataInTableView:[request responseData]];
	
	[self.loadingView setHidden:YES];
	
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
			[self.maintenanceView setText:self.statusMessage];
			[self.maintenanceView setHidden:NO];
			[self.theTableView setHidden:YES];
			break;
		default:
			[self.theTableView reloadData];			
			[self.theTableView setHidden:NO];			
			break;
	}
	
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self fetchContent];
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Recherche";
    self.tableData =[[NSMutableArray alloc]init];
    self.disableViewOverlay = [[UIView alloc]
							   initWithFrame:CGRectMake(0.0f,44.0f,320.0f,416.0f)];
    self.disableViewOverlay.backgroundColor=[UIColor blackColor];
    self.disableViewOverlay.alpha = 0;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] 
														 initWithTarget:self action:@selector(handleTap:)];
	[self.disableViewOverlay addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];	
	
	[self.maintenanceView setText:@"Aucun résultat"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//[self.theSearchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	// We don't want to do anything until the user clicks 
	// the 'Search' button.
	// If you wanted to display results as the user types 
	// you would do that here.
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
}

-(void)handleTap:(id)sender{
    [self searchBar:self.theSearchBar activate:NO];	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
	
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search


    [self searchBar:searchBar activate:NO];
	
	[self fetchContent];
}

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{	
	
    self.theTableView.allowsSelection = !active;
    self.theTableView.scrollEnabled = !active;
    if (!active) {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        // probably not needed if you have a details view since you 
        // will go there on selection
        NSIndexPath *selected = [self.theTableView 
								 indexPathForSelectedRow];
        if (selected) {
            [self.theTableView deselectRowAtIndexPath:selected 
											 animated:NO];
        }
    }
    [searchBar setShowsCancelButton:active animated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"SearchResult";
    UITableViewCell *cell = [tableView
							 dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:MyIdentifier] autorelease];
    }
	
    //id *data = [self.tableData objectAtIndex:indexPath.row];
    //cell.textLabel.text = data.name;
    return cell;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[theTableView release], theTableView = nil;
    [theSearchBar release], theSearchBar = nil;
    [tableData dealloc];	
	[disableViewOverlay dealloc];

    [super dealloc];
}


@end
