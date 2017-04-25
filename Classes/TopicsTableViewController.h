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

@interface TopicsTableViewController : PageViewController <AddMessageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate> {
	IBOutlet UITableView *topicsTableView;
	IBOutlet UIView *loadingView;

	NSString *forumName;

	NSString *forumBaseURL;
	NSString *forumFavorisURL;
	NSString *forumFlag1URL;
	NSString *forumFlag0URL;

	NSString *forumNewTopicUrl;

	NSMutableArray *arrayData;
    NSMutableArray *arrayNewData;


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
	
    UIActionSheet		*topicActionSheet;
    
    UISegmentedControl  *subCatSegmentedControl;
	TopicCellView *__weak tmpCell;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    
    id _popover;
    
    int selectedFlagIndex;
	
}

@property (nonatomic, weak) IBOutlet TopicCellView *tmpCell;

@property (nonatomic, strong) UIPickerView *myPickerView;
@property (nonatomic, strong) NSArray *pickerViewArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIActionSheet *topicActionSheet;

@property (nonatomic, strong) UISegmentedControl  *subCatSegmentedControl;
@property (nonatomic, strong) IBOutlet UITableView *topicsTableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;

@property (nonatomic, strong) NSString *forumName;

@property (nonatomic, strong) NSString *forumNewTopicUrl;


@property (nonatomic, strong) NSString *forumBaseURL;
@property (nonatomic, strong) NSString *forumFavorisURL;
@property (nonatomic, strong) NSString *forumFlag1URL;
@property (nonatomic, strong) NSString *forumFlag0URL;

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, strong) NSMutableArray *arrayNewData;
@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;

@property (nonatomic, strong) NSIndexPath *pressedIndexPath;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property (nonatomic, strong) UIImage *imageForUnselectedRow;
@property (nonatomic, strong) UIImage *imageForSelectedRow;
@property (nonatomic, strong) UIImage *imageForRedFlag;
@property (nonatomic, strong) UIImage *imageForYellowFlag;
@property (nonatomic, strong) UIImage *imageForBlueFlag;

@property STATUS status;
@property int selectedFlagIndex;

@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) id popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil flag:(int)flag;

-(void)loadDataInTableView:(NSData *)contentData;
-(void)reset;
-(void)shakeHappened:(ShakeView*)view;

-(void)showPicker:(id)sender;
- (CGRect)pickerFrameWithSize:(CGSize)size;
-(void)dismissActionSheet;
-(void)segmentFilterAction;

- (void)cancelFetchContent;
- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest;
- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest;
- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest;

- (void)chooseTopicPage;
- (void)newTopic;

- (void)setTopicViewed;
- (void)pushTopic;

-(void)test;

@end
