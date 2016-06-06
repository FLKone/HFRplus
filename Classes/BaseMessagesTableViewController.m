//
//  BaseMessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 06/06/2016.
//
//

#import "BaseMessagesTableViewController.h"
#import "MessagesTableViewController.h"

#import "ParseMessagesOperation.h"



#import "QuoteMessageViewController.h"
#import "EditMessageViewController.h"
#import "NewMessageViewController.h"
#import "DeleteMessageViewController.h"

#import "MWPhotoBrowser.h"

#import "MessageDetailViewController.h"
#import "TopicsTableViewController.h"
#import "PollTableViewController.h"

#import "UIWebView+Tools.h"

#import "RangeOfCharacters.h"
#import "NSData+Base64.h"

#import "RegexKitLite.h"
#import "HTMLParser.h"
#import "ASIFormDataRequest.h"

#import "ASIDownloadCache.h"

#import "LinkItem.h"
#import <CommonCrypto/CommonDigest.h>

#import "ProfilViewController.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "BlackList.h"

@implementation BaseMessagesTableViewController

@synthesize _topicName;
@synthesize loadingView, errorLabelView, messagesWebView;
@synthesize request, queue, arrayData, topicAnswerUrl;
@synthesize isLoading, isAnimating, loaded, isViewed, errorReported, firstLoad, isMP, gestureEnabled;
@synthesize swipeLeftRecognizer, swipeRightRecognizer;
@synthesize arrayAction, curPostID;
@synthesize editFlagTopic, stringFlagTopic, lastStringFlagTopic;
@synthesize arrayActionsMessages, styleAlert, pollNode, pollParser;
@synthesize arrayInputData;
@synthesize isRedFlagged, isUnreadable, isFavoritesOrRead;
@synthesize messagesTableViewController, detailViewController;
@synthesize searchBg, searchBox, searchKeyword, searchPseudo, searchFilter, searchFromFP, searchInputData, isSearchIntra, isSearchIntraEnabled;

- (void)setTopicName:(NSString *)n {
    _topicName = [n filterTU];
}

//Getter method
- (NSString*) topicName {
    return _topicName;
}

#pragma mark -
#pragma mark Data lifecycle

- (void)setProgress:(float)newProgress{
    //NSLog(@"Progress %f%", newProgress*100);
}

- (void)cancelFetchContent
{
    [self.request cancel];
    [self setRequest:nil];
}

- (void)fetchContent:(int)from
{

    //self.firstDate = [NSDate date];
    self.errorReported = NO;
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
    //self.currentUrl = @"/forum2.php?config=hfr.inc&cat=25&post=1711&page=301&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t530526";


    //self.currentUrl = @"/forum2.php?config=hfr.inc&cat=25&post=5925&page=1&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t535660";

    //self.currentUrl = @"/forum2.php?config=hfr.inc&cat=25&subcat=525&post=5145&page=87&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t540188";

    //NSLog(@"URL %@", [self currentUrl]);

    //NSLog(@"[self currentUrl] %@", [self currentUrl]);
    //NSLog(@"[self stringFlagTopic] %@", [self stringFlagTopic]);

    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]]]];
    [request setDelegate:self];
    [request setShowAccurateProgress:YES];

    //[request setCachePolicy:ASIReloadIfDifferentCachePolicy];
    //[request setDownloadCache:[ASIDownloadCache sharedCache]];

    [request setDownloadProgressDelegate:self];

    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];

    if (self.swipeLeftRecognizer) [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
    if (self.swipeRightRecognizer) [self.view removeGestureRecognizer:self.swipeRightRecognizer];

    if ([NSThread isMainThread]) {
        [self.messagesWebView setHidden:YES];
    }

    //NSLog(@"from %d", from);

    [self.errorLabelView setHidden:YES];

    if(from == kNewMessageFromNext) self.stringFlagTopic = @"#bas";
    if(from != kNewMessageFromUpdate) self.firstLoad = YES;

    switch (from) {
        case kNewMessageFromShake:
        case kNewMessageFromUpdate:
        case kNewMessageFromEditor:
            //NSLog(@"hidden");
            [self.loadingView setHidden:YES];
            break;
        default:
            //NSLog(@"not hidden");
            [self.loadingView setHidden:NO];
            [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
            break;
    }

    [request startAsynchronous];
}


- (void)fetchContent
{
    [self fetchContent:kNewMessageFromUnkwn];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    //--
    //NSLog(@"fetchContentStarted");

    if (![self.currentUrl isEqualToString:[theRequest.url.absoluteString stringByReplacingOccurrencesOfString:kForumURL withString:@""]]) {
        //NSLog(@"not equal ==");
        self.currentUrl = [theRequest.url.absoluteString stringByReplacingOccurrencesOfString:kForumURL withString:@""];
    }

}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    //NSLog(@"fetchContentComplete");

    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];

    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //

    //MaJ de la puce MP
    if (!self.isViewed && self.isMP) {
        //NSLog(@"pas lu");
        [[HFRplusAppDelegate sharedAppDelegate] readMPBadge];
        self.isViewed = YES;
    }
    //MaJ de la puce MP

    //NSLog(@"%@", [request responseString]);

    ParseMessagesOperation *parser = [[ParseMessagesOperation alloc] initWithData:[request responseData] index:0 reverse:self.firstLoad delegate:self];

    [queue addOperation:parser]; // this will start the "ParseOperation"
    [self cancelFetchContent];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{

    [self.loadingView setHidden:YES];

    //NSLog(@"theRequest.error %@", theRequest.error);
    //NSLog(@"theRequest.url %@", theRequest.url);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
                                                   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
    
    if (self.firstLoad) {
        [alert setTag:667];
    }
    else {
        [alert setTag:6677];
    }
    
    [alert show];
    
    [self cancelFetchContent];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    NSLog(@"viewDidUnload Base Messages Table View");

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;

    self.loadingView = nil;
    self.errorLabelView = nil;

    [self.messagesWebView stopLoading];
    self.messagesWebView.delegate = nil;
    self.messagesWebView = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [super viewDidUnload];


}


- (void)dealloc {
    NSLog(@"dealloc Messages Table View");

    [self viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appInBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appInForeground" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VisibilityChanged" object:nil];

    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }

    [self.queue cancelAllOperations];

    [request cancel];
    [request setDelegate:nil];

    self.topicName = nil;


    //[self.arrayData removeAllObjects];
    self.arrayData = nil;
    
    
    
}

#pragma mark -
#pragma mark View lifecycle management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        //NSLog(@"init %@", theTopicUrl);
        self.currentUrl = [theTopicUrl copy];
        self.loaded = NO;
        self.isViewed = YES;

        self.errorReported = NO;
        self.gestureEnabled = YES;
        self.firstLoad = YES;
        self.isMP = NO;
    }
    return self;
}

- (void)viewDidLoad {
    //NSLog(@"viewDidLoad %@", self.topicName);

    [super viewDidLoad];
    
    self.isAnimating = NO;

    self.title = self.topicName;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisibilityChanged:) name:@"VisibilityChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTextSizeDidChange) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }


    // fond blanc WebView
    [self.messagesWebView hideGradientBackground];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.messagesWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
    else
    {
        [self.messagesWebView setBackgroundColor:[UIColor whiteColor]];
    }

    self.arrayAction = [[NSMutableArray alloc] init];
    self.arrayActionsMessages = [[NSMutableArray alloc] init];

    self.arrayData = [[OrderedDictionary alloc] init];

    self.arrayInputData = [[NSMutableDictionary alloc] init];
    self.editFlagTopic = [[NSString	alloc] init];
    self.stringFlagTopic = [[NSString	alloc] init];
    self.lastStringFlagTopic = [[NSString	alloc] init];

    self.isFavoritesOrRead = [[NSString	alloc] init];
    self.isUnreadable = NO;
    self.curPostID = @"";


    [self setEditFlagTopic:nil];
    [self setStringFlagTopic:@""];

    [self fetchContent];
    [self editMenuHidden:nil];
    [self forceButtonMenu];

}

