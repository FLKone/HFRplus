//
//  CompteViewController.h
//  HFRplus
//
//  Created by FLK on 12/08/10.
//

#import <UIKit/UIKit.h>
#import "IdentificationViewController.h"

@interface CompteViewController : UIViewController <IdentificationViewControllerDelegate> {
	UIView *compteView;
	UIView *loginView;
	UIButton *profilBtn;
}

@property (nonatomic, strong) IBOutlet UIView* compteView;
@property (nonatomic, strong) IBOutlet UIView* loginView;
@property (nonatomic, strong) IBOutlet UIButton* profilBtn;

- (void)checkLogin;
- (IBAction)login;
- (IBAction)logout;

- (IBAction)goToProfil;
@end
