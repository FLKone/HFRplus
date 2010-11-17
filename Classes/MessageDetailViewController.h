//
//  MessageDetailViewController.h
//  HFR+
//
//  Created by Lace on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewMessageViewController.h"

@class MessagesTableViewController;

@interface MessageDetailViewController : UIViewController <AddMessageViewControllerDelegate, UIActionSheetDelegate, UIWebViewDelegate> {
	IBOutlet UIWebView *messageView;
	IBOutlet UILabel *messageAuthor;
	IBOutlet UILabel *messageDate;
	IBOutlet UIImageView *authorAvatar;

	IBOutlet UILabel *messageTitle;

	NSString *messageTitleString;
	NSMutableArray *arrayData;
	int pageNumber;
	int curMsg;
	
	MessagesTableViewController *parent;
	
	UIColor *defaultTintColor;

	UIToolbar *toolbarBtn;
	UIBarButtonItem *quoteBtn;
	UIBarButtonItem *editBtn;
	UIBarButtonItem *actionBtn;	
	NSMutableArray *arrayAction;

}

@property (nonatomic, retain) IBOutlet UIWebView *messageView;
@property (nonatomic, retain) IBOutlet UILabel *messageAuthor;
@property (nonatomic, retain) IBOutlet UILabel *messageDate;
@property (nonatomic, retain) IBOutlet UIImageView *authorAvatar;
@property (nonatomic, retain) IBOutlet UILabel *messageTitle;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbarBtn;
@property (nonatomic, retain) UIBarButtonItem *quoteBtn;
@property (nonatomic, retain) UIBarButtonItem *editBtn;
@property (nonatomic, retain) UIBarButtonItem *actionBtn;
@property (nonatomic, retain) NSMutableArray *arrayAction;

@property (nonatomic, retain) NSString *messageTitleString;

@property (nonatomic, retain) NSMutableArray *arrayData;

@property (nonatomic, assign) MessagesTableViewController *parent;

@property (nonatomic, retain) UIColor *defaultTintColor;

@property int pageNumber;
@property int curMsg;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andContent:(LinkItem *)myItem;
-(void)QuoteMessage;
-(void)EditMessage;
-(void)ActionList;
	
@end