- (void)viewWillDisappear:(BOOL)animated {
    //NSLog(@"viewWillDisappear");

    [super viewWillDisappear:animated];
    self.isAnimating = YES;


}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"viewDidAppear");

    [super viewDidAppear:animated];
    self.isAnimating = NO;
    
}

-(void)forceButtonMenu {
    if ([self.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {

        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;

    }
    else {
        UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];

        [navItem setLeftBarButtonItem:((SplitViewController *)self.splitViewController).mybarButtonItem animated:YES];
        [navItem setLeftItemsSupplementBackButton:YES];
    }
}


-(void)showPoll {

    PollTableViewController *pollVC = [[PollTableViewController alloc] initWithPollNode:self.pollNode andParser:self.pollParser];
    pollVC.delegate = self;

    // Set options
    pollVC.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)

    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:pollVC];
    //nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentModalViewController:nc animated:YES];


    //[self.navigationController pushViewController:browser animated:YES];


}

-(void)markUnread {
    ASIHTTPRequest  *delrequest =
    [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, self.isFavoritesOrRead]]];
    //delete

    [delrequest startSynchronous];

    //NSLog(@"arequest: %@", [arequest url]);

    if (delrequest) {
        if ([delrequest error]) {
            //NSLog(@"error: %@", [[arequest error] localizedDescription]);
        }
        else if ([delrequest responseString])
        {
            //NSLog(@"responseString: %@", [arequest responseString]);

            //[self reload];
            [[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] popViewControllerAnimated:YES];
            [(TopicsTableViewController *)[[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] visibleViewController] fetchContent];
        }
    }
    //NSLog(@"nonlu %@", self.isFavoritesOrRead);
}



#pragma mark -
#pragma mark Webview lifecycle

- (NSString *) userTextSizeDidChange {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_text"] isEqualToString:@"sys"]) {
        if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
            CGFloat userFontSize = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody].pointSize;
            userFontSize = floorf(userFontSize*0.90);
            NSString *script = [NSString stringWithFormat:@"$('.message .content .right').css('cssText', 'font-size:%fpx !important');", userFontSize];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right table.code *').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right p.editedhfrlink').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];

            [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];

            return [NSString stringWithFormat:@".message .content .right { font-size:%fpx !important; }", userFontSize];

            //NSLog(@"userFontSize %@", script);
        }
    }

    return @"";

}

-(void)goToPagePosition:(NSString *)position{
    NSString *script;

    if ([position isEqualToString:@"top"])
        script = @"$('html, body').animate({scrollTop:0}, 'slow');";
    else if ([position isEqualToString:@"bottom"])
        script = @"$('html, body').animate({scrollTop:$(document).height()}, 'slow');";
    else {
        script = @"";
    }

    [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
}

-(void)goToPagePositionTop{
    [self goToPagePosition:@"top"];
}
-(void)goToPagePositionBottom{
    [self goToPagePosition:@"bottom"];
}


- (void)didSelectMessage:(NSString *)selectedPostID
{

    NSLog(@"selectedPostID %@", selectedPostID);

    {
        // Navigation logic may go here. Create and push another view controller.

        if (self.detailViewController == nil) {
            MessageDetailViewController *aView = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewControllerv2" bundle:nil];
            self.detailViewController = aView;
        }


        // ...
        // Pass the selected object to the new view controller.
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                         style: UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }

        ///===
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

        label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
        //label.frame = CGRectMake(0, 0, 500, self.navigationBar.frame.size.height - 4);

        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //

        [label setAdjustsFontSizeToFitWidth:YES];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByTruncatingMiddle];

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [label setFont:[UIFont boldSystemFontOfSize:13.0]];
            }
            else {
                [label setFont:[UIFont boldSystemFontOfSize:17.0]];
            }
        }
        else
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [label setTextColor:[UIColor whiteColor]];
                label.shadowColor = [UIColor darkGrayColor];
                [label setFont:[UIFont boldSystemFontOfSize:13.0]];
                label.shadowOffset = CGSizeMake(0.0, -1.0);


            }
            else {
                [label setTextColor:[UIColor colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00]];
                label.shadowColor = [UIColor whiteColor];
                [label setFont:[UIFont boldSystemFontOfSize:19.0]];
                label.shadowOffset = CGSizeMake(0.0, 0.5f);

            }
        }





        [label setNumberOfLines:0];

        [label setText:[NSString stringWithFormat:@"Page : %d — %lu/%lu", self.pageNumber, [self.arrayData indexForKey:selectedPostID] + 1, (unsigned long)arrayData.count]];

        [self.detailViewController.navigationItem setTitleView:label];
        ///===

        //setup the URL
        //detailViewController.topicName = [[arrayData objectAtIndex:indexPath.row] name];

        //NSLog(@"push message details");
        // andContent:[arrayData objectAtIndex:indexPath.section]

        self.detailViewController.currentPostID = selectedPostID;
        self.detailViewController.pageNumber = self.pageNumber;
        self.detailViewController.parent = self;
        self.detailViewController.messageTitleString = self.topicName;

        [self.navigationController pushViewController:detailViewController animated:YES];

    }
}

- (void) didSelectImage:(NSString *)selectedPostID withUrl:(NSString *)selectedURL {
    if (self.isAnimating) {
        return;
    }

    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[[arrayData objectForKey:selectedPostID] toHTML] error:NULL];
    HTMLNode * msgNode = [myParser doc]; //Find the body tag

    NSArray * tmpImageArray =  [msgNode findChildrenWithAttribute:@"class" matchingName:@"hfrplusimg" allowPartial:NO];
    //NSLog(@"%d", [tmpImageArray count]);

    NSMutableArray * imageArray = [[NSMutableArray alloc] init];
    int selectedIndex = 0;

    for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
        //NSLog(@"======\nalt %@", [imgNode getAttributeNamed:@"alt"]);
        //NSLog(@"longdesc %@", [imgNode getAttributeNamed:@"longdesc"]);

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/"]]]];
        else
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/preview/"]]]];


        if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
            selectedIndex = [imageArray count] - 1;
        }

        /*

         [imageArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"alt"], [imgNode getAttributeNamed:@"longdesc"], nil]  forKeys:[NSArray arrayWithObjects:@"alt", @"longdesc", nil]]];
         if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
         selectedIndex = [imageArray count] - 1;
         }
         */

    }

    //NSLog(@"selectedIndex %d", selectedIndex);
    // Create the root view controller for the navigation controller
    // The new view controller configures a Cancel and Done button for the
    // navigation bar.


    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:imageArray];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:selectedIndex]; // Example: allows second image to be presented first
    // Present
    
    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    
    
    //[self.navigationController pushViewController:browser animated:YES];
    
}



#pragma mark -
#pragma mark OptionsTopic

