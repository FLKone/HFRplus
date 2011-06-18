//
//  HFRplusAppDelegate.h
//  HFRplus
//
//  Created by FLK on 18/08/10.
//

#import "GANTracker.h"
static const NSInteger kGANDispatchPeriodSec = 10;

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TabBarController.h"

#import "Reachability.h"

@interface HFRplusAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	TabBarController *rootController;	

	UINavigationController *forumsNavController;
	UINavigationController *favoritesNavController;
	UINavigationController *messagesNavController;

	BOOL isLoggedIn;
	BOOL statusChanged;	
	
   // NSOperationQueue *ioQueue;
    NSTimer *periodicMaintenanceTimer;
    //NSOperation *periodicMaintenanceOperation;	
	
	NSString *hash_check;
    
    Reachability* internetReach;
}

//@property (nonatomic, retain) NSOperationQueue *ioQueue;
//@property (retain) NSOperation *periodicMaintenanceOperation;
- (void)periodicMaintenance;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TabBarController *rootController;

@property (nonatomic, retain) IBOutlet UINavigationController *forumsNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *favoritesNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *messagesNavController;

@property BOOL isLoggedIn;
@property BOOL statusChanged;

@property (nonatomic, retain) NSString *hash_check;

@property (nonatomic, retain) Reachability *internetReach;

+ (HFRplusAppDelegate *)sharedAppDelegate;

- (void)updateMPBadgeWithString:(NSString *)badgeValue;
- (void)readMPBadge;
- (void)openURL:(NSString *)stringUrl;

- (void)login;
- (void)checkLogin;
- (void)logout;

- (void)registerDefaultsFromSettingsBundle;
@end

