//
//  PayViewController.h
//  HFRplus
//
//  Created by Shasta on 22/01/11.
//  Copyright 2011 FLK. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PayViewController : UIViewController {
	UIButton* resutsBtn;
	NSTimer *periodicMaintenanceTimer;

}
@property (nonatomic, retain) IBOutlet UIButton* resutsBtn;

- (IBAction) achat;
- (IBAction) data;
- (void)periodicCheck;

@end
