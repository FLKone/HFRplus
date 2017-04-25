//
//  IdentificationViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <UIKit/UIKit.h>

@protocol IdentificationViewControllerDelegate;

@interface IdentificationViewController : UIViewController {
	id <IdentificationViewControllerDelegate> __weak delegate;

	IBOutlet UITextField *pseudoField;
	IBOutlet UITextField *passField;
    IBOutlet UILabel *titleLabel;
}
@property (nonatomic, weak) id <IdentificationViewControllerDelegate> delegate;

@property (nonatomic, strong) UITextField* pseudoField;
@property (nonatomic, strong) UITextField* passField;

-(IBAction) done:(id)sender;

-(IBAction) connexion;
-(void)finish;
-(void)finishOK;

- (IBAction)goToCreate;

@end


@protocol IdentificationViewControllerDelegate
- (void)identificationViewControllerDidFinish:(IdentificationViewController *)controller;
- (void)identificationViewControllerDidFinishOK:(IdentificationViewController *)controller;
@end