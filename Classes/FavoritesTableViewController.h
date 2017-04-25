//
//  FavoritesTableViewController.h
//  HFRplus
//
//  Created by FLK on 05/07/10.
//

#import <UIKit/UIKit.h>

@class MessagesTableViewController;
@class ASIHTTPRequest;

@interface FavoritesTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
	IBOutlet UITableView *favoritesTableView;
	IBOutlet UIView *loadingView;

    NSMutableArray *arrayData;
    NSMutableArray *arrayNewData;
    NSMutableArray *arrayCategories;

	MessagesTableViewController *messagesTableViewController;

	NSIndexPath *pressedIndexPath;

	ASIHTTPRequest *request;
	
    bool reloadOnAppear;
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;	
    
    UIActionSheet		*topicActionSheet;
    
    BOOL showAll;
}

@property (nonatomic, strong) IBOutlet UITableView *favoritesTableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;

@property (nonatomic, strong) UIActionSheet *topicActionSheet;

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, strong) NSMutableArray *arrayNewData;
@property (nonatomic, strong) NSMutableArray *arrayCategories;

@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;

@property BOOL showAll;

@property bool reloadOnAppear;
@property STATUS status;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

-(NSString*)wordAfterString:(NSString*)searchString inString:(NSString*)selfString;

@property (nonatomic, strong) NSIndexPath *pressedIndexPath;

@property (strong, nonatomic) ASIHTTPRequest *request;

-(void)loadDataInTableView:(NSData*)contentData;
-(void)reset;
-(void)reload:(BOOL)shake;
-(void)reload;

- (void)setTopicViewed;
- (void)pushTopic;

- (void)chooseTopicPage;

@end