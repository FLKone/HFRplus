//
//  MessagesTableViewController.h
//  HFRplus
//
//  Created by FLK on 07/07/10.
//
#import "HFRplusAppDelegate.h"

#import <UIKit/UIKit.h>
#import "PageViewController.h"

#import "ParseMessagesOperation.h"
#import "AddMessageViewController.h"

//#import "FormViewController.h"
//#import "EditFormView.h"
//#import "QuoteFormView.h"

#import "OptionsTopicViewController.h"

#import "QuoteMessageViewController.h"
#import "EditMessageViewController.h"
#import "NewMessageViewController.h"

#import "PhotoViewController.h"
#import "MWPhotoBrowser.h"

@class HTMLNode;
@class MessageDetailViewController;
@class ASIHTTPRequest;

@interface MessagesTableViewController : PageViewController <UIActionSheetDelegate, ParseMessagesOperationDelegate, AddMessageViewControllerDelegate, PhotoViewControllerDelegate, UIScrollViewDelegate> {
	UIWebView *messagesWebView;
	UIView *loadingView;
	UIView *overview;
	
	NSString *topicName;
	
	NSString *topicAnswerUrl;
	
	BOOL loaded; //to load data only once
	BOOL isLoading; //to check is refresh ON
	BOOL isRedFlagged; //to check is refresh ON
	BOOL isUnreadable; //to check is refresh ON
	NSString *isFavoritesOrRead; //to check is refresh ON

	BOOL isViewed; //to check if isViewed (bold & +1)

	
	NSMutableArray *arrayData;
	NSMutableArray *updatedArrayData;
	
    MessagesTableViewController *messagesTableViewController;
	MessageDetailViewController *detailViewController;
	
	//Gesture
	UISwipeGestureRecognizer *swipeLeftRecognizer;
	UISwipeGestureRecognizer *swipeRightRecognizer;
    UISwipeGestureRecognizer *singledualTap;
    
	//V3
	// the queue to run our "ParseOperation"
    NSOperationQueue		*queue;
	
	NSString * stringFlagTopic;
	NSString * editFlagTopic;
	
	//FormsVar
	NSMutableDictionary *arrayInputData;
	
	UIToolbar *aToolbar;
	NSMutableArray *arrayAction;
	int curPostID;
	
	BOOL isAnimating; //to check is an animation is ON

	NSDate *firstDate;
    
    UIActionSheet *styleAlert;    
}


@property (nonatomic, retain) IBOutlet UIWebView *messagesWebView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *overview;

@property (nonatomic, retain) NSString *topicAnswerUrl;
@property (nonatomic, retain) NSString *topicName;

@property (nonatomic, retain) NSDate *firstDate;

@property BOOL loaded;
@property BOOL isLoading;
@property BOOL isRedFlagged;
@property BOOL isUnreadable;
@property (nonatomic, retain) NSString *isFavoritesOrRead;

@property BOOL isViewed;

@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, retain) NSMutableArray *updatedArrayData;

@property (nonatomic, retain) MessageDetailViewController *detailViewController;
@property (nonatomic, retain) MessagesTableViewController *messagesTableViewController;

@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *singledualTap;

@property (nonatomic, retain) UIActionSheet *styleAlert;

@property (nonatomic, retain) NSOperationQueue *queue; //v3

@property (nonatomic, retain) NSString *stringFlagTopic;
@property (nonatomic, retain) NSString *editFlagTopic;

@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) UIToolbar *aToolbar;

@property (retain, nonatomic) ASIHTTPRequest *request;

@property (retain, nonatomic) NSMutableArray *arrayAction;
@property int curPostID;

@property BOOL isAnimating;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl;
- (void)optionsTopic:(id)sender;
- (void)answerTopic;
- (void)quoteMessage:(NSString *)quoteUrl;
- (void)editMessage:(NSString *)editUrl;

-(void)addDataInTableView;
-(void)loadDataInTableView:(HTMLParser *)myParser;

-(void)setupFastAnswer:(HTMLNode *)bodyNode;
-(void)setupPageToolbar:(HTMLNode *)bodyNode;

-(BOOL) canBeFavorite;
-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur;
-(NSString *) LireCookie:(NSString *)nom;
-(void)  EffaceCookie:(NSString *)nom;

@end
