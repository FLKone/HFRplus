//
//  HFRSearchViewController.h
//  HFRplus
//
//  Created by Shasta on 04/11/10.
//

#import <UIKit/UIKit.h>
@class ASIFormDataRequest;


@interface HFRSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, NSXMLParserDelegate> {
	UIView *disableViewOverlay;

    UITableView *theTableView;
    UISearchBar *theSearchBar;
	
	IBOutlet UIView *loadingView;
	IBOutlet UILabel *maintenanceView;

	ASIFormDataRequest *request;
	STATUS status;
	NSString *statusMessage;
	
	
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

@property(retain) NSMutableArray *stories;
@property(retain) UIView *disableViewOverlay;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (retain, nonatomic) ASIFormDataRequest *request;
@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end
