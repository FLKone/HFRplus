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
	
	UIViewController *__weak lastViewController;
	IBOutlet InfoTableViewCell *__weak tmpCell;
}

@property (nonatomic, strong) NSMutableArray *menuList;

@property (nonatomic, weak) UIViewController *lastViewController;
@property (nonatomic, weak) IBOutlet InfoTableViewCell *tmpCell;

@end