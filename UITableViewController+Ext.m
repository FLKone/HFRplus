#import "UITableViewController+Ext.h"

@implementation UITableViewController (Ext)

- (void)hideEmptySeparators
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
    [v release];
}

@end