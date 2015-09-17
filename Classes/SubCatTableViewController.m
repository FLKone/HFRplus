//
//  SubCatTableViewController.m
//  HFRplus
//
//  Created by FLK on 02/07/12.
//

#import "SubCatTableViewController.h"
#import "Constants.h"
#import "Forum.h"

@interface SubCatTableViewController ()

@end

@implementation SubCatTableViewController

@synthesize arrayData, suPicker, notification;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self setContentSizeForViewInPopover:CGSizeMake(250.0, 35*(MIN(10, arrayData.count)))];
        
        if ([self respondsToSelector:@selector(setPreferredContentSize:)]) { //iOS7+
            [self setPreferredContentSize:CGSizeMake(250.0, 35*(MIN(10, arrayData.count)))];
        }
    //}
    
    [self hideEmptySeparators];
    
    /*
    if(!UIAccessibilityIsReduceTransparencyEnabled())
    {
        self.tableView.backgroundColor = [UIColor clearColor];
        self.navigationController.popoverPresentationController.backgroundColor = [UIColor clearColor];

        UIBlurEffect* be = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView* vev = [[UIVisualEffectView alloc] initWithEffect:be];
        vev.frame = self.tableView.frame;
        self.tableView.backgroundView = vev;
        
        self.tableView.separatorEffect = [UIVibrancyEffect effectForBlurEffect:be];
        
        //if (self.navigationController.popoverPresentationController) {
        NSLog(@"inpopOver");
        //}
    }
    */

    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	if (indexPath.row == 0) {
        	cell.textLabel.text = [NSString stringWithFormat:@"%@", [(Forum *)[arrayData objectAtIndex:indexPath.row] aTitle]];
    }
    else
        cell.textLabel.text = [NSString stringWithFormat:@"- %@", [(Forum *)[arrayData objectAtIndex:indexPath.row] aTitle]];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6]]; // set color here
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [suPicker selectRow:indexPath.row inComponent:0 animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];

}

@end
