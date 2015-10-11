//
//  PollTableViewController.h
//  HFRplus
//
//  Created by Shasta on 12/02/2014.
//
//

#import <UIKit/UIKit.h>
@class MessagesTableViewController;
@class ASIHTTPRequest;
@class HTMLNode;
@class HTMLParser;

@interface PollTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    
    IBOutlet UITableView *tableViewPoll;
	IBOutlet UIView *loadingView;
    NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    STATUS status;

    
    NSMutableDictionary *arrayInputData;
    NSMutableDictionary *arraySubmitBtn;
    NSMutableArray *arrayOptions;
    NSMutableArray *arrayResults;
    
    NSMutableArray *arraySelectedRows;
    
    NSString *stringQuestion;
    NSString *stringFooter;
    
    MessagesTableViewController *delegate;
    ASIHTTPRequest *request;
    
    int intNombreChoix;
}

@property (nonatomic, strong) IBOutlet UITableView *tableViewPoll;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) NSMutableDictionary *arrayInputData;
@property (nonatomic, strong) NSMutableDictionary *arraySubmitBtn;
@property (nonatomic, strong) NSMutableArray *arrayOptions;
@property (nonatomic, strong) NSMutableArray *arrayResults;
@property (nonatomic, strong) NSMutableArray *arraySelectedRows;

@property (nonatomic, strong) NSString *stringQuestion;
@property (nonatomic, strong) NSString *stringFooter;

@property (nonatomic, strong) MessagesTableViewController *delegate;
@property (nonatomic, strong) ASIHTTPRequest *request;
@property STATUS status;

@property int intNombreChoix;

- (id)initWithPollNode:(HTMLNode *)aPollNode andParser:(HTMLParser *)aPollParser;

@end