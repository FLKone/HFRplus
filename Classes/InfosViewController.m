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
#import "AlerteModoViewController.h"


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
	self.title = [NSString stringWithFormat:@"HFR+ %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	
    /*
	// Make the title of this page the same as the title of this app
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont boldSystemFontOfSize:17.0]];
	label.textAlignment = NSTextAlignmentCenter;
	
	label.text= [NSString stringWithFormat:@"HFR+ %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //[label setTextColor:[UIColor whiteColor]];
        //label.shadowColor = [UIColor darkGrayColor];
        //label.shadowOffset = CGSizeMake(0.0, -1.0);
    }
    else {
        [label setTextColor:[UIColor colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00]];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0, 0.5f);
    }
    
    
	self.navigationItem.titleView = label;		
	[label release];
	*/
    
    [self hideEmptySeparators];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.tableView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
    
    self.menuList = [NSMutableArray array];
    self.menuList[0] = [NSMutableArray array];
    self.menuList[1] = [NSMutableArray array];
	
    [self.menuList[0] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Mon Compte", @"CompteViewController", @"CompteViewController", @"111-user", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    
    
    
    [self.menuList[1] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Aide", @"AideViewController", @"AideViewController", @"113-navigation", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    
    [self.menuList[1] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Crédits", @"CreditsViewController", @"CreditsViewController", @"122-stats", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleIdentifier isEqualToString:@"hfrplus.red"]) {
        [self.menuList[1] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Faire un don", @"PayViewController", @"PayViewController", @"119-piggy-bank", nil]
                                                                    forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];
    }
    
    [self.menuList[0] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Réglages", @"SettingsViewController", @"IASKAppSettingsView", @"20-gear2", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];   

    
    [self.menuList[0] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Liste noire", @"BlackListTableViewController", @"BlackListTableViewController", @"Thor Hammer Filled-23", nil]
                                                                forKeys:[NSArray arrayWithObjects:kTitleKey, kViewControllerKey, kXibKey, kImageKey, nil]]];

    [self.menuList[0] addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Debug", @"HFRDebugViewController", @"HFRDebugViewController", @"19-gear", nil]
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
    if (section == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL debug = [defaults boolForKey:@"menu_debug"];
        
        if (!debug)
            return ((NSMutableArray *)menuList[section]).count - 1;
    }
    return ((NSMutableArray *)menuList[section]).count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return menuList.count;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return HEIGHT_FOR_HEADER_IN_SECTION;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //On récupère la section (forum)
    CGFloat curWidth = self.view.frame.size.width;
    
    //UIView globale
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
    customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //UIImageView de fond
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIImage *myImage = [UIImage imageNamed:@"bar2.png"];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
        imageView.alpha = 0.9;
        imageView.frame = CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [customView addSubview:imageView];
    }
    else {
        //bordures/iOS7
        UIView* borderView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,1/[[UIScreen mainScreen] scale])] autorelease];
        borderView.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView];
        
        UIView* borderView2 = [[[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT_FOR_HEADER_IN_SECTION-1/[[UIScreen mainScreen] scale],curWidth,1/[[UIScreen mainScreen] scale])] autorelease];
        borderView2.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView2];
        
    }
    
    return customView;
    
}
*/

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
    NSDictionary *dataDictionary = [menuList[indexPath.section] objectAtIndex:indexPath.row];
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
	
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                     style: UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.navigationItem.backBarButtonItem.title = @" ";
    }
    
    NSMutableDictionary *rowData = [self.menuList[indexPath.section] objectAtIndex:indexPath.row];

    UIViewController *targetViewController = [[NSClassFromString([rowData valueForKey:kViewControllerKey]) alloc] initWithNibName:[rowData valueForKey:kXibKey] bundle:nil];
    [targetViewController awakeFromNib];
    
	[self setLastViewController:targetViewController];
    [self.navigationController pushViewController:targetViewController animated:YES];
    
}


@end

