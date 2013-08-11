//
//  Constants.h
//  HFRplus
//
//  Created by FLK on 05/08/10.
//


#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

static const NSInteger kDispatchPeriodSeconds = 20;
float kTableViewContentInsetTop;
float kTableViewScrollInsetTop;
float kTableViewContentInsetBottom;

typedef enum {
	kIdle,
	kMaintenance,
	kNoResults,
    kNoAuth,
	kComplete
} STATUS;

#define kForumURL				@"http://forum.hardware.fr"

#define kTimeoutMini		30
#define kTimeoutMaxi		60
#define kTimeoutAvatar      10

#define kTableViewCellRowHeight     44.0f
//#define kTableViewContentInsetTop   44.0f //iOS5-6
//#define kTableViewContentInsetTop   64.0f //iOS7
//#define kTableViewContentInsetBottom   42.0f


#define MAX_HEIGHT 1200.0f 
#define MAX_CELL_CONTENT 300.0f
#define MAX_TEXT_WIDTH 250.0f

#ifndef DEBUG_LOGS
	#define DEBUG_LOGS 0
#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kNewMessageFromUpdate   1
#define kNewMessageFromShake    2
#define kNewMessageFromEditor   3
#define kNewMessageFromUnkwn    4

//Categories
#import "UITableViewController+Ext.h"
#import "NSDictionary+Merging.h"
#import "UIImage+Resize.h"
#import "UIBarButtonItem+Extension.h"

// Helpers
#import "HFRTableView.h"
#import "MenuViewController.h"
#import "HFRNavigationController.h"

// Views
#import "MenuButton.h"

// Controllers
#import "MenuViewController.h"
#import "ForumsTableViewController.h"
#import "InfosViewController.h"
#import "FavoritesTableViewController.h"
#import "HFRSearchViewController.h"
#import "HFRMPViewController.h"

//Vendor
#import "TestFlight.h"