-(void)optionsTopic:(id)sender
{

    [self.arrayActionsMessages removeAllObjects];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if(self.topicAnswerUrl.length > 0)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"answerTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_firstpage   = [defaults boolForKey:@"actionsmesages_firstpage"];
    if(actionsmesages_firstpage)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Première page", @"firstPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_lastpage    = [defaults boolForKey:@"actionsmesages_lastpage"];
    if(actionsmesages_lastpage)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière page", @"lastPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_lastanswer  = [defaults boolForKey:@"actionsmesages_lastanswer"];
    if(actionsmesages_lastanswer)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière réponse", @"lastAnswer", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_pagenumber  = [defaults boolForKey:@"actionsmesages_pagenumber"];
    if(actionsmesages_pagenumber && ([self lastPageNumber] > [self firstPageNumber]))
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Page Numéro...", @"choosePage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_toppage     = [defaults boolForKey:@"actionsmesages_toppage"];
    if(actionsmesages_toppage)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Haut de la page", @"goToPagePositionTop", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_bottompage  = [defaults boolForKey:@"actionsmesages_bottompage"];
    if(actionsmesages_bottompage)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Bas de la page", @"goToPagePositionBottom", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_poll  = [defaults boolForKey:@"actionsmesages_poll"];
    if(actionsmesages_poll && self.pollNode)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Sondage", @"showPoll", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    BOOL actionsmesages_unread      = [defaults boolForKey:@"actionsmesages_unread"];
    if(actionsmesages_unread && self.isUnreadable)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Marquer comme non lu", @"markUnread", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    if (self.arrayActionsMessages.count == 0) {
        return;
    }

    [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Rechercher", @"searchTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.parentViewController isMemberOfClass:[UINavigationController class]]) {

        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Navigateur✚", @"fullScreen", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    }
    //UIActionSheet *styleAlert;


    /*NSMutableArray *optionsList = [NSMutableArray arrayWithObjects:@"Première page", @"Dernière page", nil];

     if(topicAnswerUrl.length > 0) {
     [optionsList addObject:@"Répondre"];
     }

     if (self.isUnreadable) {
     [optionsList addObject:@"Marquer comme non lu"];
     }


     */
    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:styleAlert.numberOfButtons-1 animated:YES];
        return;
    }
    else {
        styleAlert = [[UIActionSheet alloc] init];
    }



    //styleAlert = [[UIActionSheet alloc] init];
    styleAlert.delegate = self;

    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    for( NSDictionary *dico in arrayActionsMessages)
        [styleAlert addButtonWithTitle:[dico valueForKey:@"title"]];

    [styleAlert addButtonWithTitle:@"Annuler"];
    styleAlert.cancelButtonIndex = styleAlert.numberOfButtons-1;

    // use the same style as the nav bar
    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    [styleAlert showFromBarButtonItem:sender animated:YES];

    //[styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
    //[styleAlert release];
    
}


-(void)answerTopic
{

    while (self.isAnimating) {
        //NSLog(@"isAnimating");
        //return;
    }
    //NSLog(@"isOK");

    HFRNavigationController *navigationController;

    {
        NewMessageViewController *addMessageViewController = [[NewMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
        addMessageViewController.delegate = self;
        [addMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", kForumURL, topicAnswerUrl]];
        addMessageViewController.title = @"Nouv. Réponse";

        navigationController = [[HFRNavigationController alloc]
                                initWithRootViewController:addMessageViewController];
    }


    // Create the navigation controller and present it modally.


    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.

    //[[HFR_AppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", topicAnswerUrl]];

    //[[UIApplication sharedApplication] open-URL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]];

    /*
     HFR_AppDelegate *mainDelegate = (HFR_AppDelegate *)[[UIApplication sharedApplication] delegate];
     [[mainDelegate rootController] setSelectedIndex:3];
     [[(BrowserViewController *)[[mainDelegate rootController] selectedViewController] webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]]];
     */
}



#pragma mark -
#pragma mark sharedMenuController management


-(void)actionFavoris:(NSString *)selectedPostID {


    ASIHTTPRequest  *aRequest =
    [[ASIHTTPRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [[self.arrayData objectForKey:selectedPostID] addFlagUrl]]]];


    [aRequest setStartedBlock:^{
        //alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ajout aux favoris en cours..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        //[alert show];
    }];

    __weak ASIHTTPRequest*aRequest_ = aRequest;

    [aRequest setCompletionBlock:^{
        NSString *responseString = [aRequest_ responseString];
        responseString = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        NSString *regExMsg = @".*<div class=\"hop\">([^<]+)</div>.*";
        NSPredicate *regExErrorPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExMsg];
        BOOL isRegExMsg = [regExErrorPredicate evaluateWithObject:responseString];

        if (isRegExMsg) {
            //KO
            //NSLog(@"%@", [responseString stringByMatching:regExMsg capture:1L]);
            //          usleep(1000000);
            //            [alert dismissWithClickedButtonIndex:0 animated:NO];
            //            [alert dismissWithClickedButtonIndex:0 animated:NO];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[responseString stringByMatching:regExMsg capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                           delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            alert.tag = 6666;


            [alert show];

            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

            // Adjust the indicator so it is up a few pixels from the bottom of the alert
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            NSLog(@"Show Alerte");
        }
    }];

    [aRequest setFailedBlock:^{
        //[alert dismissWithClickedButtonIndex:0 animated:0];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:[[aRequest_ error] localizedDescription]
                                                       delegate:self cancelButtonTitle:@":(" otherButtonTitles: nil];
        alert.tag = 666;

        [alert show];
    }];

    [aRequest startSynchronous];

}
-(void)actionProfil:(NSString *)selectedPostID {

    ProfilViewController *profilVC = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil andUrl:[[arrayData objectForKey:selectedPostID] urlProfil]];

    // Set options
    profilVC.wantsFullScreenLayout = YES;

    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:profilVC];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentModalViewController:nc animated:YES];



}
-(void)actionLink:(NSString *)selectedPostID {

    NSLog("actionLink URL = %@%@#%@", kForumURL, self.currentUrl, [[arrayData objectForKey:selectedPostID] postID]);


    //Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"actionLink URL = %@%@#%@", kForumURL, self.currentUrl, [[arrayData objectForKey:selectedPostID] postID]];


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Lien copié dans le presse-papiers"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    alert.tag = kAlertPasteBoardOK;


    [alert show];

}

-(void) actionAlerter:(NSString *)selectedPostID {
    NSLog(@"actionAlerter %@", selectedPostID);
    if (self.isAnimating) {
        return;
    }

    NSString *alertUrl = [NSString stringWithFormat:@"%@%@", kForumURL, [[arrayData objectForKey:selectedPostID] urlAlert]];

    AlerteModoViewController *alerteMessageViewController = [[AlerteModoViewController alloc]
                                                             initWithNibName:@"AlerteModoViewController" bundle:nil];
    alerteMessageViewController.delegate = self;
    [alerteMessageViewController setUrl:alertUrl];

    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:alerteMessageViewController];

    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];



}
-(void) actionSupprimer:(NSString *)selectedPostID {
    NSLog(@"actionSupprimer %@", selectedPostID);
    if (self.isAnimating) {
        return;
    }

    NSString *editUrl = [NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectForKey:selectedPostID] urlEdit] decodeSpanUrlFromString]];
    NSLog(@"DEL editUrl = %@", editUrl);

    DeleteMessageViewController *delMessageViewController = [[DeleteMessageViewController alloc]
                                                             initWithNibName:@"AddMessageViewController" bundle:nil];
    delMessageViewController.delegate = self;
    [delMessageViewController setUrlQuote:editUrl];

    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:delMessageViewController];

    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

}

