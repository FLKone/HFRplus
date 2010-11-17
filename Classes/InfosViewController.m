//
//  InfosViewController.m
//  HFR+
//
//  Created by Lace on 23/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InfosViewController.h"

#import "IdentificationViewController.h"
#import	"AideViewController.h"
#import "CreditsViewController.h"

@implementation InfosViewController

@synthesize menuList, infosTableView, lastViewController;

static NSArray *pageNames = nil;

- (void)dealloc
{
    [infosTableView release];
	[menuList release];
	if(lastViewController) [lastViewController release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	self.title = @"Infos";
	
	// Make the title of this page the same as the title of this app
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor =[UIColor whiteColor];
	//label.text= @"HFR+ 1.1 (1.1.0.7)";
	label.text= [NSString stringWithFormat:@"HFR+ %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];	
	self.navigationItem.titleView = label;		
	[label release];
	
	self.menuList = [NSMutableArray array];

    if (!pageNames)
	{
		pageNames = [[NSArray alloc] initWithObjects:@"Compte", @"Aide", @"Credits", nil];
    }
	
    for (NSString *pageName in pageNames)
	{
		[self.menuList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								  pageName, kTitleKey,
								  nil]];
	}

	
	[self.infosTableView reloadData];
}

- (void)viewDidUnload
{
	self.infosTableView = nil;
	self.menuList = nil;
	
	[super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
	
	[super viewWillAppear:animated];
	
	[self.infosTableView deselectRowAtIndexPath:self.infosTableView.indexPathForSelectedRow animated:NO];

	if(lastViewController) [lastViewController release];
	[self setLastViewController:nil];


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
	return menuList.count;
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
	
	NSString *viewControllerName = [[pageNames objectAtIndex:indexPath.row] stringByAppendingString:@"ViewController"];
	UIViewController *targetViewController = [[NSClassFromString(viewControllerName) alloc] initWithNibName:viewControllerName bundle:nil];
	[self setLastViewController:targetViewController];
	
	//[targetViewController release];
	/*
	self.navigationItem.backBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"Retour"
									 style: UIBarButtonItemStyleBordered
									target:nil
									action:nil];
	*/
	
    [self.navigationController pushViewController:targetViewController animated:YES];
}


@end

