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
	UITableView *favoritesTableView;
	UIView *loadingView;

    NSMutableArray *arrayNewData;

	MessagesTableViewController *messagesTableViewController;

	NSIndexPath *pressedIndexPath;

	ASIHTTPRequest *request;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;	
    
    UIActionSheet		*topicActionSheet;
    
    BOOL showAll;
}

@property (nonatomic, retain) IBOutlet UITableView *favoritesTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) UIActionSheet *topicActionSheet;

@property (nonatomic, retain) NSMutableArray *arrayNewData;

@property (nonatomic, retain) MessagesTableViewController *messagesTableViewController;

@property BOOL showAll;

@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

-(NSString*)wordAfterString:(NSString*)searchString inString:(NSString*)selfString;

@property (nonatomic, retain) NSIndexPath *pressedIndexPath;

@property (retain, nonatomic) ASIHTTPRequest *request;

-(void)loadDataInTableView:(NSData*)contentData;
-(void)reset;
-(void)reload:(BOOL)shake;
-(void)reload;

- (void)setTopicViewed;
- (void)pushTopic;

- (void)chooseTopicPage;

@end