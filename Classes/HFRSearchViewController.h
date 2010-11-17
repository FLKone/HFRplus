//
//  HFRSearchViewController.h
//  HFRplus
//
//  Created by Shasta on 04/11/10.
//

#import <UIKit/UIKit.h>
@class ASIFormDataRequest;


@interface HFRSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource> {
	NSMutableArray *tableData;

	UIView *disableViewOverlay;

    UITableView *theTableView;
    UISearchBar *theSearchBar;
	
	IBOutlet UIView *loadingView;
	IBOutlet UILabel *maintenanceView;

	ASIFormDataRequest *request;
	STATUS status;
	NSString *statusMessage;
}

@property(retain) NSMutableArray *tableData;
@property(retain) UIView *disableViewOverlay;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (retain, nonatomic) ASIFormDataRequest *request;
@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end