-(void) actionBL:(NSString *)selectedPostID {

    NSString *username = [[arrayData objectForKey:selectedPostID] name];
    NSString *promptMsg = @"";

    if ([[BlackList shared] removeWord:username]) {
        promptMsg = [NSString stringWithFormat:@"%@ a été supprimé de la liste noire", username];
    }
    else {
        [[BlackList shared] add:username];
        promptMsg = [NSString stringWithFormat:@"BIM! %@ ajouté à la liste noire", username];
    }


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:promptMsg
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    alert.tag = kAlertBlackListOK;
    [alert show];


}

-(void)actionMessage:(NSString *)selectedPostID {
    if (self.isAnimating) {
        return;
    }

    //[[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", forumNewTopicUrl]];

    NewMessageViewController *editMessageViewController = [[NewMessageViewController alloc]
                                                           initWithNibName:@"AddMessageViewController" bundle:nil];
    editMessageViewController.delegate = self;
    [editMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", kForumURL, [[arrayData objectForKey:selectedPostID] MPUrl]]];
    editMessageViewController.title = @"Nouv. Message";
    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:editMessageViewController];

    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
}

-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur {
    //NSLog(@"EcrireCookie");

    NSMutableDictionary *	outDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [outDict setObject:nom forKey:NSHTTPCookieName];
    [outDict setObject:valeur forKey:NSHTTPCookieValue];
    [outDict setObject:[[NSDate date] dateByAddingTimeInterval:(60*60)] forKey:NSHTTPCookieExpires];
    [outDict setObject:@".hardware.fr" forKey:NSHTTPCookieDomain];
    [outDict setObject:@"/" forKey:@"Path"];		// This does work.

    NSHTTPCookie	*	cookie = [NSHTTPCookie cookieWithProperties:outDict];

    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookShared setCookie:cookie];
}

-(NSString *)LireCookie:(NSString *)nom {
    //NSLog(@"LireCookie");


    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];

    for (NSHTTPCookie *aCookie in cookies) {
        if ([[aCookie name] isEqualToString:nom]) {

            if ([[NSDate date] timeIntervalSinceDate:[aCookie expiresDate]] <= 0) {
                return [aCookie value];
            }

        }

    }

    return @"";

}
-(void)EffaceCookie:(NSString *)nom {
    //NSLog(@"EffaceCookie");

    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];

    for (NSHTTPCookie *aCookie in cookies) {
        if ([[aCookie name] isEqualToString:nom]) {
            [cookShared deleteCookie:aCookie];
        }

    }

    return;
}


-(void)actionCiter:(NSString *)selectedPostID {

    NSString *components = [[[arrayData objectForKey:selectedPostID] quoteJS] substringFromIndex:7];
    components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
    components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];

    NSArray *quoteComponents = [components componentsSeparatedByString:@","];

    NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
    NSString *quotes = [self LireCookie:nameCookie];

    //NSLog(@"quotes APRES LECTURE %@", quotes);

    if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
        quotes = [quotes stringByAppendingString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]];
    }
    else {
        quotes = [quotes stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]] withString:@""];
    }


    if (quotes.length == 0) {
        //
        //NSLog(@"quote vide");
        [self EffaceCookie:nameCookie];
    }
    else
    {
        //NSLog(@"nameCookie %@", nameCookie);
        //NSLog(@"quotes %@", quotes);
        [self EcrireCookie:nameCookie withVal:quotes];
    }

    //[self.messageView stringByEvaluatingJavaScriptFromString:@"quoter('hardwarefr','prive',1556872,1962548600);"];
    //NSLog(@"actionCiter %@", [NSDate date]);

    //NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSArray *cookies = [cookShared cookies];

    //for (NSHTTPCookie *aCookie in cookies) {
    //	NSLog(@"%@", aCookie);
    //}


}

-(void)EditMessage:(NSString *)selectedPostID {

    [self setEditFlagTopic:[[arrayData objectForKey:selectedPostID] postID]];
    [self editMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectForKey:selectedPostID] urlEdit] decodeSpanUrlFromString]]];

}

-(void)QuoteMessage:(NSString *)selectedPostID {

    [self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectForKey:selectedPostID] urlQuote] decodeSpanUrlFromString]]];
}


-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected withBold:(BOOL)boldSelection {
    if (self.isAnimating) {
        return;
    }

    QuoteMessageViewController *quoteMessageViewController = [[QuoteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
    quoteMessageViewController.delegate = self;
    [quoteMessageViewController setUrlQuote:quoteUrl];
    [quoteMessageViewController setTextQuote:selected];
    [quoteMessageViewController setBoldQuote:boldSelection];

    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:quoteMessageViewController];

    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
}

-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected {
    [self quoteMessage:quoteUrl andSelectedText:selected withBold:NO];
}

-(void)quoteMessage:(NSString *)quoteUrl
{
    [self quoteMessage:quoteUrl andSelectedText:@""];
}

-(void)editMessage:(NSString *)editUrl
{
    if (self.isAnimating) {
        return;
    }

    EditMessageViewController *editMessageViewController = [[EditMessageViewController alloc]
                                                            initWithNibName:@"AddMessageViewController" bundle:nil];
    editMessageViewController.delegate = self;
    [editMessageViewController setUrlQuote:editUrl];

    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:editMessageViewController];

    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    
}


-(void)textQuote:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];

    NSString *baseElem = @"window.getSelection().anchorNode";
    while ([[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] rangeOfString:@"message"].location == NSNotFound) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);

        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    NSString *selectedPostID = [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]];

    NSLog(@"theSelectedText %@", theSelectedText);

    [self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectForKey:selectedPostID] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText];
}

-(void)textQuoteBold:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];

    NSString *baseElem = @"window.getSelection().anchorNode";
    while ([[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] rangeOfString:@"message"].location == NSNotFound) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);

        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    NSString *selectedPostID = [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]];

    NSLog(@"theSelectedText Bold %@", theSelectedText);

    [self quoteMessage:[NSString stringWithFormat:@"%@%@", kForumURL, [[[arrayData objectForKey:selectedPostID] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText withBold:YES];
    
    
}

-(void)actionFavoris {
    [self actionFavoris:curPostID];
    
}
-(void)actionProfil {
    [self actionProfil:curPostID];
    
}	
-(void)actionMessage {
    [self actionMessage:curPostID];
    
}
-(void)actionBL {
    [self actionBL:curPostID];
    
}
-(void)actionAlerter {
    [self actionAlerter:curPostID];
    
}
-(void)actionSupprimer {
    [self actionSupprimer:curPostID];
    
}

-(void)actionCiter {
    [self actionCiter:curPostID];
}

-(void)actionLink {
    [self actionLink:curPostID];
}

-(void)EditMessage {
    [self EditMessage:curPostID];
}

-(void)QuoteMessage
{
    [self QuoteMessage:curPostID];
}

#pragma mark -
#pragma mark Add Message Delegate

- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    //NSLog(@"addMessageViewControllerDidFinish %@", self.editFlagTopic);

    [self setEditFlagTopic:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
    NSLog(@"addMessageViewControllerDidFinishOK");

    [self.navigationController popToViewController:self animated:NO];

    [self dismissViewControllerAnimated:NO completion:^{
        if (self.arrayData.count > 0) {
            //NSLog(@"curid %d", self.curPostID);
            NSString *components = [[[self.arrayData objectAtIndex:0] quoteJS] substringFromIndex:7];
            components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
            components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];

            NSArray *quoteComponents = [components componentsSeparatedByString:@","];

            NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];

            [self EffaceCookie:nameCookie];
        }

        self.curPostID = @"";

        [self setStringFlagTopic:[[controller refreshAnchor] copy]];

        NSLog(@"addMessageViewControllerDidFinishOK stringFlagTopic %@", self.stringFlagTopic);


        [self searchNewMessages:kNewMessageFromEditor];

    }];

    if ([UIAlertController class]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hooray !"
                                                                       message:controller.statusMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(250000, dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{

                }];
            });
        }];
        
    }
    
}

