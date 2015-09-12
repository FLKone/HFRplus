//
//  ForumsTableViewController.h
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import <UIKit/UIKit.h>

@class TopicsTableViewController;
@class ASIHTTPRequest;
@class ForumCellView;

@interface ForumsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet UITableView *forumsTableView;
	IBOutlet UIView *loadingView;
    IBOutlet ForumCellView *tmpCell;
    
	NSMutableArray *arrayData;
	NSMutableArray *arrayNewData;
	ASIHTTPRequest *request;
	
	TopicsTableViewController *topicsTableViewController;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    
    //Meta data (order, subcat, default flag etc.)
    NSMutableDictionary *metaDataList;
    NSIndexPath *pressedIndexPath;
    UIActionSheet		*forumActionSheet;

}

@property (nonatomic, retain) IBOutlet UITableView *forumsTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, assign) IBOutlet ForumCellView *tmpCell;

@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, retain) NSMutableArray *arrayNewData;
@property (nonatomic, retain) TopicsTableViewController *topicsTableViewController;

@property (retain, nonatomic) ASIHTTPRequest *request;

@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (nonatomic, retain) NSMutableDictionary *metaDataList;
@property (nonatomic, retain) NSIndexPath *pressedIndexPath;
@property (nonatomic, retain) UIActionSheet *forumActionSheet;


-(void)loadDataInTableView:(NSData *)contentData;
-(void)reload:(BOOL)shake;
-(void)reload;
@end
