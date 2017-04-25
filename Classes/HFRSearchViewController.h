//
//  HFRSearchViewController.h
//  HFRplus
//
//  Created by FLK on 04/11/10.
//

#import <UIKit/UIKit.h>
@class ASIFormDataRequest;
@class MessagesTableViewController;
@class TopicSearchCellView;

@interface HFRSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, NSXMLParserDelegate, UIActionSheetDelegate> {
	UIView *disableViewOverlay;

    UITableView *theTableView;
    UISearchBar *theSearchBar;
	
	IBOutlet UIView *loadingView;
	IBOutlet UILabel *maintenanceView;

	ASIFormDataRequest *request;
	STATUS status;
	NSString *statusMessage;
	
	MessagesTableViewController *messagesTableViewController;
	TopicSearchCellView *__weak tmpCell;

	NSIndexPath *pressedIndexPath;
	UIActionSheet		*topicActionSheet;
    
	NSXMLParser * rssParser;
	
	NSMutableArray * stories;
	
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink;	
}

@property(strong) NSMutableArray *stories;
@property(strong) UIView *disableViewOverlay;

@property (nonatomic, strong) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *theSearchBar;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (strong, nonatomic) ASIFormDataRequest *request;
@property STATUS status;
@property (nonatomic, strong) NSString *statusMessage;

@property (nonatomic, strong) NSIndexPath *pressedIndexPath;
@property (nonatomic, strong) UIActionSheet *topicActionSheet;

@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;
@property (nonatomic, weak) IBOutlet TopicSearchCellView *tmpCell;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end
