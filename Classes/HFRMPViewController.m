//
//  MPViewController.m
//  HFRplus
//
//  Created by FLK on 23/07/10.
//

#import "HFRplusAppDelegate.h"

#import "HFRMPViewController.h"
#import "MessagesTableViewController.h"

#import "Topic.h"
#import "TopicCellView.h"

@implementation HFRMPViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//NSLog(@"vdl MP");
	
	self.forumName = @"Messages";
	self.forumBaseURL = @"/forum1.php?config=hfr.inc&cat=prive&page=1";
		
    [super viewDidLoad];

    UIBarButtonItem *composeBarItem = [UIBarButtonItem barItemWithImageNamed:@"compose" title:@"" target:self action:@selector(newTopic)];
	self.navigationItem.leftBarButtonItem = composeBarItem;
    
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
    
    /*
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newTopic)];
	self.navigationItem.leftBarButtonItem = segmentBarItem;
    [segmentBarItem release];	
	
	segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];		
	*/
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
    if ((cell = [super tableView:tableView cellForRowAtIndexPath:indexPath])) {
        // Custom initialization
		
		if ([(Topic *)[arrayData objectAtIndex:indexPath.row] isViewed]) {
			[[(TopicCellView *)cell titleLabel] setFont:[UIFont systemFontOfSize:14]];
		}
		else {
			[[(TopicCellView *)cell titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];

		}

		
		if ([[(TopicCellView *)cell titleLabel] numberOfLines] > 0) {
			[[(TopicCellView *)cell titleLabel] setNumberOfLines:0];
			
			CGRect frameTitle = [[(TopicCellView *)cell titleLabel] frame];
			frameTitle.size.height -= 10; 
			[[(TopicCellView *)cell titleLabel] setFrame:frameTitle];
			
			CGRect frameMsg = [[(TopicCellView *)cell msgLabel] frame];
			frameMsg.origin.y -= 10; 
			[[(TopicCellView *)cell msgLabel] setFrame:frameMsg];
			
			CGRect frameTime = [[(TopicCellView *)cell timeLabel] frame];
			frameTime.origin.y -= 10;	
			[[(TopicCellView *)cell timeLabel] setFrame:frameTime];
		}
		
		//[[(TopicCellView *)cell titleLabel] ];
		
		[[(TopicCellView *)cell msgLabel] setText:[NSString stringWithFormat:@"@%@", [(Topic *)[arrayData objectAtIndex:indexPath.row] aAuthorOrInter]]];

		//[(UILabel *)[cell.contentView viewWithTag:999] setFrame:CGRectMake(10, 5, 280, 22)];
		//[(UILabel *)[cell.contentView viewWithTag:997] setFrame:CGRectMake(130, 27, 150, 22)];
		
//		[(UILabel *)[cell.contentView viewWithTag:999] setBackgroundColor:[UIColor blueColor]];
		
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:indexPath.row] aURLOfLastPost]];
	self.messagesTableViewController = aView;
	[aView release];

	
	//setup the URL
	self.messagesTableViewController.topicName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:indexPath.row] isViewed];	

    [self pushTopic];
	//NSLog(@"push message liste");

}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.topicsTableView];
		self.pressedIndexPath = [[self.topicsTableView indexPathForRowAtPoint:longPressLocation] copy];
		
        if (self.topicActionSheet != nil) {
            [self.topicActionSheet release], self.topicActionSheet = nil;
        }
        
		self.topicActionSheet = [[UIActionSheet alloc] initWithTitle:@"Aller à..."
																delegate:self cancelButtonTitle:@"Annuler"
												  destructiveButtonTitle:nil
													   otherButtonTitles:	@"la dernière page", @"la première page", @"la page numéro...", @"Copier le lien",
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

-(void)reset
{
	[super reset];

	//[self.topicsTableView setHidden:YES];
	//[self.maintenanceView setHidden:YES];	
	//[self.loadingView setHidden:YES];	
	
	[self.navigationItem.leftBarButtonItem setEnabled:NO];
}


-(void)loadDataInTableView:(NSData *)contentData {
	[super loadDataInTableView:contentData];
	[self.navigationItem.leftBarButtonItem setEnabled:YES];
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex %d", buttonIndex);
	switch (buttonIndex)
	{
		case 0:
		{
			
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

			[self pushTopic];
			
			//NSLog(@"url pressed last page: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]);
			 
			break;
		}
		case 1:
		{
			
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURL]];
			self.messagesTableViewController = aView;
			[aView release];
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

			[self pushTopic];
			 
			//NSLog(@"url pressed last post: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURL]);
			 
			break;
			
		}
        default:
        {
            NSLog(@"default");
            [super actionSheet:modalView clickedButtonAtIndex:buttonIndex];
            break;
        }
			
	}
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//Bouton Stop
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"stop" title:@"" target:self action:@selector(cancelFetchContent)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
	
	[super fetchContentStarted:theRequest];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;

	
	[super fetchContentComplete:theRequest];

    //NSLog(@"%d", self.status);
    
	switch (self.status) {
		case kMaintenance:
		case kNoAuth:
			[self.navigationItem.leftBarButtonItem setEnabled:NO];	
			break;
		case kNoResults:            
		default:	
			[self.navigationItem.leftBarButtonItem setEnabled:YES];	
			break;
	}
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
	
	[super fetchContentFailed:theRequest];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

-(NSString *)newTopicTitle
{
	return @"Nouv. Message";	
}

@end
