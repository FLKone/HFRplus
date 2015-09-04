//
//  AlerteModoViewController.h
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@protocol AlerteModoViewControllerDelegate;

@interface AlerteModoViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate>{
    id <AlerteModoViewControllerDelegate> delegate;
    
    IBOutlet UITextView *textView;
    
    IBOutlet UIView *loadingView;
    IBOutlet UIView *accessoryView;
    
    NSString *url;
    ASIHTTPRequest *request;
    NSMutableDictionary *arrayInputData;
    NSString *formSubmit;
}
@property (nonatomic, assign) id <AlerteModoViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, assign) IBOutlet UIView *accessoryView;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) NSString *formSubmit;

@end

@protocol AlerteModoViewControllerDelegate
- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller;
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller;
@end