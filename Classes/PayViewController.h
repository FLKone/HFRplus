//
//  PayViewController.h
//  HFRplus
//
//  Created by FLK on 22/01/11.
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