#pragma mark -
#pragma mark AlerteModo Delegate

- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinish");
    [self dismissModalViewControllerAnimated:YES];
}
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinishOK");
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark searchNewMessages

-(void)searchNewMessages:(int)from {

    if (![self.messagesWebView isLoading]) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"$('#actualiserbtn').addClass('loading');"];
                       });

        [self performSelectorInBackground:@selector(fetchContentinBackground:) withObject:[NSNumber numberWithInt:from]];
    }
}

-(void)searchNewMessages {

    [self searchNewMessages:kNewMessageFromUnkwn];

}

- (void)fetchContentinBackground:(id)from {



    @autoreleasepool {
        int intfrom = [from intValue];

        switch (intfrom) {
            case kNewMessageFromShake:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
            case kNewMessageFromUpdate:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
            case kNewMessageFromEditor:
                // le flag est mis à jour depuis l'editeur.
                break;
            default:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
        }
        
        [self fetchContent:intfrom];
        
    }
}


#pragma mark -
#pragma mark Parsing Delegate

-(HTMLNode *)loadDataInTableView:(HTMLParser *)myParser
{
    //NSLog(@"name topicName %@", self.topicName);

    HTMLNode * bodyNode = [myParser body]; //Find the body tag

    //MP
    BOOL needToUpdateMP = NO;
    HTMLNode *MPNode = [bodyNode findChildOfClass:@"none"]; //Get links for cat
    NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
    //NSLog(@"temporaryMPArray count %d", temporaryMPArray.count);

    if (temporaryMPArray.count == 3) {
        //NSLog(@"MPNode allContents %@", [[temporaryMPArray objectAtIndex:1] allContents]);

        NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";
        NSString *myMPNumber = [[[temporaryMPArray objectAtIndex:1] allContents] stringByReplacingOccurrencesOfRegex:regExMP
                                                                                                          withString:@"$1"];

        [[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
    }
    else {
        needToUpdateMP = YES;
    }

    //MP

    //Answer Topic URL
    HTMLNode * topicAnswerNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"repondre_form" allowPartial:NO];
    self.topicAnswerUrl = [[NSString alloc] init];
    self.topicAnswerUrl = [[topicAnswerNode findChildTag:@"a"] getAttributeNamed:@"href"];
    //NSLog(@"new answer: %@", topicAnswerUrl);

    [self setupPoll:bodyNode andP:myParser];

    //form to fast answer
    [self setupFastAnswer:bodyNode];

    return bodyNode;
}

-(void)setupPoll:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    self.pollNode = nil;
    self.pollParser = nil;

    HTMLNode * tmpPollNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO];
    if(tmpPollNode)
    {
        //NSLog(@"Raw Poll %@", rawContentsOfNode([tmpPollNode _node], [myParser _doc]));
        [self setPollNode:tmpPollNode];
        [self setPollParser:myParser];
    }
}

-(void)setupFastAnswer:(HTMLNode*)bodyNode
{
    HTMLNode * fastAnswerNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hop" allowPartial:NO];
    NSArray *temporaryInputArray = [fastAnswerNode findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:YES];

    //HTMLNode * inputNode;
    for (HTMLNode * inputNode in temporaryInputArray) { //Loop through all the tags
        //NSLog(@"inputNode: %@ - value: %@", [inputNode getAttributeNamed:@"name"], [inputNode getAttributeNamed:@"value"]);
        [self.arrayInputData setObject:[inputNode getAttributeNamed:@"value"] forKey:[inputNode getAttributeNamed:@"name"]];

    }

    self.isRedFlagged = NO;

    //Fav/Unread
    HTMLNode * FlagNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"delflag" allowPartial:YES];
    self.isFavoritesOrRead =  @"";

    if (FlagNode) {
        self.isFavoritesOrRead = [FlagNode getAttributeNamed:@"href"];
        if ([FlagNode findChildWithAttribute:@"src" matchingName:@"flagn0.gif" allowPartial:YES]) {
            self.isRedFlagged = YES;
        }

        //NSLog(@"FlagNode %d", self.isRedFlagged);
    }
    else {
        HTMLNode * ReadNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"nonlu" allowPartial:YES];
        if (ReadNode) {
            self.isFavoritesOrRead = [ReadNode getAttributeNamed:@"href"];
            self.isUnreadable = YES;
        }
        else {
            self.isFavoritesOrRead =  @"";
        }
        
        //NSLog(@"!FlagNode %@", self.isFavoritesOrRead);
        //NSLog(@"!FlagNode %d", self.isUnreadable);
    }
}

- (NSString*)generateHTMLToolbar {
    return @"";
}

