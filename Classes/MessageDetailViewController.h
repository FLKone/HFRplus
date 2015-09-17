//
//  MessageDetailViewController.h
//  HFRplus
//
//  Created by FLK on 10/07/10.
//

#import <UIKit/UIKit.h>

#import "NewMessageViewController.h"

@class MessagesTableViewController;

@interface MessageDetailViewController : UIViewController <AddMessageViewControllerDelegate, UIActionSheetDelegate, UIWebViewDelegate> {
	IBOutlet UIWebView *messageView;
	IBOutlet UILabel *messageAuthor;
	IBOutlet UILabel *messageDate;
	IBOutlet UIImageView *authorAvatar;
    IBOutlet UIView *messageAvatar;

	IBOutlet UILabel *messageTitle;

	NSString *messageTitleString;
	NSMutableArray *arrayData;
	int pageNumber;
	int curMsg;
	
	MessagesTableViewController *__weak parent;
    MessagesTableViewController *messagesTableViewController;

	UIColor *defaultTintColor;

	UIToolbar *toolbarBtn;
	UIBarButtonItem *quoteBtn;
	UIBarButtonItem *editBtn;
	UIBarButtonItem *actionBtn;	
	NSMutableArray *arrayAction;
    
    UIActionSheet *styleAlert;
    
}

@property (nonatomic, strong) IBOutlet UIWebView *messageView;
@property (nonatomic, strong) IBOutlet UILabel *messageAuthor;
@property (nonatomic, strong) IBOutlet UILabel *messageDate;
@property (nonatomic, strong) IBOutlet UIImageView *authorAvatar;
@property (nonatomic, strong) IBOutlet UILabel *messageTitle;
@property (nonatomic, strong) IBOutlet UIView *messageAvatar;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbarBtn;
@property (nonatomic, strong) UIBarButtonItem *quoteBtn;
@property (nonatomic, strong) UIBarButtonItem *editBtn;
@property (nonatomic, strong) UIBarButtonItem *actionBtn;
@property (nonatomic, strong) NSMutableArray *arrayAction;

@property (nonatomic, strong) UIActionSheet *styleAlert;

@property (nonatomic, strong) NSString *messageTitleString;

@property (nonatomic, strong) NSMutableArray *arrayData;

@property (nonatomic, weak) MessagesTableViewController *parent;
@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;

@property (nonatomic, strong) UIColor *defaultTintColor;

@property int pageNumber;
@property int curMsg;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andContent:(LinkItem *)myItem;
-(void)QuoteMessage;
-(void)EditMessage;
-(void)ActionList:(id)sender;
	
@end
