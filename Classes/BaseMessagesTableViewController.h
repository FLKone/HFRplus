//
//  BaseMessagesTableViewController.h
//  HFRplus
//
//  Created by FLK on 06/06/2016.
//
//

// App
#import "HFRplusAppDelegate.h"

// Base
#import "PageViewController.h"

// Delegates
#import "ParseMessagesOperation.h"
#import "AddMessageViewController.h"
#import "AlerteModoViewController.h"

// Classes
#import "ASIHTTPRequest.h"
#import "OrderedDictionary.h"
#import "HTMLNode.h"
@class MessageDetailViewController;


@interface BaseMessagesTableViewController : PageViewController <UIActionSheetDelegate, ParseMessagesOperationDelegate, AddMessageViewControllerDelegate, UIScrollViewDelegate, AlerteModoViewControllerDelegate>
{
    UIWebView *messagesWebView;
    UIView *loadingView;
    UILabel *errorLabelView;

    ASIHTTPRequest *request;
    NSOperationQueue		*queue;
    OrderedDictionary *arrayData;
    NSString *topicAnswerUrl;

    BOOL isLoading; //to check is refresh ON
    BOOL isAnimating;
    BOOL loaded; //to load data only once
    BOOL isViewed; //to check if isViewed (bold & +1)
    BOOL errorReported;
    BOOL firstLoad;
    BOOL isMP;
    BOOL gestureEnabled;

    //Gesture
    UISwipeGestureRecognizer *swipeLeftRecognizer;
    UISwipeGestureRecognizer *swipeRightRecognizer;

    //Contextual
    NSMutableArray *arrayAction;
    NSString *curPostID;

    NSString *stringFlagTopic;
    NSString *lastStringFlagTopic; // used for splitView
    NSString *editFlagTopic;// used after editing

    //Options
    NSMutableArray *arrayActionsMessages;
    UIActionSheet *styleAlert;
    HTMLNode *pollNode;
    HTMLParser *pollParser;

    //Fast
    NSMutableDictionary *arrayInputData;
    BOOL isRedFlagged;
    BOOL isUnreadable;
    NSString *isFavoritesOrRead;

    id messagesTableViewController;
    MessageDetailViewController *detailViewController;


    //Search
    UIView *searchBg;
    UIView *searchBox;
    UITextField *searchKeyword;
    UITextField *searchPseudo;
    UISwitch *searchFilter;
    UISwitch *searchFromFP;
    NSMutableDictionary *searchInputData;
    BOOL isSearchIntra;
    BOOL isSearchIntraEnabled;
}

@property (nonatomic, strong, setter=setTopicName:) NSString *_topicName;

@property (nonatomic, strong) IBOutlet UIWebView *messagesWebView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabelView;

@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) NSOperationQueue *queue; //v3
@property (nonatomic, strong) OrderedDictionary *arrayData;
@property (nonatomic, strong) NSString *topicAnswerUrl;

@property BOOL isLoading;
@property BOOL isAnimating;
@property BOOL loaded;
@property BOOL isViewed;
@property BOOL errorReported;
@property BOOL firstLoad;
@property BOOL isMP;
@property BOOL gestureEnabled;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;

@property (nonatomic, strong) NSMutableArray *arrayAction;
@property (nonatomic, strong) NSString *curPostID;

@property (nonatomic, strong) NSString *stringFlagTopic;
@property (nonatomic, strong) NSString *lastStringFlagTopic;
@property (nonatomic, strong) NSString *editFlagTopic;

@property (nonatomic, strong) UIActionSheet *styleAlert;
@property (strong, nonatomic) NSMutableArray *arrayActionsMessages;
@property (nonatomic, strong) HTMLNode *pollNode;
@property (nonatomic, strong) HTMLParser *pollParser;

@property (nonatomic, strong) NSMutableDictionary *arrayInputData;
@property BOOL isRedFlagged;
@property BOOL isUnreadable;
@property (nonatomic, strong) NSString *isFavoritesOrRead;

@property (nonatomic, strong) id messagesTableViewController;
@property (nonatomic, strong) MessageDetailViewController *detailViewController;

@property (nonatomic, strong) IBOutlet UIView *searchBg;
@property (nonatomic, strong) IBOutlet UIView *searchBox;
@property (nonatomic, strong) IBOutlet UITextField *searchKeyword;
@property (nonatomic, strong) IBOutlet UITextField *searchPseudo;
@property (nonatomic, strong) IBOutlet UISwitch *searchFilter;
@property (strong, nonatomic) IBOutlet UISwitch *searchFromFP;
@property (nonatomic, strong) NSMutableDictionary *searchInputData;
@property BOOL isSearchIntra;
@property BOOL isSearchIntraEnabled;


- (IBAction)searchFilterChanged:(UISwitch *)sender;
- (IBAction)searchFromFPChanged:(UISwitch *)sender;
- (IBAction)searchPseudoChanged:(UITextField *)sender;
- (IBAction)searchKeywordChanged:(UITextField *)sender;
- (void)toggleSearch:(BOOL) active;
- (IBAction)searchNext:(UITextField *)sender;

-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur;
-(NSString *) LireCookie:(NSString *)nom;
-(void) EffaceCookie:(NSString *)nom;

-(void)textQuote:(id)sender;
-(void)textQuoteBold:(id)sender;

- (NSString*) topicName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl;
- (void)optionsTopic:(id)sender;
- (void)answerTopic;
- (void)quoteMessage:(NSString *)quoteUrl;
- (void)editMessage:(NSString *)editUrl;

-(void)goToPagePosition:(NSString *)position;
-(void)goToPagePositionTop;
-(void)goToPagePositionBottom;

-(HTMLNode *)loadDataInTableView:(HTMLParser *)myParser;
-(void)setupFastAnswer:(HTMLNode *)bodyNode;

- (void)editMenuHidden:(id)sender;
- (BOOL)canBeFavorite;

-(void)searchNewMessages:(int)from;
- (NSString*)generateHTMLToolbar;

@end
