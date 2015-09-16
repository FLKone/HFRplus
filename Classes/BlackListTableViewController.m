//
//  BlackListTableViewController.m
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import "HFRplusAppDelegate.h"
#import "BlackListTableViewController.h"
#import "BlackList.h"

@interface BlackListTableViewController ()

@end

@implementation BlackListTableViewController
@synthesize blackListDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        //NSLog(@"initWithNibName add");
        //Smileys / Rehost
        self.blackListDict = [[NSMutableArray alloc] init];

    }
    return self;
}

NSInteger Sort_BL_Comparer(id id1, id id2, void *context)
{
    // Sort Function
    NSDictionary* dc1 = (NSDictionary*)id1;
    NSDictionary* dc2 = (NSDictionary*)id2;
    
    NSComparisonResult result = [[dc1 valueForKey:@"word"] compare:[dc2 valueForKey:@"word"] options:NSCaseInsensitiveSearch];

    return result;
}

-(void)reloadData {
    //NSLog(@"list: %@", [[BlackList shared] description]);
    
    NSArray *sortedArray = [[[BlackList shared] getAll] sortedArrayUsingFunction:Sort_BL_Comparer context:self];

    
    self.blackListDict = (NSMutableArray *)sortedArray;//[[[BlackList shared] getAll] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      //  return [[obj1 valueForKey:@"word"] compare:[obj2 valueForKey:@"word"]];
    //}];
    
    [self.tableView reloadData];
}
-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"vwa");
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self hideEmptySeparators];

    
    self.title = @"Liste noire";
    //[self reloadData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"self.blackListDict.count %lu", (unsigned long)self.blackListDict.count);
    return self.blackListDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellBL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"word"];
    cell.detailTextLabel.text = [[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"mode"];
    return cell;
}



/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Supprimer %@ de la liste noire ?", [[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"word"]]
                                                   delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    
    [alert setTag:667];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        [[BlackList shared] removeWord:[[self.blackListDict objectAtIndex:self.tableView.indexPathForSelectedRow.row] valueForKey:@"word"]];
    }
}

- (void)dealloc {
    //NSLog(@"dealloc ADD");
    
    [self viewDidUnload];
    
    self.blackListDict = nil;

    [super dealloc];
    
    
    
}

@end
