//
//  HFRplusAppDelegate.h
//  HFRplus
//
//  Created by FLK on 18/08/10.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TabBarController.h"
#import "SplitViewController.h"
#import "DetailNavigationViewController.h"

#import "IASKAppSettingsViewController.h"

#import "Reachability.h"

@interface HFRplusAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	TabBarController *rootController;	
	SplitViewController *splitViewController;
	DetailNavigationViewController *detailNavigationController;

	UINavigationController *forumsNavController;
	UINavigationController *favoritesNavController;
	UINavigationController *messagesNavController;
    UINavigationController *searchNavController;
    
	BOOL isLoggedIn;
	BOOL statusChanged;	
	
   // NSOperationQueue *ioQueue;
    NSTimer *periodicMaintenanceTimer;
    //NSOperation *periodicMaintenanceOperation;	
	
	NSString *hash_check;
    
    Reachability* internetReach;

}

- (void)periodicMaintenance;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TabBarController *rootController;
@property (nonatomic, retain) IBOutlet SplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet DetailNavigationViewController *detailNavigationController;

@property (nonatomic, retain) IBOutlet UINavigationController *forumsNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *favoritesNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *messagesNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *searchNavController;

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

- (void)resetApp;

- (void)registerDefaultsFromSettingsBundle;
@end

