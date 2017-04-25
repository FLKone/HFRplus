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
@synthesize reloadOnAppear, actionButton, reloadButton;

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

    self.navigationItem.titleView = nil;
    //if([self isKindOfClass:[HFRMPViewController class]]) 
    
    [self showBarButton:kNewTopic];
    [self showBarButton:kReload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginChanged:)
                                                 name:kLoginChangedNotification
                                               object:nil];
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

-(void)LoginChanged:(NSNotification *)notification {
    NSLog(@"loginChanged %@", notification);
    
    self.reloadOnAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"viewWillAppear Forums Table View");
    
    
    [super viewWillAppear:animated];

    if (self.reloadOnAppear) {
        [self fetchContent];
        self.reloadOnAppear = NO;
    }
    
    //On repositionne les boutons
    [self showBarButton:kSync];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //NSLog(@"dealloc Forums Table View");
    [self viewDidUnload];


    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginChangedNotification object:nil];
 
    
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
    if ((cell = [super tableView:tableView cellForRowAtIndexPath:indexPath])) {
		
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

	
	//setup the URL
	self.messagesTableViewController.topicName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.messagesTableViewController.isViewed = [[arrayData objectAtIndex:indexPath.row] isViewed];	

    [self pushTopic];
	//NSLog(@"push message liste");

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"page %d", [self pageNumber]];
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint longPressLocation = [longPressRecognizer locationInView:self.topicsTableView];
		self.pressedIndexPath = [[self.topicsTableView indexPathForRowAtPoint:longPressLocation] copy];
		
        if (self.topicActionSheet != nil) {
            self.topicActionSheet = nil;
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
	

    [self statusBarButton:kNewTopic enable:NO];
}


-(void)loadDataInTableView:(NSData *)contentData {
	[super loadDataInTableView:contentData];
    [self statusBarButton:kNewTopic enable:NO];

}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"buttonIndex %d", buttonIndex);
	switch (buttonIndex)
	{
		case 0:
		{
			
			MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[arrayData objectAtIndex:pressedIndexPath.row] aURLOfLastPage]];
			self.messagesTableViewController = aView;
			
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
    [self showBarButton:kCancel];
    [self statusBarButton:kNewTopic enable:NO];

	[super fetchContentStarted:theRequest];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{

	//Bouton Reload
    [self showBarButton:kReload];
	
	[super fetchContentComplete:theRequest];

    //NSLog(@"%d", self.status);
    
	switch (self.status) {
		case kMaintenance:
		case kNoAuth:
            [self statusBarButton:kNewTopic enable:NO];
			break;
		case kNoResults:            
		default:
            [self statusBarButton:kNewTopic enable:YES];
			break;
	}
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentFailed");
	//Bouton Reload
    [self showBarButton:kReload];
	
	[super fetchContentFailed:theRequest];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

-(void)statusBarButton:(BARBTNTYPE)type enable:(bool)enable {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger vos_sujets = [defaults integerForKey:@"main_gaucheWIP"];

    
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        vos_sujets == 0) {
        NSLog(@"à droite");
        
        switch (type) {
            case kNewTopic:
            default:
            {
                NSLog(@"NEW TOPIC");
                [self.navigationItem.leftBarButtonItem setEnabled:enable];
                [self.actionButton setEnabled:enable];
            }
                break;

        }
    }
    else {
        NSLog(@"à gauche");
        
        switch (type) {
            case kNewTopic:
            default:
                
            {
                NSLog(@"NEW TOPIC");
                [self.navigationItem.rightBarButtonItem setEnabled:enable];
                [self.actionButton setEnabled:enable];

            }
                break;

        }
        
        
    }
}

-(void)showBarButton:(BARBTNTYPE)type {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger vos_sujets = [defaults integerForKey:@"main_gaucheWIP"];
    //NSLog(@"maingauche %d", (vos_sujets == 0));
    //NSLog(@"maingauche %d", ([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact));
    
    if (type == kSync) {
        //On inverse les boutons
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
            vos_sujets == 0) {
            //NSLog(@"DROITE ");
            if (!(self.navigationItem.leftBarButtonItem.action == @selector(newTopic))) {
                self.navigationItem.rightBarButtonItem = self.navigationItem.leftBarButtonItem;
                self.navigationItem.leftBarButtonItem = self.actionButton;
            }

            
        }
        else {
            //NSLog(@"GAUCHE");
            
            if ((self.navigationItem.leftBarButtonItem.action == @selector(newTopic))) {
                //NSLog(@"IN GAUCHE");
                self.navigationItem.leftBarButtonItem = self.navigationItem.rightBarButtonItem;
                self.navigationItem.rightBarButtonItem = self.actionButton;
            }
            

        }
        
        return;
    }
    
    
    
    
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        vos_sujets == 0) {
        //NSLog(@"à droite");
        
        switch (type) {
            case kNewTopic:
            {
                //NSLog(@"NEW TOPIC");
                self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newTopic)];
                self.navigationItem.leftBarButtonItem = self.actionButton;
            }
                break;
            case kCancel:
            {
                //NSLog(@"CANCEL");
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
            }
                break;
            case kReload:
            default:
            {
                //NSLog(@"RELOAD");
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
            }
                break;
        }
    }
    else {
        //NSLog(@"à gauche");
        
        switch (type) {
            case kNewTopic:
            {
               //NSLog(@"NEW TOPIC");
                self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newTopic)];
                self.navigationItem.rightBarButtonItem = self.actionButton;
            }
                break;
            case kCancel:
            {
                //NSLog(@"CANCEL");
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
            }
                break;
            case kReload:
            default:
            {
                //NSLog(@"RELOAD");
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchContent)];
            }
                break;
        }
        
        
    }
}

-(NSString *)newTopicTitle
{
	return @"Nouv. Message";	
}

@end
