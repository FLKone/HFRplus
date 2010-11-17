//
//  InfosViewController.h
//  HFR+
//
//  Created by Lace on 23/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kViewControllerKey		@"viewController"
#define kTitleKey				@"title"

@interface InfosViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate,
												  UITableViewDataSource, UIActionSheetDelegate>
{
	UITableView	*infosTableView;
	NSMutableArray *menuList;
	
	UIViewController *lastViewController;
	
}

@property (nonatomic, retain) IBOutlet UITableView *infosTableView;
@property (nonatomic, retain) NSMutableArray *menuList;

@property (nonatomic, assign) UIViewController *lastViewController;

@end
