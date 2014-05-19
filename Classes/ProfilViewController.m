//
//  ProfilViewController.m
//  HFRplus
//
//  Created by Shasta on 19/05/2014.
//
//

#import "HFRplusAppDelegate.h"
#import "ProfilViewController.h"

#import "ASIHTTPRequest.h"

#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "RangeOfCharacters.h"

@interface ProfilViewController ()

@end

@implementation ProfilViewController
@synthesize profilTableView, loadingView, maintenanceView, status, statusMessage;
@synthesize currentUrl, request;
@synthesize arrayData;

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
    NSLog(@"cancelFetchContent");
    
    [self.request cancel];
}

- (void)fetchContent
{
	self.status = kIdle;
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, self.currentUrl]]]];
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
    
    [self.arrayData removeAllObjects];
	[self.profilTableView reloadData];
    
	[self.maintenanceView setHidden:YES];
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
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:YES];
    
    [self loadDataInTableView:[theRequest responseData]];
    
	[self.profilTableView reloadData];
    [self.profilTableView setHidden:NO];
    
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
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:NO];
    [self.profilTableView setHidden:YES];
    
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
#pragma mark Parsing

-(void)loadDataInTableView:(NSData *)contentData
{
    NSLog(@"loadDataInTableView");
    
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
    
	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
		self.status = kMaintenance;
		self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[myParser release];
        
        
        [self.maintenanceView setText:self.statusMessage];
        [self.maintenanceView setHidden:NO];
        
		return;
	}
    
    HTMLNode *tableNode = [bodyNode findChildTag:@"table"];
    
    NSArray *temporaryProfilArray = [tableNode findChildTags:@"tr"];
    
    int curSection = -1;
    NSMutableArray *parsedDataArray = [NSMutableArray array];
    
	for (HTMLNode * profilNode in temporaryProfilArray) {
        
		if (![[profilNode tagName] isEqualToString:@"tr"]) {
			continue;
		}
		
		if ([[profilNode className] isEqualToString:@"cBackHeader"]) {
            // Titre
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    [[profilNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"section",
                                                                                [NSMutableArray array], @"rows", nil];

            [parsedDataArray addObject:dict];
            
            curSection++;
		}

        
		if ([[profilNode className] isEqualToString:@"profil"]) {
            // info
            switch (curSection) {
                case 2:
                {
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [[rowData stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    NSString *rowType = @"feedback";
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    @"", @"title",
                                          rowData, @"data",
                                          rowType, @"type", nil];
                    
                    NSLog(@"dict %@", dict);
                    
                    [[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    
                    break;
                }
                case 3:
                {
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [[rowData stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    NSString *rowType = @"link";
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    @"", @"title",
                                          rowData, @"data",
                                          rowType, @"type", nil];
                    
                    NSLog(@"dict %@", dict);
                    
                    [[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    
                    break;
                }
                default:
                {
                    NSString *rowTitle = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase2" allowPartial:NO] allContents];
                    rowTitle = [[rowTitle stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [rowData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *rowType = @"string";
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    rowTitle, @"title",
                                          rowData, @"data",
                                          rowType, @"type", nil];
                    
                    [[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    
                    break;
                }
            }
            
            

            //NSLog(@"profil %@", [profilNode allContents]);
		}
        
	}
	
    self.arrayData = [NSMutableArray array];
    [self.arrayData addObjectsFromArray:parsedDataArray];
    //NSLog(@"arrayData %@", self.arrayData);
    //NSLog(@"parsedDataArray %@", parsedDataArray);
	[myParser release];
}

#pragma mark -
#pragma mark View management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.currentUrl = [theURL copy];

	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Profil";
    
    // close
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = doneButton;
    
	// reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.profilTableView setTableFooterView:v];
    [v release];
    
    [self fetchContent];
}


- (void)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Reload

-(void)reload
{
    [self fetchContent];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //NSLog(@"nbSec %d", self.arrayData.count);
    return self.arrayData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //NSLog(@"Title %d = %@", section, [[self.arrayData objectAtIndex:section] objectForKey:@"section"]);
    return [[self.arrayData objectAtIndex:section] objectForKey:@"section"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//NSLog(@"Count Forums Table View: %d", arrayData.count);
    //NSLog(@"nbRow In Sec %d = %d", section, [[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count]);

    return [[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];

    if ([[theRow objectForKey:@"data"] isEqualToString:@""]) {
        return 0;
    }
    
    if ([[theRow objectForKey:@"data"] isEqualToString:@"NA"]) {
        return 0;
    }
    
    return 50.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];

    NSString *type = [theRow objectForKey:@"type"];

    if ([type isEqualToString:@"feedback"]) {

        static NSString *CellIdentifier = @"CellFB";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if ([type isEqualToString:@"link"]) {
        
        static NSString *CellIdentifier = @"CellLINK";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.numberOfLines = 0;
        
        cell.detailTextLabel.text = [theRow objectForKey:@"title"];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;

    }
}

#pragma mark -
#pragma mark Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    if ([[theRow objectForKey:@"type"] isEqualToString:@"string"]) {
        return YES;
    }
    else
        return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {

    if (action == @selector(copy:))
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.textLabel.text];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

 /*

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
   
    self.topicsTableViewController = nil;
    
	if (self.topicsTableViewController == nil) {
		TopicsTableViewController *aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
		self.topicsTableViewController = aView;
		[aView release];
	}
    
	//setup the URL
	
    
    
	self.navigationItem.backBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"Retour"
									 style: UIBarButtonItemStyleBordered
									target:nil
									action:nil];
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.navigationItem.backBarButtonItem.title = @" ";
    }
    
    
	self.topicsTableViewController.forumBaseURL = [[arrayData objectAtIndex:indexPath.row] aURL];
	self.topicsTableViewController.forumName = [[arrayData objectAtIndex:indexPath.row] aTitle];
	self.topicsTableViewController.pickerViewArray = [[arrayData objectAtIndex:indexPath.row] subCats];
    
	[self.navigationController pushViewController:topicsTableViewController animated:YES];
  
}
*/
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.loadingView = nil;
	self.profilTableView = nil;
	self.maintenanceView = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
    
	[self viewDidUnload];
    
	[request cancel];
	[request setDelegate:nil];
	self.request = nil;
    self.currentUrl = nil;
    
	self.statusMessage = nil;
    
    [super dealloc];
}



@end
