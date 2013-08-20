//
//  HFRSearchViewController.m
//  HFRplus
//
//  Created by FLK on 04/11/10.
//

#import "HFRplusAppDelegate.h"

#import "HFRSearchViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "TopicSearchCellView.h"
#import "MessagesTableViewController.h"
#import "RangeOfCharacters.h"


@implementation HFRSearchViewController
@synthesize stories;
@synthesize request;

@synthesize disableViewOverlay, loadingView;
@synthesize status, statusMessage, maintenanceView, messagesTableViewController, tmpCell, pressedIndexPath, topicActionSheet;

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
	[self.stories removeAllObjects];
	
	[self.maintenanceView setHidden:YES];
	[self.theTableView setHidden:YES];
	[self.loadingView setHidden:NO];
		
    //you must then convert the path to a proper NSURL or it won't work
	
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.theSearchBar.text, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);

	
    NSURL *xmlURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/cse?cx=005221696873136977783:gnqtncc8bu8&client=google-csbe&output=xml_no_dtd&num=20&q=%@", result]];

	NSLog(@"xmlURL %@", xmlURL);

	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	NSLog(@"OK");
    [rssParser parse];
	

	
}

-(void)OrientationChanged
{
    if (self.topicActionSheet) {
        [self.topicActionSheet dismissWithClickedButtonIndex:[self.topicActionSheet cancelButtonIndex] animated:YES];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.theSearchBar = [[UISearchBar alloc] init];
    theSearchBar.delegate = self;
    theSearchBar.placeholder = @"Recherche";
    
	self.navigationItem.titleView = theSearchBar;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 0, 44);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrientationChanged)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
	self.title = @"Recherche";
    self.stories =[[NSMutableArray alloc]init];
    self.disableViewOverlay = [[UIView alloc]
							   initWithFrame:CGRectMake(0.0f,0.0f,320.0f,1000.0f)];
    self.disableViewOverlay.backgroundColor=[UIColor blackColor];
    self.disableViewOverlay.alpha = 0;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] 
														 initWithTarget:self action:@selector(handleTap:)];
	[self.disableViewOverlay addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];	
	
	[self.maintenanceView setText:@"Aucun résultat"];
}


