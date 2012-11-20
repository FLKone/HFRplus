//
//  PayViewController.h
//  HFRplus
//
//  Created by FLK on 22/01/11.
//

#import <UIKit/UIKit.h>


@interface PayViewController : UIViewController {
	NSTimer *periodicMaintenanceTimer;
    IBOutlet UIButton *resutsBtn;

}
@property (retain, nonatomic) IBOutlet UIButton *resutsBtn;

- (IBAction) achat;
- (void)periodicCheck;
- (IBAction)gotohfrplus;

@end
