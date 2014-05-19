//
//  ProfilViewController.h
//  HFRplus
//
//  Created by Shasta on 19/05/2014.
//
//

#import <UIKit/UIKit.h>

@class ASIHTTPRequest;

@interface ProfilViewController : UIViewController {
    /* View */
    IBOutlet UITableView *profilTableView;
	IBOutlet UIView *loadingView;
    
    STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    
    /* Request */
    NSString *currentUrl;
    ASIHTTPRequest *request;

    /* Data */
    NSMutableArray *arrayData;
}

@property (nonatomic, retain) IBOutlet UITableView *profilTableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property STATUS status;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (retain, nonatomic) NSString *currentUrl;
@property (retain, nonatomic) ASIHTTPRequest *request;

@property (nonatomic, retain) NSMutableArray *arrayData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl;

@end