//
//  TopicsTableViewController.h
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@class MessagesTableViewController;
@class ASIHTTPRequest;
@class ShakeView;
@class TopicCellView;

#import "AddMessageViewController.h"
#import "NewMessageViewController.h"

@interface TopicsTableViewController : PageViewController <AddMessageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *topicsTableView;
	IBOutlet UIView *loadingView;

	NSString *forumName;

	NSString *forumBaseURL;
	NSString *forumFavorisURL;
	NSString *forumFlag1URL;
	NSString *forumFlag0URL;

	NSString *forumNewTopicUrl;

	NSMutableArray *arrayData;

	MessagesTableViewController *messagesTableViewController;

	//Gesture
	UISwipeGestureRecognizer *swipeLeftRecognizer;
	UISwipeGestureRecognizer *swipeRightRecognizer;
	
	NSIndexPath *pressedIndexPath;
	
	UIImage *imageForUnselectedRow;
	UIImage *imageForSelectedRow;
	UIImage *imageForRedFlag;
	UIImage *imageForYellowFlag;
	UIImage *imageForBlueFlag;

	ASIHTTPRequest *request;
	
	UIPickerView		*myPickerView;
	NSArray				*pickerViewArray;
	UIActionSheet		*actionSheet;
	
	TopicCellView *tmpCell;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    
    id _popover;
    
    int selectedFlagIndex;
	
}

@property (nonatomic, assign) IBOutlet TopicCellView *tmpCell;

@property (nonatomic, retain) UIPickerView *myPickerView;
@property (nonatomic, retain) NSArray *pickerViewArray;
@property (nonatomic, retain) UIActionSheet *actionSheet;

@property (nonatomic, retain) IBOutlet UITableView *topicsTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) NSString *forumName;

@property (nonatomic, retain) NSString *forumNewTopicUrl;


@property (nonatomic, retain) NSString *forumBaseURL;
@property (nonatomic, retain) NSString *forumFavorisURL;
@property (nonatomic, retain) NSString *forumFlag1URL;
@property (nonatomic, retain) NSString *forumFlag0URL;

@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, retain) MessagesTableViewController *messagesTableViewController;

@property (nonatomic, retain) NSIndexPath *pressedIndexPath;

@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRightRecognizer;

@property (retain, nonatomic) ASIHTTPRequest *request;

@property (nonatomic, retain) UIImage *imageForUnselectedRow;
@property (nonatomic, retain) UIImage *imageForSelectedRow;
@property (nonatomic, retain) UIImage *imageForRedFlag;
@property (nonatomic, retain) UIImage *imageForYellowFlag;
@property (nonatomic, retain) UIImage *imageForBlueFlag;

@property STATUS status;
@property int selectedFlagIndex;

@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (nonatomic, retain) id popover;

-(void)loadDataInTableView:(NSData *)contentData;
-(void)reset;
-(void)shakeHappened:(ShakeView*)view;

-(void)showPicker:(id)sender;
- (CGRect)pickerFrameWithSize:(CGSize)size;
-(void)dismissActionSheet;
-(void)segmentFilterAction;

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest;
- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest;
- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest;

- (void)chooseTopicPage;

- (void)setTopicViewed;
- (void)pushTopic;

@end