- (void)handleLoadedApps:(OrderedDictionary *)loadedItems
{

    int i;
    NSString *tmpHTML = @"";
/*
    if (!self.firstLoad) {
        int nbAdded = 0;

        for (i = 0; i < [loadedItems count]; i++) { //Loop through all the tags

            if (self.arrayData.count > i) {
                NSLog(@"postID new: %@ | old: %@", [[loadedItems objectAtIndex:i] postID], [[self.arrayData objectAtIndex:i] postID]);
            }
            else {
                NSLog(@"postID new: %@ | old: -----", [[loadedItems objectAtIndex:i] postID]);
                tmpHTML = [tmpHTML stringByAppendingString:[[loadedItems objectAtIndex:i] toHTML]];
                [self.arrayData insertObject:[loadedItems objectAtIndex:i] forKey:[loadedItems keyAtIndex:i] atIndex:i];
                nbAdded = nbAdded + 1;
                // Live test
                //if(nbAdded >= 2) break;
            }

        }

        if (tmpHTML.length > 0) {
            tmpHTML = [tmpHTML stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            tmpHTML = [tmpHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            tmpHTML = [tmpHTML stringByReplacingOccurrencesOfString:@"\r" withString:@""];

            NSString *animate = @"";

            if (!self.autoUpdate) {
                animate = @"$('html, body').animate({scrollTop:new_div.offset().top-50}, 'slow');";
            }

            //NSString *jsQuery = [NSString stringWithFormat:@"$('#qsdoiqjsdkjhqkjhqsdqdilkjqsd2').append('%@')", tmpHTML];
            NSString *jsQuery = [NSString stringWithFormat:@"var new_div = $('%@');\
                                 new_div.hide().appendTo('#qsdoiqjsdkjhqkjhqsdqdilkjqsd2').slideDown('fast', function() {\
                                 %@\
                                 });\
                                 ", tmpHTML, animate];

            NSLog(@"Messages Added %d", nbAdded);
            //NSLog(@"jsQuery %@", jsQuery);



            [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsQuery];

            NSString *jsString = [NSString stringWithFormat:@"$('.message').addSwipeEvents().bind('doubletap', function(evt, touch) { window.location = 'oijlkajsdoihjlkjasdodetails://'+this.id; });"];
            [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString];

            if (self.autoUpdate) {
                [self newMessagesAutoAdded:nbAdded];
            }

        }
        else {
            if (self.autoUpdate) {

                [self setupTimer:10];

            }
        }

        if (self.autoUpdate && [(UIBarButtonItem *)[self.aToolbar.items objectAtIndex:4] isEnabled]) {
            // page suivante dispo, stop autoupdate
            [self stopTimer];

            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"$('#actualiserbtn').remove()"];
                           });
        }
        else {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"$('#actualiserbtn').removeClass('loading');"];
                           });

        }
        NSString *tooBar = [self generateHTMLToolbar];
        NSString *jsQuery2 = [NSString stringWithFormat:@"var new_div2 = $('%@');\
                              var old_div = $('#toolbarpage');\
                              if (old_div.length > 0) { $(old_div).replaceWith(new_div2) }\
                              else { $('#endofpage').before(new_div2); } \
                              ", tooBar];
        //NSLog(@"jsQuery %@", jsQuery2);

        [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsQuery2];

        return;
    }

 */
    [self.arrayData removeAllObjects];
    self.arrayData = loadedItems;




    NSLog(@"COUNT = %lu", (unsigned long)[self.arrayData count]);

    if (self.isSearchIntra && self.arrayData.count == 0) {
        NSLog(@"BZAAAAA %@", self.currentUrl);
        [self.loadingView setHidden:YES];
        [self.messagesWebView setHidden:YES];
        [self.errorLabelView setText:@"Désolé aucune réponse n'a été trouvée"];
        [self.errorLabelView setHidden:NO];
        [self toggleSearch:YES];
    }
    else {

        NSLog(@"OLD %@", self.stringFlagTopic);

        NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        int currentFlagValue = [[self.stringFlagTopic stringByTrimmingCharactersInSet:nonDigits] intValue];
        bool ifCurrentFlag = NO;
        int closePostID = 0;

        if(!currentFlagValue) { //si pas de value on cherche soit le premier message (pas de flag) soit le dernier (#bas)
            NSLog(@"!currentFlagValue");

            ifCurrentFlag = YES;
        }

        NSLog(@"Looking for %d", currentFlagValue);
        NSLog(@"==============");

        for (i = 0; i < [self.arrayData count]; i++) { //Loop through all the tags
            tmpHTML = [tmpHTML stringByAppendingString:[[self.arrayData objectAtIndex:i] toHTML]];

            if (!ifCurrentFlag) {

                int tmpFlagValue = [[[[self.arrayData objectAtIndex:i] postID] stringByTrimmingCharactersInSet:nonDigits] intValue];

                if (tmpFlagValue == currentFlagValue) {
                    //NSLog(@"TROUVE");
                    ifCurrentFlag = YES;
                    closePostID = tmpFlagValue;
                }

                //NSLog(@"pas encore trouvé");

                if (closePostID && currentFlagValue && tmpFlagValue >= currentFlagValue) {
                    //NSLog(@"On a trouvé plus grand, on set");
                    closePostID = tmpFlagValue;
                    ifCurrentFlag = YES;
                }
                else {
                    //NSLog(@"0, on set le premier");
                    closePostID = tmpFlagValue;
                }

                //NSLog(@"-- curFlagID = %d", tmpFlagValue);
            }

        }

        if (closePostID) {
            NSLog(@"On remplace au plus proche");
            self.stringFlagTopic = [NSString stringWithFormat:@"#t%d", closePostID];
        }

        NSLog(@"NEW %@", self.stringFlagTopic);


        NSString *refreshBtn = @"";

        //on ajoute le bouton actualiser si besoin
        if (([self pageNumber] == [self lastPageNumber]) || ([self lastPageNumber] == 0)) {
            //NSLog(@"premiere et unique ou dernier");
            //'before'
            refreshBtn = @"<div id=\"actualiserbtn\" onClick=\"window.location = 'oijlkajsdoihjlkjasdorefresh://data'; return false;\">Actualiser</div>";

        }
        else {
            //NSLog(@"autre");
        }

        NSString *tooBar = [self generateHTMLToolbar];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *display_sig = [defaults stringForKey:@"display_sig"];

        NSString *display_sig_css = @"nosig";

        if ([display_sig isEqualToString:@"yes"]) {
            display_sig_css = @"";
        }

        NSString *customFontSize = [self userTextSizeDidChange];

        NSString *HTMLString = [NSString
                                stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
                                <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">\
                                <head>\
                                <script type='text/javascript' src='jquery-2.1.1.min.js'></script>\
                                <script type='text/javascript' src='jquery.doubletap.js'></script>\
                                <script type='text/javascript' src='jquery.base64.js'></script>\
                                <meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no' />\
                                <link type='text/css' rel='stylesheet' href='style-liste.css'/>\
                                <link type='text/css' rel='stylesheet' href='style-liste-retina.css' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\
                                <style type='text/css'>\
                                %@\
                                </style>\
                                </head><body class='iosversion'><a name='top'></a>\
                                <div class='bunselected %@' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'>\
                                %@\
                                </div>\
                                %@\
                                %@\
                                <div id='endofpage'></div>\
                                <div id='endofpagetoolbar'></div>\
                                <a name='bas'></a>\
                                <script type='text/javascript'>\
                                document.addEventListener('DOMContentLoaded', loadedML);\
                                document.addEventListener('touchstart', touchstart);\
                                function loadedML() { setTimeout(function() {document.location.href = 'oijlkajsdoihjlkjasdoloaded://loaded';},700); };\
                                function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; }\
                                function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; }\
                                function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}}\
                                $('img').error(function(){ $(this).attr('src', 'photoDefaultfailmini.png');});\
                                function touchstart() { document.location.href = 'oijlkajsdoihjlkjasdotouch://touchstart'};\
                                </script>\
                                </body></html>", customFontSize, display_sig_css, tmpHTML, refreshBtn, tooBar];


        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            if (self.isSearchIntra) {
                HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7 searchintra"];
            }
            else {
                HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
            }
        }
        //  HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"hfrplusiosversion" withString:@""];


        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        //NSLog(@"baseURL %@", baseURL);

        //NSLog(@"======================================================================================================");
        //NSLog(@"HTMLString %@", HTMLString);
        NSLog(@"======================================================================================================");
        NSLog(@"baseURL %@", baseURL);
        //NSLog(@"======================================================================================================");
        
        self.loaded = NO;
        [self.messagesWebView loadHTMLString:HTMLString baseURL:baseURL];
        
        [self.messagesWebView setUserInteractionEnabled:YES];
    }
    
    
    //[HTMLString release];
    //[tmpHTML release];
    
}

- (void)handleLoadedParser:(HTMLParser *)myParser
{
    [self loadDataInTableView:myParser];
}

- (void)didStartParsing:(HTMLParser *)myParser
{
    [self performSelectorOnMainThread:@selector(handleLoadedParser:) withObject:myParser waitUntilDone:NO];
}

- (void)didFinishParsing:(OrderedDictionary *)appList
{
    [self performSelectorOnMainThread:@selector(handleLoadedApps:) withObject:appList waitUntilDone:NO];
    self.queue = nil;
}

#pragma mark -
#pragma mark SharedMenu lifecycle

