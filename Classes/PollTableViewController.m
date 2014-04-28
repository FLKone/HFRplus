//
//  PollTableViewController.m
//  HFRplus
//
//  Created by Shasta on 12/02/2014.
//
//

#import "HFRplusAppDelegate.h"

#import "PollTableViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "RangeOfCharacters.h"
#import "ASIFormDataRequest.h"

#import "PollResultTableViewCell.h"

#import "ASIHTTPRequest.h"
#import "MessagesTableViewController.h"

@interface PollTableViewController ()

@end

@implementation PollTableViewController

@synthesize arrayInputData, arraySubmitBtn, arrayOptions, arrayResults, stringQuestion, stringFooter, intNombreChoix, arraySelectedRows, delegate, tableViewPoll, loadingView, maintenanceView, statusMessage, request, status;

- (id)initWithPollNode:(NSString *)aPollNodeString;
{
    self = [super init];
    if (self) {

        
        // Custom initialization
        [self setupFromPollString:aPollNodeString];
        
    }
    return self;
}

- (void)setupFromPollString:(NSString *)aPollNodeString {
    //SONDAGE PARSE
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:aPollNodeString error:NULL];
    HTMLNode * aPollNode = [myParser body]; //Find the body tag
    aPollNode = [aPollNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO];
    
    //NSLog(@"aPollNode %@", rawContentsOfNode([aPollNode _node], [myParser _doc]));
    
    //INIT
    self.arraySelectedRows = [NSMutableArray array];
    self.arrayOptions = [NSMutableArray array];
    self.arrayInputData = [NSMutableDictionary dictionary];
    self.arraySubmitBtn = [NSMutableDictionary dictionary];
    //NSLog(@"pollNode %@", aPollNode);
    
    
    //LA Question
    HTMLNode *titleNode = [aPollNode findChildWithAttribute:@"class" matchingName:@"s2" allowPartial:NO];
    self.stringQuestion = [titleNode allContents];
    
    //Header infos
    NSString *regularExpressionString = @".*</b>(.*)<ol type=\"1\">.*";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:aPollNodeString];
    
    if (myStringMatchesRegEx) {
        NSString* stringHeader = [aPollNodeString stringByMatching:regularExpressionString capture:1L];
        NSString* regularExpressionString2 = @".* ([0-9]{1,2}) .*";
        NSString* stringNombreChoix = [stringHeader stringByMatching:regularExpressionString2 capture:1L];
        
        self.intNombreChoix = [stringNombreChoix integerValue];
    }
    else {
        self.intNombreChoix = 1;
    }
    
    //Footer infos
    self.stringFooter = rawContentsOfNode([[[aPollNode children] objectAtIndex:[aPollNode children].count-2] _node], [myParser _doc]);
    self.stringFooter = [[[self.stringFooter stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r"] stripHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSArray *temporaryAllInputArray = [aPollNode findChildTags:@"input"];
    
    //NSLog(@"inputNode ========== %d", temporaryAllInputArray.count);

    
    
    
    if (temporaryAllInputArray.count) {
        
        //Req Fields
        for (HTMLNode * inputallNode in temporaryAllInputArray) { //Loop through all the tags
            
            //NSLog(@"name %@ value %@ type %@", [inputallNode getAttributeNamed:@"name"], [inputallNode getAttributeNamed:@"value"], [inputallNode getAttributeNamed:@"type"]);
            
            //Hidden input
            if ([[inputallNode getAttributeNamed:@"type"] isEqualToString:@"hidden"]) {
                [self.arrayInputData setObject:[inputallNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
            }
            
            //actions
            if ([[inputallNode getAttributeNamed:@"type"] isEqualToString:@"submit"]) {
                [self.arraySubmitBtn setObject:[inputallNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
            }
        }
        
        //Choix du sondage
        NSArray *temporaryAllRadioArray = [aPollNode findChildTags:@"li"];
        for (HTMLNode * inputallRadio in temporaryAllRadioArray) { //Loop through all the tags
            
            //NSLog(@"inputallRadio %@", rawContentsOfNode([inputallRadio _node], [myParser _doc]));
            
            
            //NSLog(@"name %@ value %@ type %@",  [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"name"],
            //                                    [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"value"],
            //                                    [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"type"]);
            //NSLog(@"text %@", [[inputallRadio findChildTag:@"label"] allContents]);
            
            [self.arrayOptions addObject:[NSArray arrayWithObjects:[[inputallRadio findChildTag:@"label"] allContents], [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"name"], nil]];
            
            //setObject:[[[inputallRadio children] objectAtIndex:1] allContents] forKey:[[[inputallRadio children] objectAtIndex:0] getAttributeNamed:@"name"]];
            
        }
    }
    else
    {
        //dejavote/clos = resultats
        int i = 0;
        self.arrayResults = [NSMutableArray array];
        [arrayResults addObject:[NSMutableDictionary dictionaryWithCapacity:3]];
        
        NSArray *temporaryAllResultsArray = [aPollNode children];
        
        //NSLog(@"c %d", temporaryAllResultsArray.count);
        
        for (HTMLNode * inputResult in temporaryAllResultsArray) { //Loop through all the tags
            
            //NSLog(@"inputResult %@", rawContentsOfNode([inputResult _node], [myParser _doc]));
            
            
            if (![arrayResults objectAtIndex:i]) {
                [arrayResults addObject:[NSMutableDictionary dictionaryWithCapacity:3]];
            }
            
            if ([[inputResult getAttributeNamed:@"class"] isEqualToString:@"sondageLeft"]) {
                //
                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[NSNumber numberWithInt:[[[[inputResult children] objectAtIndex:3] allContents] integerValue]] forKey:@"pcVote"];
                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[NSNumber numberWithInt:[[[[inputResult children] objectAtIndex:5] allContents] integerValue]] forKey:@"nbVote"];
                continue;
            }
            else if ([[inputResult getAttributeNamed:@"class"] isEqualToString:@"sondageRight"]) {
                //
                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[[inputResult allContents] stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""] forKey:@"labelVote"];
                continue;
            }
            else if ([[inputResult getAttributeNamed:@"class"] isEqualToString:@"spacer"]) {
                i++;
                [arrayResults addObject:[NSMutableDictionary dictionaryWithCapacity:3]];
                continue;
            }
            else
            {
                continue;
            }
            
        }
        [arrayResults removeLastObject];
        //NSLog(@"arrayResults %@", arrayResults);
    }
    
    //SONDAGE PARSE
    
    
    if(self.intNombreChoix > 1)
    {
        self.navigationItem.prompt = [NSString stringWithFormat:@"%d choix possibles", self.intNombreChoix];
        self.tableViewPoll.allowsMultipleSelection = YES;
    }
    else {
        self.navigationItem.prompt = nil;
        self.tableViewPoll.allowsMultipleSelection = NO;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    

}

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
    
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self.delegate currentUrl]]]]];
	[request setShouldRedirect:NO];
    
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	[self.maintenanceView setHidden:YES];
	[self.tableViewPoll setHidden:YES];
	[self.loadingView setHidden:NO];
	
	//--
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	NSLog(@"fetchContentComplete");

    
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[request responseString] error:NULL];
	HTMLNode * bodyNode = [myParser body]; //Find the body tag
    NSLog(@"setupPoll");
	HTMLNode * tmpPollNode = [[bodyNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO] retain];
	if(tmpPollNode)
    {
        NSString *pollNode = rawContentsOfNode([tmpPollNode _node], [myParser _doc]);
        [self setupFromPollString:pollNode];
        [self setupHeaders];
        [self.delegate setPollNode:pollNode];
    }
    
	//[self.arrayData removeAllObjects];
	[self.tableViewPoll reloadData];
	
	//[self loadDataInTableView:[request responseData]];
    
	[self.loadingView setHidden:YES];
    
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:
			[self.maintenanceView setText:self.statusMessage];
            
            [self.loadingView setHidden:YES];
			[self.maintenanceView setHidden:NO];
			[self.tableViewPoll setHidden:YES];
			break;
		default:
			[self.tableViewPoll reloadData];
            
            [self.loadingView setHidden:YES];
            [self.maintenanceView setHidden:YES];
			[self.tableViewPoll setHidden:NO];
			break;
	}
    
	
	[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:YES];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    
    [self.maintenanceView setText:@"oops :o"];
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:NO];
    [self.tableViewPoll setHidden:YES];
	
	[(UISegmentedControl *)[self.navigationItem.titleView.subviews objectAtIndex:0] setUserInteractionEnabled:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:667];
	[alert show];
	[alert release];	
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Sondage";
    
    [self.maintenanceView setHidden:YES];
    [self.loadingView setHidden:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *voteButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Vote", nil) style:UIBarButtonItemStyleDone target:self action:@selector(voteButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = voteButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [self setupHeaders];
    NSLog(@"WIDTH %f", self.view.frame.size.width);

}