- (void) viewWillAppear:(BOOL)animated
{
	//[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
		
	if (self.messagesTableViewController) {
		//NSLog(@"viewWillAppear Topics Table View Dealloc MTV");
		
		self.messagesTableViewController = nil;
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//[self.theSearchBar becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
	if (self.theTableView.indexPathForSelectedRow) {
		NSLog(@"SEARCH indexPathForSelectedRow");
		//[[self.arrayData objectAtIndex:[self.topicsTableView.indexPathForSelectedRow row]] setIsViewed:YES];
		[self.theTableView reloadData];
	}
	
	/*[[(TopicCellView *)[topicsTableView cellForRowAtIndexPath:topicsTableView.indexPathForSelectedRow] titleLabel]setFont:[UIFont systemFontOfSize:13]];
	 [topicsTableView deselectRowAtIndexPath:topicsTableView.indexPathForSelectedRow animated:NO];*/
	
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



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	NSLog(@"ERROR XML: %@", parseError);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"R"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"R"]) {
		// save values to an item, then store that item into the array...
		
		NSString *pattern = @"<(.|\n)*?>";

		currentTitle = (NSMutableString *)[currentTitle stringByDecodingXMLEntities];
		[item setObject:[[currentTitle stringByReplacingOccurrencesOfString:@"amp;" withString:@""] stringByReplacingOccurrencesOfRegex:pattern withString:@""] forKey:@"title"];
		//[item setObject:currentTitle forKey:@"title"];
		
		[item setObject:[currentLink stringByReplacingOccurrencesOfString:kForumURL withString:@""] forKey:@"link"];

		currentSummary = (NSMutableString *)[currentSummary stringByDecodingXMLEntities];
		[item setObject:[[currentSummary stringByReplacingOccurrencesOfString:@"amp;" withString:@""] stringByReplacingOccurrencesOfRegex:pattern withString:@""] forKey:@"summary"];
		//[item setObject:currentSummary forKey:@"summary"];
		
		[item setObject:currentDate forKey:@"date"];
		

		
		//On check si y'a page=2323
		NSString *currentUrl = [[item valueForKey:@"link"] copy];
		int pageNumber;
		
        NSLog(@"currentUrl %@", currentUrl);
        
		NSString *regexString  = @".*page=([^&]+).*";
		NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
		NSRange   searchRange = NSMakeRange(0, currentUrl.length);
		NSError  *error2        = NULL;
		
		matchedRange = [currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
		
		if (matchedRange.location == NSNotFound) {
			NSRange rangeNumPage =  [currentUrl rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
            
            if (rangeNumPage.location == NSNotFound) {
                return;
            }
            
			pageNumber = [[currentUrl substringWithRange:rangeNumPage] intValue];
		}
		else {
			pageNumber = [[currentUrl substringWithRange:matchedRange] intValue];
			
		}
		//On check si y'a page=2323
		
		
		[item setObject:[NSString stringWithFormat:@"p. %d", pageNumber] forKey:@"page"];
		/**/
		[stories addObject:[item copy]];
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"T"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"UE"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"S"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	NSLog(@"all done!");
	//NSLog(@"stories array has %d items", [stories count]);
	
	//NSLog(@"stories %@", stories);
	NSMutableArray *tmArr = [[NSMutableArray alloc] init];
	
	for (NSDictionary *story in stories) {
		if ([[story valueForKey:@"link"] rangeOfString:@"/liste_sujet"].location != NSNotFound) {
			[tmArr addObject:story];
			
		}
	}
	
	for (NSDictionary *story in tmArr) {
	
		[stories removeObject:story];
	}
	
	//NSLog(@"stories array has %d items", [stories count]);

	if ([stories count] == 0) {
		[self.maintenanceView setText:@"Aucun résultat"];
		[self.maintenanceView setHidden:NO];
		[self.theTableView setHidden:YES];
		[self.loadingView setHidden:YES];
	}
	else {
		[self.maintenanceView setHidden:YES];
		[self.theTableView setHidden:NO];
		[self.loadingView setHidden:YES];
	}

	
	
	[theTableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [stories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"TopicSearchCellView";
    
    TopicSearchCellView *cell = (TopicSearchCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
		
        [[NSBundle mainBundle] loadNibNamed:@"TopicSearchCellView" owner:self options:nil];
        cell = tmpCell;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;	

		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
															 initWithTarget:self action:@selector(handleLongPress:)];
		[cell addGestureRecognizer:longPressRecognizer];
		[longPressRecognizer release];
        
        self.tmpCell = nil;
		
	}
	
	/*
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	*/
	
	
	
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	[cell.titleLabel setText:[[stories objectAtIndex: storyIndex] objectForKey: @"title"]];
	[cell.msgLabel setText:[[stories objectAtIndex: storyIndex] objectForKey: @"summary"]];
	[cell.timeLabel setText:[[stories objectAtIndex: storyIndex] objectForKey: @"page"]];

	// Set up the cell

//	[cell setText:[(NSString *)[[stories objectAtIndex: storyIndex] objectForKey: @"title"] stringByReplacingOccurrencesOfRegex:pattern
//																									withString:@""]];
	
	
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	//NSLog(@"did Select row Topics table views: %d", indexPath.row);
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];		
	
	//if (self.messagesTableViewController == nil) {
	MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[stories objectAtIndex: storyIndex] objectForKey: @"link"]];
	self.messagesTableViewController = aView;
	[aView release];
	//}
	
	
	
	
	//NSLog(@"%@", self.navigationController.navigationBar);
	
	
	
	
	//setup the URL
	self.messagesTableViewController.topicName = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];	
	self.messagesTableViewController.isViewed = NO;	
	
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
#pragma mark LongPress delegate

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.theTableView];
		self.pressedIndexPath = [[self.theTableView indexPathForRowAtPoint:longPressLocation] copy];
        
        if (self.topicActionSheet != nil) {
            [self.topicActionSheet release], self.topicActionSheet = nil;
        }
        
		self.topicActionSheet = [[UIActionSheet alloc] initWithTitle:@":smiley-menu:"
                                                            delegate:self cancelButtonTitle:@"Annuler"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:	@"Copier le lien",
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
			NSLog(@"copier lien page 1 %@", [[stories objectAtIndex: pressedIndexPath.row] objectForKey: @"link"]);
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"%@%@", kForumURL, [[stories objectAtIndex: pressedIndexPath.row] objectForKey: @"link"]];
            
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[theTableView release], theTableView = nil;
    [theSearchBar release], theSearchBar = nil;
    [stories dealloc];	
	[disableViewOverlay dealloc];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    self.pressedIndexPath = nil;
    self.topicActionSheet = nil;
    
    [super dealloc];
}


@end