- (void)VisibilityChanged:(NSNotification *)notification {
    NSLog(@"VisibilityChanged %@", notification);
    /*  NSLog(@"TINT 1 %ld", (long)[[HFRplusAppDelegate sharedAppDelegate].window tintAdjustmentMode]);

     [[HFRplusAppDelegate sharedAppDelegate].window setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
     [[HFRplusAppDelegate sharedAppDelegate].window setTintColor:[UIColor greenColor]];
     [[HFRplusAppDelegate sharedAppDelegate].window setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];

     NSLog(@"TINT 2 %ld", (long)[[HFRplusAppDelegate sharedAppDelegate].window tintAdjustmentMode]);
     */
    //


    //    NSLog(@"TINT 2 %@", [[HFRplusAppDelegate sharedAppDelegate].window tintColor]);


    if ([[notification valueForKey:@"object"] isEqualToString:@"SHOW"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
        [self editMenuHidden:nil];
    }
    //[self resignFirstResponder];
}


- (void)editMenuHidden:(id)sender {
    NSLog(@"editMenuHidden %@ NOMBRE %lu", sender, [UIMenuController sharedMenuController].menuItems.count);

    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgQuoteB = [UIImage imageNamed:@"BoldFilled-20"];


    UIMenuItem *textQuotinuum = [[UIMenuItem alloc] initWithTitle:@"Citerexclu" action:@selector(textQuote:) image:menuImgQuote];
    UIMenuItem *textQuotinuumBis = [[UIMenuItem alloc] initWithTitle:@"Citergras" action:@selector(textQuoteBold:) image:menuImgQuoteB];

    [self.arrayAction removeAllObjects];
    /*
     [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citerexclu", @"textQuote:", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

     [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citergras", @"textQuoteBold:", menuImgQuoteB, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
     */

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObjects:textQuotinuum, textQuotinuumBis, nil]];
    //[self.messagesWebView becomeFirstResponder];
    //    [self becomeFirstResponder];
    
}

#pragma mark -
#pragma mark WebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"== webViewDidStartLoad");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishPreLoadDOM {
    NSLog(@"== webViewDidFinishPreLoadDOM");

    //[self userTextSizeDidChange];
}

- (void)webViewDidFinishLoadDOM
{
    NSLog(@"== webViewDidFinishLoadDOM");

    if (!self.pageNumber) {
        return;
    }

    if (!self.loaded) {
        NSLog(@"== First DOM");
        self.loaded = YES;

        //if (SYSTEM_VERSION_LESS_THAN(@"9")) {
        NSString* jsString2 = @"window.location.hash='#bas';";
        NSString* jsString3 = [NSString stringWithFormat:@"window.location.hash='%@';", ![self.stringFlagTopic isEqualToString:@""] ? [NSString stringWithFormat:@"anch%@", self.stringFlagTopic] : @"#top"];
        NSLog(@"jsString3 %@", jsString3);

        NSString* result = [self.messagesWebView stringByEvaluatingJavaScriptFromString:[jsString2 stringByAppendingString:jsString3]];
        //        [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString3];
        //}
        //Position du Flag



        //NSLog(@"jsString2 %@", jsString2);
        //NSLog(@"jsString3 %@", jsString3);
        //NSLog(@"result %@", result);

        self.lastStringFlagTopic = self.stringFlagTopic;
        self.stringFlagTopic = @"";

        [self.loadingView setHidden:YES];
        [self.messagesWebView setHidden:NO];
        [self.messagesWebView becomeFirstResponder];

        self.firstLoad = NO;

        /* LIVE
        if (self.autoUpdate) {

            [self setupTimer:5];

        }
         */

        NSString *jsString = @"";

        jsString = [jsString stringByAppendingString:@"$('.message').addSwipeEvents().bind('doubletap', function(evt, touch) { window.location = 'oijlkajsdoihjlkjasdodetails://'+this.id; });"];
        [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString];
        return;
    }
    NSLog(@"== DOMed");

}




- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"== webViewDidFinishLoad");

    //if (!self.loaded) {
    //    [self webViewDidFinishPreLoadDOM];
    //}

    [self webViewDidFinishLoadDOM];

    //    [webView.scrollView setContentSize: CGSizeMake(300, webView.scrollView.contentSize.height)];
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    //NSLog(@"== webViewDidFinishLoad OK");

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //NSLog(@"MTV %@ nbS=%lu", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count);

    BOOL returnA;

    if ((action == @selector(textQuote:) || action == @selector(textQuoteBold:)) && ([self.searchKeyword isFirstResponder] || [self.searchPseudo isFirstResponder]) ) {
        returnA = NO;
    } else {
        returnA = [super canPerformAction:action withSender:sender];
    }

    //NSLog(@"MTV returnA %d", returnA);
    return returnA;
}

- (BOOL) canBecomeFirstResponder {
    //NSLog(@"===== canBecomeFirstResponder");

    return NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"expected:%ld, got:%ld | url:%@", (long)UIWebViewNavigationTypeLinkClicked, (long)navigationType, aRequest.URL);

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

        if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoauto"]) {
            [self goToPage:[[aRequest.URL absoluteString] lastPathComponent]];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"file"]) {

            if ([[[aRequest.URL pathComponents] objectAtIndex:0] isEqualToString:@"/"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
                //NSLog(@"pas la meme page / topic");

                //NSLog(@"did Select row Topics table views: %d", indexPath.row);

                //if (self.messagesTableViewController == nil) {
                MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                //}

                //setup the URL
                aView.topicName = @"";
                aView.isViewed = YES;

                self.messagesTableViewController = aView;

                self.navigationItem.backBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                 style: UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];

                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                    self.navigationItem.backBarButtonItem.title = @" ";
                }

                //NSLog(@"push message liste");
                [self.navigationController pushViewController:messagesTableViewController animated:YES];
            }



            // NSLog(@"clicked [[aRequest.URL absoluteString] %@", [aRequest.URL absoluteString]);
            //  NSLog(@"clicked [[aRequest.URL pathComponents] %@", [aRequest.URL pathComponents]);
            //  NSLog(@"clicked [[aRequest.URL path] %@", [aRequest.URL path]);
            //  NSLog(@"clicked [[aRequest.URL lastPathComponent] %@", [aRequest.URL lastPathComponent]);

            return NO;
        }
        else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {

            //NSLog(@"%@", aRequest.URL);

            MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", kForumURL] withString:@""]];
            
            aView.topicName = @"";
            aView.isViewed = YES;

            self.messagesTableViewController = aView;

            self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                             style: UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                self.navigationItem.backBarButtonItem.title = @" ";
            }

            [self.navigationController pushViewController:messagesTableViewController animated:YES];

            return NO;
        }
        else {
            NSURL *url = aRequest.URL;
            NSString *urlString = url.absoluteString;

            [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
            return NO;
        }

    }
    else if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdodetails"]) {
            NSLog(@"details ========== %@", [[aRequest.URL absoluteString] lastPathComponent]);
            [self didSelectMessage:[[aRequest.URL absoluteString] lastPathComponent]];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdotouch"]) {
            // cache le menu controller dès que l'utilisateur touche la WebView
            if ([[[aRequest.URL absoluteString] lastPathComponent] isEqualToString:@"touchstart"]) {
                if ([UIMenuController sharedMenuController].isMenuVisible) {
                    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
                }
            }
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopreloaded"]) {
            [self webViewDidFinishPreLoadDOM];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoloaded"]) {
            [self webViewDidFinishLoadDOM];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdorefresh"]) {

            [self searchNewMessages:kNewMessageFromUpdate];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopopup"]) {
            //NSLog(@"oijlkajsdoihjlkjasdopopup");
            int ypos = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] intValue];
            NSString *tappedPostID = [[[aRequest.URL absoluteString] pathComponents] objectAtIndex:2];
            NSLog(@"%d %@", ypos, tappedPostID);

            [self performSelector:@selector(showMenuCon:andPos:) withObject:tappedPostID withObject:[NSNumber numberWithInt:ypos]];
            return NO;
        }
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoimbrows"]) {
            NSString *regularExpressionString = @"oijlkajsdoihjlkjasdoimbrows://[^/]+/(.*)";

            NSString *imgUrl = [[[[aRequest.URL absoluteString] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            [self didSelectImage:[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] withUrl:imgUrl];

            return NO;
        }
        else {

            //NSLog(@"OTHHHHERRRREEE %@ %@", [aRequest.URL scheme], [aRequest.URL fragment]);
            if ([[aRequest.URL fragment] isEqualToString:@"bas"]) {
                //return NO;
            }

        }


    }
    else {
        //NSLog(@"VRAIMENT OTHHHHERRRREEE %@ %@", [aRequest.URL scheme], [aRequest.URL fragment]);

    }

    return YES;
}

