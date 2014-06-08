//
//  ProfilViewController.h
//  HFRplus
//
//  Created by Shasta on 19/05/2014.
//
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

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

@class ASIHTTPRequest;
@interface FeedbackViewController : PageViewController {
    IBOutlet UITableView *feedTableView;

    IBOutlet UIView *loadingView;
    NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    STATUS status;
    
    ASIHTTPRequest *request;
    
    /* Data */
    NSMutableArray *arrayData;
}

@property (nonatomic, retain) IBOutlet UITableView *feedTableView;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *arrayData;
@property STATUS status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end

@interface PersonnalLinkViewController : UIViewController {
    IBOutlet UIWebView *webView;
    NSURL *url;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet NSURL *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end


@interface ConfigurationViewController : UIViewController {
    IBOutlet UITextView *textView;
    
    IBOutlet UIView *loadingView;
    NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    STATUS status;
    
    ASIHTTPRequest *request;
    
    NSString *url;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) IBOutlet UILabel *maintenanceView;

@property (nonatomic, retain) ASIHTTPRequest *request;
@property STATUS status;

@property (nonatomic, retain) IBOutlet NSString *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end