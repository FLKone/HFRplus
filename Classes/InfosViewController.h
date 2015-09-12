//
//  InfosViewController.h
//  HFRplus
//
//  Created by FLK on 23/07/10.
//

#import <UIKit/UIKit.h>
@class InfoTableViewCell;

#define kViewControllerKey		@"viewController"
#define kTitleKey				@"title"
#define kXibKey                 @"xib"
#define kImageKey                 @"image"

@interface InfosViewController : UITableViewController <UINavigationBarDelegate, UIActionSheetDelegate>
{
	NSMutableArray *menuList;
	
	UIViewController *lastViewController;
	IBOutlet InfoTableViewCell *tmpCell;
}

@property (nonatomic, retain) NSMutableArray *menuList;

@property (nonatomic, assign) UIViewController *lastViewController;
@property (nonatomic, assign) IBOutlet InfoTableViewCell *tmpCell;

@end