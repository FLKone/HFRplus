//
//  InfosViewController.h
//  HFRplus
//
//  Created by FLK on 23/07/10.
//

#import <UIKit/UIKit.h>

#define kViewControllerKey		@"viewController"
#define kTitleKey				@"title"
#define kXibKey                 @"xib"
#define kImageKey                 @"image"

@interface InfosViewController : UITableViewController <UINavigationBarDelegate, UIActionSheetDelegate>
{
	NSMutableArray *menuList;
	
	UIViewController *lastViewController;
	
}

@property (nonatomic, retain) NSMutableArray *menuList;

@property (nonatomic, assign) UIViewController *lastViewController;

@end
