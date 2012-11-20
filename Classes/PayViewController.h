//
//  PayViewController.h
//  HFRplus
//
//  Created by FLK on 22/01/11.
//

#import <UIKit/UIKit.h>


@interface PayViewController : UIViewController {
	NSTimer *periodicMaintenanceTimer;

}

- (IBAction) achat;
- (IBAction) data;
- (void)periodicCheck;
- (IBAction)gotohfrplus;

@end
