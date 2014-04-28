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

@interface PollTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
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

@property (nonatomic, retain) IBOutlet UITableView *tableViewPoll;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) NSMutableDictionary *arraySubmitBtn;
@property (nonatomic, retain) NSMutableArray *arrayOptions;
@property (nonatomic, retain) NSMutableArray *arrayResults;
@property (nonatomic, retain) NSMutableArray *arraySelectedRows;

@property (nonatomic, retain) NSString *stringQuestion;
@property (nonatomic, retain) NSString *stringFooter;

@property (nonatomic, retain) MessagesTableViewController *delegate;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property STATUS status;

@property int intNombreChoix;

- (id)initWithPollNode:(NSString *)aPollNode;

@end