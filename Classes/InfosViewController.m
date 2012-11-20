//
//  InfosViewController.m
//  HFRplus
//
//  Created by FLK on 23/07/10.
//

#import "InfosViewController.h"

#import "IdentificationViewController.h"
#import	"AideViewController.h"
#import "CreditsViewController.h"
#import "HFRplusAppDelegate.h"
#import "HFRDebugViewController.h"


@implementation InfosViewController

@synthesize menuList, lastViewController;

- (void)dealloc
{
	[menuList release];
	if(lastViewController) [lastViewController release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	self.title = [NSString stringWithFormat:@"HFR+ %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
	
	// Make the title of this page the same as the title of this app
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor =[UIColor whiteColor];
	//label.text= @"HFR+ 1.1 (1.1.0.7)";
	label.text= [NSString stringWithFormat:@"HFR+ %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];	
	//self.navigationItem.titleView = label;		
	[label release];
	
    [self hideEmptySeparators];
    
	self.menuList = [NSMutableArray array];
	
    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Mon Compte", @"CompteViewController", @"CompteViewController", @"111-user", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
                        
    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Aide", @"AideViewController", @"AideViewController", @"113-navigation", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    
    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Crédits", @"CreditsViewController", @"CreditsViewController", @"122-stats", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    
    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Faire un don", @"PayViewController", @"PayViewController", @"119-piggy-bank", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];    
    
    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Réglages", @"SettingsViewController", @"IASKAppSettingsView", @"20-gear2", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];   

    [self.menuList addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Debug", @"HFRDebugViewController", @"HFRDebugViewController", @"19-gear", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];   
        
    
}

- (void)viewDidUnload
{
	self.menuList = nil;
	
	[super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
	
	[super viewWillAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];

	if(lastViewController) [lastViewController release];
	[self setLastViewController:nil];

    [self.tableView reloadData];

}
/*
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL debug = [defaults boolForKey:@"menu_debug"];
	
    //NSLog(@"display %@", display);
    
	if (!debug) { 
        return menuList.count - 1;
        
    }
    else {
        return menuList.count;

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// get the view controller's info dictionary based on the indexPath's row
    NSDictionary *dataDictionary = [menuList objectAtIndex:indexPath.row];
    cell.textLabel.text = [dataDictionary valueForKey:kTitleKey];
    
    UIImage* theImage = [UIImage imageNamed:[dataDictionary valueForKey:kImageKey]];
    cell.imageView.image = theImage;
    
	return cell;
    
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
    NSMutableDictionary *rowData = [self.menuList objectAtIndex:indexPath.row];
	UIViewController *targetViewController = [rowData objectForKey:kViewControllerKey];
	if (!targetViewController)
	{
		NSLog(@"newcontroller");
        NSString *viewControllerName = [[pageNames objectAtIndex:indexPath.row] stringByAppendingString:@"ViewController"];
        targetViewController = [[NSClassFromString(viewControllerName) alloc] initWithNibName:viewControllerName bundle:nil];
        [rowData setValue:targetViewController forKey:kViewControllerKey];
        [targetViewController release];
    }
	*/
	
    NSMutableDictionary *rowData = [self.menuList objectAtIndex:indexPath.row];

    UIViewController *targetViewController = [[NSClassFromString([rowData valueForKey:kViewControllerKey]) alloc] initWithNibName:[rowData valueForKey:kXibKey] bundle:nil];
    [targetViewController awakeFromNib];
    
	[self setLastViewController:targetViewController];
    [self.navigationController pushViewController:targetViewController animated:YES];
    
}


@end

