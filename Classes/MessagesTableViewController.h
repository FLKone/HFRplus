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
    UISlider *searchSliderPage;
    UILabel *searchSliderPageDesc;
    int searchPage;
    NSTimer *searchPageTimer;
    UIButton *searchPageFirst;
    UIButton *searchPageLast;
}


@property (nonatomic, retain) IBOutlet MessageWebView *messagesWebView;
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

@property (nonatomic, retain) IBOutlet UIView *searchKeyword;
@property (nonatomic, retain) IBOutlet UIView *searchPseudo;
@property (nonatomic, retain) IBOutlet UIView *searchFilter;
@property (nonatomic, retain) IBOutlet UIView *searchSliderPage;
@property (nonatomic, retain) IBOutlet UILabel *searchSliderPageDesc;
@property int searchPage;
@property (nonatomic, retain) NSTimer *searchPageTimer;
@property (nonatomic, retain) IBOutlet UIButton *searchPageFirst;
@property (nonatomic, retain) IBOutlet UIButton *searchPageLast;

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

- (IBAction)searchSliderChanged:(UISlider *)sender;
- (IBAction)searchSliderExit:(UISlider *)sender;
- (IBAction)searchSliderEntered:(UISlider *)sender;
- (IBAction)searchPageGoToFirst:(UIButton *)sender;
- (IBAction)searchPageGoToLast:(UIButton *)sender;

@end