-(void)setupHeaders {
    // Get the text so we can measure it
    NSString *text = self.stringFooter;
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:11] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 25.0f) + 10;
    // return the height, with a bit of extra padding in
    //NSLog(@"height %f - %@", height, NSStringFromCGSize(constraint));
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    v.backgroundColor = [UIColor clearColor];
    
    UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, height)] autorelease];
    [titleLabel setText:text];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [v addSubview:titleLabel];
    
    [self.tableViewPoll setTableFooterView:v];
    //[self.tableView setTableHeaderView:v];
    [v release];
    
    // Get the text so we can measure it
    NSString *text2 = self.stringQuestion;
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint2 = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);

    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size2 = [text2 sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:constraint2 lineBreakMode:NSLineBreakByWordWrapping];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height2 = MAX(size2.height, 25.0f) + 10;
    // return the height, with a bit of extra padding in
    //NSLog(@"height %f - %@", height, NSStringFromCGSize(constraint));
    
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height2)];
    v2.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
    
    v2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    v2.backgroundColor = [UIColor clearColor];
    
    UILabel* titleLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, height2)] autorelease];
    [titleLabel2 setText:text2];
    [titleLabel2 setNumberOfLines:0];
    [titleLabel2 setFont:[UIFont boldSystemFontOfSize:13]];
    [titleLabel2 setBackgroundColor:[UIColor clearColor]];
    titleLabel2.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [v2 addSubview:titleLabel2];
    
    [self.tableViewPoll setTableHeaderView:v2];
    //[self.tableView setTableHeaderView:v];
    [v2 release];
    

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[self.view resignFirstResponder];
    
	[self.tableViewPoll deselectRowAtIndexPath:self.tableViewPoll.indexPathForSelectedRow animated:NO];
}