-(void) showMenuCon:(NSString *)tappedPostID andPos:(NSNumber *)posN {

    [self.arrayAction removeAllObjects];

    int ypos = [posN intValue];


    NSString *answString = nil;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        answString = @"Répondre";
    }
    else
    {
        answString = @"Rép.";
    }

    //UIImage *menuImgBan = [UIImage imageNamed:@"RemoveUserFilled-20"];
    UIImage *menuImgBan = [UIImage imageNamed:@"ThorHammer-20"];
    if ([[BlackList shared] isBL:[[arrayData objectForKey:tappedPostID] name]]) {
        menuImgBan = [UIImage imageNamed:@"ThorHammerFilled-20"];
    }

    UIImage *menuImgEdit = [UIImage imageNamed:@"EditColumnFilled-20"];
    UIImage *menuImgProfil = [UIImage imageNamed:@"ContactCardFilled-20"];
    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgMP = [UIImage imageNamed:@"MessageFilled-20"];
    UIImage *menuImgFav = [UIImage imageNamed:@"StarFilled-20"];

    //UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"QuoteFilled-20"];
    //UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"Quote-20"];

    UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"ReplyAllArrowFilled-20"];
    UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"ReplyAllArrow-20"];

    UIImage *menuImgDelete = [UIImage imageNamed:@"DeleteColumnFilled-20"];
    UIImage *menuImgAlerte = [UIImage imageNamed:@"HighPriorityFilled-20"];

    if([[arrayData objectForKey:tappedPostID] urlEdit]){
        //NSLog(@"urlEdit");
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Editer", @"EditMessage", menuImgEdit, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

        if ([arrayData indexForKey:tappedPostID] > 0) { //Pas de suppression du premier message d'un topic (curMsg = 0);
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Supprimer", @"actionSupprimer", menuImgDelete, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }

        if (self.navigationItem.rightBarButtonItem.enabled) {
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
    }
    else {
        //NSLog(@"profil");
        if (self.navigationItem.rightBarButtonItem.enabled) {
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }




    }



    //"Citer ☑"@"Citer ☒"@"Citer ☐"
    if([[arrayData objectForKey:tappedPostID] quoteJS] && self.navigationItem.rightBarButtonItem.enabled) {
        NSString *components = [[[arrayData objectForKey:tappedPostID] quoteJS] substringFromIndex:7];
        components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
        components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];

        NSArray *quoteComponents = [components componentsSeparatedByString:@","];

        NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
        NSString *quotes = [self LireCookie:nameCookie];

        if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☐", @"actionCiter", menuImgMultiQuoteUnchecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

        }
        else {
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☑", @"actionCiter", menuImgMultiQuoteChecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

        }

    }


    if ([self canBeFavorite]) {
        //NSLog(@"isRedFlagged ★");
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Favoris", @"actionFavoris", menuImgFav, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    }


    if(![[arrayData objectForKey:tappedPostID] urlEdit]){



        if([[arrayData objectForKey:tappedPostID] urlAlert]){

            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alerter", @"actionAlerter", menuImgAlerte, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
    }

    [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Profil", @"actionProfil", menuImgProfil, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

    if(![[arrayData objectForKey:tappedPostID] urlEdit]){

        if([[arrayData objectForKey:tappedPostID] MPUrl]){
            //NSLog(@"MPUrl");

            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"MP", @"actionMessage", menuImgMP, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }

        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Blacklist", @"actionBL", menuImgBan, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];



    }





    self.curPostID = tappedPostID;
    /*
     UIActionSheet *styleAlert = [[UIActionSheet alloc] init];
     for (id tmpAction in self.arrayAction) {
     [styleAlert addButtonWithTitle:[tmpAction valueForKey:@"title"]];
     }

     [styleAlert addButtonWithTitle:@"Annuler"];

     styleAlert.cancelButtonIndex = self.arrayAction.count;
     styleAlert.delegate = self;

     styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

     [styleAlert showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
     //[styleAlert showFromTabBar:[[[HFRplusAppDelegate sharedAppDelegate] rootController] tabBar]];
     [styleAlert release];

     */

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    //[menuController setMenuVisible:YES animated:YES];

    NSMutableArray *menuAction = [[NSMutableArray alloc] init];



    for (id tmpAction in self.arrayAction) {
        //NSLog(@"%@", [tmpAction objectForKey:@"code"]);

        if ([tmpAction objectForKey:@"image"] != nil) {
            UIMenuItem *tmpMenuItem2 = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"]) image:(UIImage *)[tmpAction objectForKey:@"image"]];
            [menuAction addObject:tmpMenuItem2];
        }
        else {
            UIMenuItem *tmpMenuItem = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"])];
            [menuAction addObject:tmpMenuItem];
        }

    }
    [menuController setMenuItems:menuAction];
    //NSLog(@"menuAction %d", menuAction.count);

    //NSLog(@"ypos %d", ypos);



    if (ypos < 40) {

        ypos +=34;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7,0")) {
            ypos +=10;
        }
        [menuController setArrowDirection:UIMenuControllerArrowUp];
    }
    else {
        [menuController setArrowDirection:UIMenuControllerArrowDown];
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7,0")) {
        //ypos += 66;
    }

    //NSLog(@"oijlkajsdoihjlkjasdopopup 0");
    
    //CGRect myFrame = [[self.view superview] frame];
    //myFrame.size.width-20
    //NSLog(@"%f", myFrame.size.width);
    
    CGRect selectionRect = CGRectMake(38, ypos, 0, 0);
    
    
    [self.view setNeedsDisplayInRect:selectionRect];
    [menuController setTargetRect:selectionRect inView:self.view];
    //[menuController setMenuVisible:YES animated:YES];
    
    //[menuController setTargetRect:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) inView:self.view];
    
    [menuController setMenuVisible:YES animated:YES];
    //[menuController setMenuVisible:YES];
    //[menuController setMenuVisible:NO];
    
    //NSLog(@"oijlkajsdoihjlkjasdopopup");	
}
/*
 - (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
 {
	NSLog(@"MTV clickedButtonAtIndex %d %d", buttonIndex, curPostID);
	if (buttonIndex < [self.arrayAction count]) {
 
 
 [self performSelector:NSSelectorFromString([[self.arrayAction objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:[NSNumber numberWithInt:curPostID]];
	}
	
 }
 */


@end
