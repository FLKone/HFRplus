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
#import "InsetLabel.h"
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
    
    NSArray *sortedArray = [[[BlackList shared] getAll] sortedArrayUsingFunction:Sort_BL_Comparer context:(__bridge void * _Nullable)(self)];

    
    self.blackListDict = (NSMutableArray *)sortedArray;//[[[BlackList shared] getAll] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      //  return [[obj1 valueForKey:@"word"] compare:[obj2 valueForKey:@"word"]];
    //}];
    
    [self.tableView reloadData];
}
-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"vwa");
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    
    if (self.blackListDict.count) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        return 1;
    }
    else {
        // Display a message when the table is empty
        InsetLabel *messageLabel = [[InsetLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        
        if ([NSTextAttachment class]) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Pour ajouter quelqu'un, selectionnez son pseudo, puis "];
            
            // creates a text attachment with an image
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            
            attachment.image = [UIImage imageNamed:@"ThorHammerBlack-20"];
            
            NSAttributedString *imageAttrString = [NSAttributedString attributedStringWithAttachment:attachment];
            
            [attributedString appendAttributedString:imageAttrString];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" !"]];
            
            messageLabel.attributedText = attributedString;
        }
        else {
            messageLabel.text = @"Pour ajouter quelqu'un, selectionnez son pseudo dans un sujet.";
            messageLabel.font = [UIFont systemFontOfSize:15.0f];
        }

        //messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        //messageLabel.font = [UIFont systemFontOfSize:15.0f];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    
    
    return 0;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"word"];
    cell.detailTextLabel.text = [[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"mode"];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[BlackList shared] removeWord:[[self.blackListDict objectAtIndex:indexPath.row] valueForKey:@"word"]];
        [self reloadData];
        
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    //NSLog(@"dealloc ADD");
    
    [self viewDidUnload];
}

@end