- (void)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)voteButtonPressed:(id)sender {
    //NSLog(@"iP %@", self.arraySelectedRows);


    
    ASIFormDataRequest  *arequest =
    [[[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user/vote.php?config=hfr.inc", kForumURL]]] autorelease];
    
    for (NSString *key in self.arrayInputData) {
        [arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
    }
    
    for(NSIndexPath *indexPath in self.arraySelectedRows)
    {
        [arequest setPostValue:@"1" forKey:[[self.arrayOptions objectAtIndex:indexPath.row] objectAtIndex:1]];
    }
    
    [arequest startSynchronous];

    if (arequest) {
        if ([arequest error]) {
            //NSLog(@"error: %@", [[arequest error] localizedDescription]);
            
            UIAlertView *alertKO = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[[arequest error] localizedDescription]
                                                             delegate:self cancelButtonTitle:@"Retour" otherButtonTitles: nil];
            [alertKO show];
            [alertKO release];
        }
        else if ([arequest responseString])
        {
            //NSLog(@"resp %@", [arequest responseString]);
            
            NSError * error = nil;
            HTMLParser *myParser = [[HTMLParser alloc] initWithString:[arequest responseString] error:&error];
            
            HTMLNode * bodyNode = [myParser body]; //Find the body tag
            
            HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
            
            
            if ([messagesNode findChildTag:@"a"] || [messagesNode findChildTag:@"input"]) {
                UIAlertView *alertKKO = [[UIAlertView alloc] initWithTitle:nil message:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertKKO show];
                [alertKKO release];
            }
            else {
                UIAlertView *alertOK = [[UIAlertView alloc] initWithTitle:@"Hooray !" message:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                                 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

                [alertOK show];

                [alertOK release];
                
                
                //NSLog(@"responseString %@", [arequest responseString]);
                
                // On regarde si on doit pas positionner le scroll sur un topic
                NSArray * urlArray = [[arequest responseString] arrayOfCaptureComponentsMatchedByRegex:@"<meta http-equiv=\"Refresh\" content=\"[^#]+([^\"]*)\" />"];
                
                
                //NSLog(@"%d", urlArray.count);
                if (urlArray.count > 0) {
                    NSLog(@"%@", [[urlArray objectAtIndex:0] objectAtIndex:0]);
                    
                    if ([[[urlArray objectAtIndex:0] objectAtIndex:1] length] > 0) {
                        //NSLog(@"On doit refresh sur #");
                        //[self setRefreshAnchor:[[urlArray objectAtIndex:0] objectAtIndex:1]];
                        //NSLog(@"refreshAnchor %@", self.refreshAnchor);
                    }
                    
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
                //[self.delegate addMessageViewControllerDidFinishOK:self];
                [self fetchContent];
            }
            
            
            [myParser release];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    // Return the number of rows in the section.
    if (self.arrayOptions.count) {

        return self.arrayOptions.count;
    }
    else if (self.arrayResults.count)
    {
        return self.arrayResults.count;
    }
    else
        return 0;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.stringQuestion;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGFloat curWidth = self.view.frame.size.width;
    CGFloat curHeight = [self tableView:tableView heightForHeaderInSection:section];
    
    //NSLog(@"W:%f H:%f", curWidth, curHeight);
    
    //UIView globale
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,curHeight)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
	customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, curWidth - 30, curHeight)] autorelease];
    [titleLabel setText:self.stringQuestion];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:[UIFont systemFontOfSize:13]];
    
    [customView addSubview:titleLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Get the text so we can measure it
    NSString *text = self.stringQuestion;
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 25.0f);
    // return the height, with a bit of extra padding in
    //NSLog(@"height %f - %@", height, NSStringFromCGSize(constraint));
    return height + (5 * 2);
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrayOptions.count) {
        
        static NSString *CellIdentifier = @"PollCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if([self.arraySelectedRows containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Configure the cell...
        [cell.textLabel setText:[[arrayOptions objectAtIndex:indexPath.row] objectAtIndex:0]];
        return cell;
    }
    else
    {
        static NSString *ResultCellIdentifier = @"ResultCell";

        PollResultTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"PollResultTableViewCell" bundle:nil] forCellReuseIdentifier:ResultCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
        }
        
        // Configure the cell...
        [cell.labelLabel setText:[[arrayResults objectAtIndex:indexPath.row] valueForKey:@"labelVote"]];

        
        [cell.pcLabel setText:[NSString stringWithFormat:@"%@%%", [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"pcVote"]]];
        if ([[[arrayResults objectAtIndex:indexPath.row] valueForKey:@"nbVote"] intValue] > 1) {
            [cell.nbLabel setText:[NSString stringWithFormat:@"%@ votes", [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"nbVote"]]];
        }
        else
            [cell.nbLabel setText:[NSString stringWithFormat:@"%@ vote", [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"nbVote"]]];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            cell.pcLabelView.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        }
        else {
            [cell.pcLabelView setBackgroundColor:[UIColor colorWithRed:42/255.f green:116/255.f blue:217/255.f alpha:1.00]];
            
        }
        
        
//        [cell.textLabel setText:[[arrayResults objectAtIndex:indexPath.row] valueForKey:@"labelVote"]];
  //      [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ vote(s) - %@%%", [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"nbVote"], [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"pcVote"]]];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PollResultTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.arrayOptions.count) {
    }
    else {
        [cell.pcLabelView setFrame:CGRectMake(  cell.pcLabelView.frame.origin.x,
                                              cell.pcLabelView.frame.origin.y,
                                              MAX(cell.frame.size.width * [[[arrayResults objectAtIndex:indexPath.row] valueForKey:@"pcVote"] intValue] / 100, 0),
                                              cell.pcLabelView.frame.size.height)];

    
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrayResults.count > 0) {
        return;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone && self.arraySelectedRows.count < self.intNombreChoix) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.arraySelectedRows addObject:indexPath];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.arraySelectedRows removeObject:indexPath];
    }

    [self.tableViewPoll deselectRowAtIndexPath:indexPath animated:YES];

    if(self.arraySelectedRows.count > 0)
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    else
        [self.navigationItem.rightBarButtonItem setEnabled:NO];

}


@end
