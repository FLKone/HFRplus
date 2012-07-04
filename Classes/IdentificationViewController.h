//
//  IdentificationViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <UIKit/UIKit.h>

@protocol IdentificationViewControllerDelegate;

@interface IdentificationViewController : UIViewController {
	id <IdentificationViewControllerDelegate> delegate;

	IBOutlet UITextField *pseudoField;
	IBOutlet UITextField *passField;
}
@property (nonatomic, assign) id <IdentificationViewControllerDelegate> delegate;

@property (nonatomic, retain) UITextField* pseudoField;
@property (nonatomic, retain) UITextField* passField;

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