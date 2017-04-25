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

- (id)initWithPollNode:(HTMLNode *)aPollNode andParser:(HTMLParser *)aPollParser;
{
    self = [super init];
    if (self) {

        
        // Custom initialization
        [self setupFromPollNode:aPollNode andParser:aPollParser];
        
    }
    return self;
}


- (void)setupFromPollNode:(HTMLNode *)aPollNode andParser:(HTMLParser *)myParser {
    
    //SONDAGE PARSE
    //HTMLNode * aPollNode = [myParser body]; //Find the body tag
    //aPollNode = [aPollNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO];
    
    NSString *aPollNodeString = rawContentsOfNode([aPollNode _node], [myParser _doc]);
    //NSLog(@"aPollNode %@", rawContentsOfNode([aPollNode _node], [myParser _doc]));
    
    //INIT
    self.arraySelectedRows = [NSMutableArray array];
    self.arrayOptions = [NSMutableArray array];
    self.arrayInputData = [NSMutableDictionary dictionary];
    self.arraySubmitBtn = [NSMutableDictionary dictionary];
    //NSLog(@"pollNode %@", aPollNode);
    
    
    //LA Question
    HTMLNode *titleNode = [aPollNode findChildWithAttribute:@"class" matchingName:@"s2" allowPartial:NO];
   
    
    
    self.stringQuestion =  [self fixedString:[titleNode allContents]];
    
    //Header infos
    NSString *regularExpressionString = @".*</b>(.*)<ol type=\"1\">.*";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:aPollNodeString];
    
    if (myStringMatchesRegEx) {
        NSString* stringHeader = [aPollNodeString stringByMatching:regularExpressionString capture:1L];
        //NSLog(@"stringHeader %@", stringHeader);
        
        NSString* regularExpressionString2 = @".* ([0-9]{1,2}) .*";
        NSPredicate *regExPredicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString2];

        BOOL myStringMatchesRegEx2 = [regExPredicate2 evaluateWithObject:stringHeader];
        if (myStringMatchesRegEx2) {
            
            NSString* stringNombreChoix = [stringHeader stringByMatching:regularExpressionString2 capture:1L];
            //NSLog(@"stringNombreChoix %@", stringNombreChoix);

            self.intNombreChoix = [stringNombreChoix integerValue];

        }
        else {
            self.intNombreChoix = 1;

        }
        
    }
    else {
        self.intNombreChoix = 1;
    }
    
    //NSLog(@"intNombreChoix %d", self.intNombreChoix);
    
    //Footer infos
    self.stringFooter = rawContentsOfNode([[[aPollNode children] objectAtIndex:[aPollNode children].count-1] _node], [myParser _doc]);
    self.stringFooter = [[[self.stringFooter stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r"] stripHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.stringFooter = [self fixedString:self.stringFooter];
    
    
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
        
        int nbO = 1;
        //Choix du sondage
        NSArray *temporaryAllRadioArray = [aPollNode findChildTags:@"li"];
        for (HTMLNode * inputallRadio in temporaryAllRadioArray) { //Loop through all the tags
            
            //NSLog(@"inputallRadio %@", rawContentsOfNode([inputallRadio _node], [myParser _doc]));
            
            
            //NSLog(@"name %@ value %@ type %@",  [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"name"],
            //                                    [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"value"],
            //                                    [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"type"]);
            //NSLog(@"text %@", [[inputallRadio findChildTag:@"label"] allContents]);


            
            [self.arrayOptions addObject:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d. %@", nbO, [self fixedString:[[inputallRadio findChildTag:@"label"] allContents]]], [[inputallRadio findChildTag:@"input"] getAttributeNamed:@"name"], nil]];
            
            //setObject:[[[inputallRadio children] objectAtIndex:1] allContents] forKey:[[[inputallRadio children] objectAtIndex:0] getAttributeNamed:@"name"]];
            nbO++;
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
            
    
            
            
            if (![arrayResults objectAtIndex:i]) {
                [arrayResults addObject:[NSMutableDictionary dictionaryWithCapacity:3]];
            }
            
            if ([[inputResult getAttributeNamed:@"class"] isEqualToString:@"sondageLeft"]) {
                //
                
                
                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[NSNumber numberWithInt:[[self fixedString:[[[inputResult children] objectAtIndex:1] allContents]] integerValue]] forKey:@"pcVote"];
                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[NSNumber numberWithInt:[[self fixedString:[[[inputResult children] objectAtIndex:2] allContents]] integerValue]] forKey:@"nbVote"];
                continue;
            }
            else if ([[inputResult getAttributeNamed:@"class"] isEqualToString:@"sondageRight"]) {
                //

                [(NSMutableDictionary *)[arrayResults objectAtIndex:i] setObject:[([self fixedString:[inputResult allContents]] ? [self fixedString:[inputResult allContents]] : @"") stringByReplacingOccurrencesOfString:@"  " withString:@" "] forKey:@"labelVote"];

                
                
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
    
    //NSLog(@"arrayResults %@", arrayResults);

    //NSLog(@"arrayOptions %@", arrayOptions);

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
    

    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        if (self.arrayOptions.count) {
            self.tableViewPoll.separatorColor = [UIColor lightGrayColor];
        }
        else {
            self.tableViewPoll.separatorColor = [UIColor clearColor];
        }
        
    });

}

-(NSString *)fixedString:(NSString *)orig {
    return orig;
}

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"fetchContent %@", [NSString stringWithFormat:@"%@%@", [k ForumURL], [self currentUrl]]);
	self.status = kIdle;
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [k ForumURL], [self.delegate currentUrl]]]]];
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
	//NSLog(@"fetchContentComplete");

    
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[request responseString] error:NULL];
	HTMLNode * bodyNode = [myParser body]; //Find the body tag
    NSLog(@"setupPoll");
	HTMLNode * tmpPollNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO];
	if(tmpPollNode)
    {
        //NSString *pollNode = rawContentsOfNode([tmpPollNode _node], [myParser _doc]);
        [self setupFromPollNode:tmpPollNode andParser:myParser];
        [self setupHeaders];
        [self.delegate setPollNode:tmpPollNode];
        [self.delegate setPollParser:myParser];
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
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Sondage";
    
    [self.maintenanceView setHidden:YES];
    [self.loadingView setHidden:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        if (self.arrayOptions.count) {
            self.tableViewPoll.separatorColor = [UIColor lightGrayColor];
        }
        else {
             self.tableViewPoll.separatorColor = [UIColor clearColor];
        }

    });
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *voteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Vote", nil) style:UIBarButtonItemStyleDone target:self action:@selector(voteButtonPressed:)];
    self.navigationItem.rightBarButtonItem = voteButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [self setupHeaders];
    
    //NSLog(@"viewDidLoad");
    


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
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, height)];
    [titleLabel setText:text];
    [titleLabel setNumberOfLines:0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [v addSubview:titleLabel];
    
    [self.tableViewPoll setTableFooterView:v];
    //[self.tableView setTableHeaderView:v];
    
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
    
    UILabel* titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, height2)];
    [titleLabel2 setText:text2];
    [titleLabel2 setNumberOfLines:0];
    [titleLabel2 setFont:[UIFont boldSystemFontOfSize:13]];
    [titleLabel2 setBackgroundColor:[UIColor clearColor]];
    titleLabel2.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [v2 addSubview:titleLabel2];
    
    [self.tableViewPoll setTableHeaderView:v2];
    //[self.tableView setTableHeaderView:v];
    

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
    [[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user/vote.php?config=hfr.inc", [k ForumURL]]]];
    
    for (NSString *key in self.arrayInputData) {
        [arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
    }
    
    for(NSIndexPath *indexPath in self.arraySelectedRows)
    {
        if (self.intNombreChoix == 1) {
            [arequest setPostValue:[NSString stringWithFormat:@"%d", (indexPath.row+1)] forKey:[[self.arrayOptions objectAtIndex:indexPath.row] objectAtIndex:1]];
        }
        else{
            [arequest setPostValue:@"1" forKey:[[self.arrayOptions objectAtIndex:indexPath.row] objectAtIndex:1]];
        }

    }
    
    [arequest startSynchronous];

    if (arequest) {
        if ([arequest error]) {
            //NSLog(@"error: %@", [[arequest error] localizedDescription]);
            
            UIAlertView *alertKO = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[[arequest error] localizedDescription]
                                                             delegate:nil cancelButtonTitle:@"Retour" otherButtonTitles: nil];
            [alertKO show];
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
            }
            else {
                UIAlertView *alertOK = [[UIAlertView alloc] initWithTitle:@"Hooray !" message:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                                 delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                [alertOK setTag:kAlertSondageOK];
                [alertOK show];

                
                
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
            
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AlertView Delegate

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    NSLog(@"didPresentAlertView PT %@", alertView);
    
    if ([alertView tag] == kAlertSondageOK) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex PT %@ index : %ld", alertView, (long)buttonIndex);
    
    if (buttonIndex == 1 && alertView.tag == 667) {
        [self fetchContent];
    }
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.textLabel setBackgroundColor:[UIColor redColor]];
            cell.textLabel.numberOfLines = 0;
        }
        
        if([self.arraySelectedRows containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Configure the cell...
        [cell.textLabel setText:[[arrayOptions objectAtIndex:indexPath.row] objectAtIndex:0]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];

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
        
        // Get the text so we can measure it
        NSString *text = [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"labelVote"];
        CGSize constraint = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = size.height + 10;
        
        //NSLog(@"indexPath %d %f %f", indexPath.row, self.view.frame.size.width, size.height);

        
        CGFloat heightDiff = height - cell.labelLabel.frame.size.height;
        
        CGRect oldLabelFrame = cell.labelLabel.frame;
        CGRect newLabelFrame = oldLabelFrame;
        
        newLabelFrame.size.height = height;
        
        cell.labelLabel.frame = newLabelFrame;
        
        cell.pcLabelView.frame = CGRectMake(cell.pcLabelView.frame.origin.x, cell.pcLabelView.frame.origin.y + heightDiff,
                                            cell.pcLabelView.frame.size.width, cell.pcLabelView.frame.size.height);

        cell.pcLabelBgView.frame = CGRectMake(cell.pcLabelBgView.frame.origin.x, cell.pcLabelBgView.frame.origin.y + heightDiff,
                                            cell.pcLabelBgView.frame.size.width, cell.pcLabelBgView.frame.size.height);

        cell.pcLabel.frame = CGRectMake(cell.pcLabel.frame.origin.x, cell.pcLabel.frame.origin.y + heightDiff,
                                            cell.pcLabel.frame.size.width, cell.pcLabel.frame.size.height);

        cell.nbLabel.frame = CGRectMake(cell.nbLabel.frame.origin.x, cell.nbLabel.frame.origin.y + heightDiff,
                                        cell.nbLabel.frame.size.width, cell.nbLabel.frame.size.height);
        
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

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if (self.arrayOptions.count) {
        NSString *text = [[arrayOptions objectAtIndex:indexPath.row] objectAtIndex:0];
        CGSize constraint = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(size.height + 10, 50);
        
    }
    else {
        NSString *text = [[arrayResults objectAtIndex:indexPath.row] valueForKey:@"labelVote"];
        CGSize constraint = CGSizeMake(self.view.frame.size.width - (15 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        height = size.height + 10;

        //NSLog(@"indexPath %d %f %f", indexPath.row, self.view.frame.size.width, size.height);

        
        height += 18.0f;
        height += 11.0f;
    }
    return height;
}


// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"aR %d aSR %d nbChoix %d", self.arrayResults.count, self.arraySelectedRows.count, self.intNombreChoix);
    
    if (self.arrayResults.count > 0) {
        return;
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.intNombreChoix == 1 && self.arraySelectedRows.count == 1 && cell.accessoryType == UITableViewCellAccessoryNone) {
        //NSLog(@"on vire");
        //on vire la checkmark
        [[self.tableViewPoll cellForRowAtIndexPath:[self.arraySelectedRows objectAtIndex:0]] setAccessoryType:UITableViewCellAccessoryNone];
        [self.arraySelectedRows removeAllObjects];
    }
    
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
    
    
    //NSLog(@"aR %d aSR %d nbChoix %d", self.arrayResults.count, self.arraySelectedRows.count, self.intNombreChoix);
    //NSLog(@"arraySelectedRows %@", self.arraySelectedRows);

}


@end
