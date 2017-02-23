//
//  ProfilViewController.h
//  HFRplus
//
//  Created by Shasta on 19/05/2014.
//
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"
#import "ThemeColors.h"
#import "ThemeManager.h"

@class ASIHTTPRequest;

@interface ProfilViewController : UIViewController {
    /* View */
    IBOutlet UITableView *profilTableView;
	IBOutlet UIView *loadingView;
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    STATUS status;
	NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    
    /* Request */
    NSString *currentUrl;
    ASIHTTPRequest *request;

    /* Data */
    NSMutableArray *arrayData;
}

@property (nonatomic, strong) IBOutlet UITableView *profilTableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property STATUS status;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (strong, nonatomic) NSString *currentUrl;
@property (strong, nonatomic) ASIHTTPRequest *request;

@property (nonatomic, strong) NSMutableArray *arrayData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl;

@end

@class ASIHTTPRequest;
@interface FeedbackViewController : PageViewController {
    IBOutlet UITableView *feedTableView;

    IBOutlet UIView *loadingView;
    IBOutlet UILabel* loadingLabel;
    IBOutlet UIActivityIndicatorView* loadingIndicator;
    
    NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    STATUS status;
    
    ASIHTTPRequest *request;
    
    /* Data */
    NSMutableArray *arrayData;
}

@property (nonatomic, strong) IBOutlet UITableView *feedTableView;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) NSMutableArray *arrayData;
@property STATUS status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end

@interface PersonnalLinkViewController : UIViewController {
    IBOutlet UIWebView *webView;
    NSURL *url;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet NSURL *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end


@interface ConfigurationViewController : UIViewController {
    IBOutlet UITextView *textView;
    
    IBOutlet UIView *loadingView;
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    NSString *statusMessage;
	IBOutlet UILabel *maintenanceView;
    STATUS status;
    
    ASIHTTPRequest *request;
    
    NSString *url;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) ASIHTTPRequest *request;
@property STATUS status;

@property (nonatomic, strong) IBOutlet NSString *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL;

@end
