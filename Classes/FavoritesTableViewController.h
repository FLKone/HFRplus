//
//  FavoritesTableViewController.h
//  HFR+
//
//  Created by Lace on 05/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessagesTableViewController;
@class ASIHTTPRequest;

@interface FavoritesTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
	UITableView *favoritesTableView;
	UIView *loadingView;
	
	NSMutableArray *favoritesArray;
	NSMutableArray *arrayData;
	NSMutableDictionary *arrayDataID;
	NSMutableArray *arrayDataID2;
	NSMutableDictionary *arraySection;

	MessagesTableViewController *messagesTableViewController;

	NSIndexPath *pressedIndexPath;

	ASIHTTPRequest *request;
	
	STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;	
    
    UITextField *pageNumberField;
}

@property (nonatomic, retain) IBOutlet UITableView *favoritesTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) NSMutableArray *favoritesArray;
@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, retain) NSMutableDictionary *arrayDataID;
@property (nonatomic, retain) NSMutableArray *arrayDataID2;
@property (nonatomic, retain) NSMutableDictionary *arraySection;
@property (nonatomic, retain) MessagesTableViewController *messagesTableViewController;

@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

-(NSString*)wordAfterString:(NSString*)searchString inString:(NSString*)selfString;

@property (nonatomic, retain) NSIndexPath *pressedIndexPath;

@property (retain, nonatomic) ASIHTTPRequest *request;

-(void)loadDataInTableView:(NSData*)contentData;
-(void)reset;
-(void)reload:(BOOL)shake;
-(void)reload;

- (void)pushTopic;

@property (nonatomic, retain) UITextField *pageNumberField;
- (void)chooseTopicPage;

@end