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
    IBOutlet ForumCellView *__weak tmpCell;
    
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

@property (nonatomic, strong) IBOutlet UITableView *forumsTableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet ForumCellView *tmpCell;

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, strong) NSMutableArray *arrayNewData;
@property (nonatomic, strong) TopicsTableViewController *topicsTableViewController;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property STATUS status;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) NSMutableDictionary *metaDataList;
@property (nonatomic, strong) NSIndexPath *pressedIndexPath;
@property (nonatomic, strong) UIActionSheet *forumActionSheet;


-(void)loadDataInTableView:(NSData *)contentData;
-(void)reload:(BOOL)shake;
-(void)reload;
@end
