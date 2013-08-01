//
//  ForumsTableViewController.h
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class TopicsTableViewController;
@interface ForumsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate> {
	IBOutlet HFRTableView *forumsTableView;
	IBOutlet UIView *loadingView;

	NSMutableArray *arrayData;
	ASIHTTPRequest *request;
	
	TopicsTableViewController *topicsTableViewController;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;	
}

@property (nonatomic, retain) IBOutlet HFRTableView *forumsTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, retain) TopicsTableViewController *topicsTableViewController;

@property (retain, nonatomic) ASIHTTPRequest *request;

@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

-(void)loadDataInTableView:(NSData *)contentData;
-(void)reload:(BOOL)shake;
-(void)reload;
@end
