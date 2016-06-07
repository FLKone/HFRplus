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

#import "MWPhotoBrowser.h"
#import "OrderedDictionary.h"

@class HTMLNode;
@class MessageDetailViewController;
@class ASIHTTPRequest;


@interface MessagesTableViewController : PageViewController <UIActionSheetDelegate, ParseMessagesOperationDelegate, AddMessageViewControllerDelegate, UIScrollViewDelegate, AlerteModoViewControllerDelegate> {
    
	UIWebView *messagesWebView;
    UIView *loadingView;
    UILabel *errorLabelView;
	UIView *overview;
	
    ASIHTTPRequest *request;

	NSString *topicAnswerUrl;
	BOOL errorReported;
    
	BOOL loaded; //to load data only once
	BOOL isLoading; //to check is refresh ON
	BOOL isRedFlagged; //to check is refresh ON
	BOOL isUnreadable; //to check is refresh ON
	NSString *isFavoritesOrRead; //to check is refresh ON

	BOOL isViewed; //to check if isViewed (bold & +1)
    BOOL isMP;
    BOOL isLive;

	OrderedDictionary *arrayData;

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
	NSString *curPostID;
	
    NSMutableArray *arrayActionsMessages;

	BOOL isAnimating; //to check is an animation is ON


    UIActionSheet *styleAlert;
    
    //Poll
    HTMLNode *pollNode;
    HTMLParser *pollParser;
    
    //Search
    UIView *searchBg;
    UIView *searchBox;
    
    UITextField *searchKeyword;
    UITextField *searchPseudo;
    UISwitch *searchFilter;
    UISwitch *searchFromFP;
    NSMutableDictionary *searchInputData;
    BOOL isSearchInstra;

    //Live
    BOOL firstLoad;
    BOOL gestureEnabled;
    BOOL paginationEnabled;
    BOOL autoUpdate;
    NSTimer *liveTimer;
    NSTimer *scrollCheckTimer;
    BOOL shouldAutoUpdate;
    NSDate *lastAutoUpDate;

}


@property (nonatomic, strong) IBOutlet UIWebView *messagesWebView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabelView;
@property (nonatomic, strong) IBOutlet UIView *overview;

@property (nonatomic, strong) NSString *topicAnswerUrl;
@property (nonatomic, strong, setter=setTopicName:) NSString *_topicName;


@property BOOL errorReported;

@property BOOL loaded;
@property BOOL isLoading;
@property BOOL isRedFlagged;
@property BOOL isUnreadable;
@property (nonatomic, strong) NSString *isFavoritesOrRead;

@property BOOL isViewed;
@property BOOL isMP;
@property BOOL isLive;

//Live
@property BOOL firstLoad;
@property BOOL gestureEnabled;
@property BOOL paginationEnabled;
@property BOOL autoUpdate;
@property BOOL shouldAutoUpdate;
@property (nonatomic, strong) NSDate *lastAutoUpDate;

@property (nonatomic, strong) NSTimer *liveTimer;
@property (nonatomic, strong) NSTimer *scrollCheckTimer;

@property (nonatomic, strong) OrderedDictionary *arrayData;

@property (nonatomic, strong) MessageDetailViewController *detailViewController;
@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;

@property (nonatomic, strong) UIActionSheet *styleAlert;

@property (nonatomic, strong) NSOperationQueue *queue; //v3

@property (nonatomic, strong) NSString *lastStringFlagTopic;
@property (nonatomic, strong) NSString *stringFlagTopic;
@property (nonatomic, strong) NSString *editFlagTopic;

@property (nonatomic, strong) NSMutableDictionary *arrayInputData;
@property (nonatomic, strong) UIToolbar *aToolbar;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) NSMutableArray *arrayAction;
@property (strong, nonatomic) NSString *curPostID;

@property BOOL isAnimating;

@property (nonatomic, strong) HTMLNode *pollNode;
@property (nonatomic, strong) HTMLParser *pollParser;

@property (nonatomic, strong) IBOutlet UIView *searchBg;
@property (nonatomic, strong) IBOutlet UIView *searchBox;

@property (nonatomic, strong) IBOutlet UITextField *searchKeyword;
@property (nonatomic, strong) IBOutlet UITextField *searchPseudo;
@property (nonatomic, strong) IBOutlet UISwitch *searchFilter;
@property (strong, nonatomic) IBOutlet UISwitch *searchFromFP;
@property (nonatomic, strong) NSMutableDictionary *searchInputData;
@property BOOL isSearchInstra;

@property (strong, nonatomic) NSMutableArray *arrayActionsMessages;

- (NSString*) topicName;

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
-(void)forceButtonMenu;

-(void)webViewDidFinishLoadDOM;

-(BOOL) canBeFavorite;
-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur;
-(NSString *) LireCookie:(NSString *)nom;
-(void) EffaceCookie:(NSString *)nom;

-(void)textQuote:(id)sender;
-(void)textQuoteBold:(id)sender;

- (IBAction)searchFilterChanged:(UISwitch *)sender;
- (IBAction)searchFromFPChanged:(UISwitch *)sender;
- (IBAction)searchPseudoChanged:(UITextField *)sender;
- (IBAction)searchKeywordChanged:(UITextField *)sender;
- (void)toggleSearch:(BOOL) active;
- (IBAction)searchNext:(UITextField *)sender;

-(void)newMessagesAutoAdded:(int)number;
-(void)stopTimer;
-(void)setupTimer:(int)sec;

@end
