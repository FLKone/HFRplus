//
//  CompteViewController.h
//  HFR+
//
//  Created by Shasta on 12/08/10.
//

#import <UIKit/UIKit.h>
#import "IdentificationViewController.h"

@interface CompteViewController : UIViewController <IdentificationViewControllerDelegate> {
	UIView *compteView;
	UIView *loginView;
	UIButton *profilBtn;
}

@property (nonatomic, retain) IBOutlet UIView* compteView;
@property (nonatomic, retain) IBOutlet UIView* loginView;
@property (nonatomic, retain) IBOutlet UIButton* profilBtn;

- (void)checkLogin;
- (IBAction)login;
- (IBAction)logout;

- (IBAction)goToProfil;
@end
