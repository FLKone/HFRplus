//
//  MPViewController.m
//  HFR+
//
//  Created by Lace on 23/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
	self.currentUrl = @"/forum1.php?config=hfr.inc&cat=prive&page=1";
		
    [super viewDidLoad];

	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newTopic)];
	self.navigationItem.leftBarButtonItem = segmentBarItem;
    [segmentBarItem release];	
	
	segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];		
	
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

	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	//label.frame = CGRectMake(0, 0, 500, self.navigationController.navigationBar.frame.size.height - 4);
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;// | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	[label setFont:[UIFont boldSystemFontOfSize:13.0]];
	[label setAdjustsFontSizeToFitWidth:YES];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextAlignment:UITextAlignmentCenter];
	[label setLineBreakMode:UILineBreakModeMiddleTruncation];
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(0.0, -1.0);
	[label setTextColor:[UIColor whiteColor]];
	[label setNumberOfLines:0];
	
	[label setText:[[arrayData objectAtIndex:indexPath.row] aTitle]];
	
	[messagesTableViewController.navigationItem setTitleView:label];
	[label release];	
	
	//setup the URL
	self.messagesTableViewController.topicName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:indexPath.row] isViewed];	

	//NSLog(@"push message liste");
	[self.navigationController pushViewController:messagesTableViewController animated:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.topicsTableView];
		pressedIndexPath = [[self.topicsTableView indexPathForRowAtPoint:longPressLocation] copy];
		
		
		UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@"Aller à..."
																delegate:self cancelButtonTitle:@"Annuler"
												  destructiveButtonTitle:nil
													   otherButtonTitles:	@"la dernière page", @"la première page", @"la page numéro...",
									 nil,
									 nil];
		
		// use the same style as the nav bar
		styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
		[styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
		[styleAlert release];
		
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
	switch (buttonIndex)
	{
		case 0:
		{
			
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]];
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
			
			[label setText:[[arrayData objectAtIndex:pressedIndexPath.row] aTitle]];
			
			[messagesTableViewController.navigationItem setTitleView:label];
			[label release];	
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

			[self.navigationController pushViewController:messagesTableViewController animated:YES];			
			
			//NSLog(@"url pressed last page: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]);
			 
			break;
		}
		case 1:
		{
			
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURL]];
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
			
			[label setText:[[arrayData objectAtIndex:pressedIndexPath.row] aTitle]];
			
			[messagesTableViewController.navigationItem setTitleView:label];
			[label release];	
			
			self.messagesTableViewController.topicName = [[arrayData objectAtIndex:pressedIndexPath.row] aTitle];	
			self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:pressedIndexPath.row] isViewed];	

			[self.navigationController pushViewController:messagesTableViewController animated:YES];	
			 
			//NSLog(@"url pressed last post: %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURL]);
			 
			break;
			
		}
        default:
        {
            [super actionSheet:modalView clickedButtonAtIndex:buttonIndex];
            break;
        }
			
	}
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//Bouton Stop
	self.navigationItem.rightBarButtonItem = nil;	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	
	
	[super fetchContentStarted:theRequest];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[super fetchContentComplete:theRequest];

	switch (self.status) {
		case kMaintenance:
		case kNoResults:
			[self.navigationItem.leftBarButtonItem setEnabled:NO];	
			break;
		default:	
			[self.navigationItem.leftBarButtonItem setEnabled:YES];	
			break;
	}
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
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
