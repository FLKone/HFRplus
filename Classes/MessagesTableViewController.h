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

#import "QuoteMessageViewController.h"
#import "EditMessageViewController.h"
#import "NewMessageViewController.h"
#import "DeleteMessageViewController.h"
#import "AlerteModoViewController.h"

#import "PhotoViewController.h"
#import "MWPhotoBrowser.h"

@class HTMLNode;
@class MessageDetailViewController;
@class ASIHTTPRequest;

#import "MessageWebView.h"

@interface MessagesTableViewController : PageViewController <UIActionSheetDelegate, ParseMessagesOperationDelegate, AddMessageViewControllerDelegate, PhotoViewControllerDelegate, UIScrollViewDelegate> {
    
	MessageWebView *messagesWebView;
	UIView *loadingView;
	UIView *overview;
	

	
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
    
	//V3
	// the queue to run our "ParseOperation"
    NSOperationQueue		*queue;
	
	NSString * lastStringFlagTopic;
	NSString * stringFlagTopic;
	NSString * editFlagTopic;
	
	//FormsVar
	NSMutableDictionary *arrayInputData;
	
	UIToolbar *aToolbar;
	NSMutableArray *arrayAction;
	int curPostID;
	
    NSMutableArray *arrayActionsMessages;

	BOOL isAnimating; //to check is an animation is ON

	NSDate *firstDate;
    
    UIActionSheet *styleAlert;
    
    //Poll
    NSString *pollNode;
    
    //Search
    UIView *searchBg;
    UIView *searchBox;
    
    UITextField *searchKeyword;
    UITextField *searchPseudo;
    UISwitch *searchFilter;
    UISwitch *searchFromFP;
    NSMutableDictionary *searchInputData;
    BOOL isSearchInstra;
}


@property (nonatomic, retain) IBOutlet MessageWebView *messagesWebView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *overview;

@property (nonatomic, retain) NSString *topicAnswerUrl;
@property (nonatomic, retain, setter=setTopicName:) NSString *_topicName;

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

@property (nonatomic, retain) UIActionSheet *styleAlert;

@property (nonatomic, retain) NSOperationQueue *queue; //v3

@property (nonatomic, retain) NSString *lastStringFlagTopic;
@property (nonatomic, retain) NSString *stringFlagTopic;
@property (nonatomic, retain) NSString *editFlagTopic;

@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) UIToolbar *aToolbar;

@property (retain, nonatomic) ASIHTTPRequest *request;

@property (retain, nonatomic) NSMutableArray *arrayAction;
@property int curPostID;

@property BOOL isAnimating;

@property (nonatomic, retain) NSString *pollNode;

@property (nonatomic, retain) IBOutlet UIView *searchBg;
@property (nonatomic, retain) IBOutlet UIView *searchBox;

@property (nonatomic, retain) IBOutlet UITextField *searchKeyword;
@property (nonatomic, retain) IBOutlet UITextField *searchPseudo;
@property (nonatomic, retain) IBOutlet UISwitch *searchFilter;
@property (retain, nonatomic) IBOutlet UISwitch *searchFromFP;
@property (nonatomic, retain) NSMutableDictionary *searchInputData;
@property BOOL isSearchInstra;

@property (retain, nonatomic) NSMutableArray *arrayActionsMessages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl;
- (void)optionsTopic:(id)sender;
- (void)answerTopic;
- (void)quoteMessage:(NSString *)quoteUrl;
- (void)editMessage:(NSString *)editUrl;

-(void)markUnread;
-(void)goToPagePosition:(NSString *)position;
-(void)goToPagePositionTop;
-(void)goToPagePositionBottom;

-(void)loadDataInTableView:(HTMLParser *)myParser;

-(void)setupFastAnswer:(HTMLNode *)bodyNode;
-(void)setupPageToolbar:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser;
-(void)setupPoll:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser;

-(void)searchNewMessages:(int)from;
-(void)searchNewMessages;
-(void)fetchContentinBackground:(id)from;

-(void)webViewDidFinishLoadDOM;

-(BOOL) canBeFavorite;
-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur;
-(NSString *) LireCookie:(NSString *)nom;
-(void) EffaceCookie:(NSString *)nom;

- (IBAction)searchFilterChanged:(UISwitch *)sender;
- (IBAction)searchFromFPChanged:(UISwitch *)sender;
- (IBAction)searchPseudoChanged:(UITextField *)sender;
- (IBAction)searchKeywordChanged:(UITextField *)sender;
- (void)toggleSearch:(BOOL) active;
- (IBAction)searchNext:(UITextField *)sender;


@end
