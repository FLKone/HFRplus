//
//  AlerteModoViewController.h
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "UITextView+Placeholder.h"

@protocol AlerteModoViewControllerDelegate;

@interface AlerteModoViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate>{
    id <AlerteModoViewControllerDelegate> __weak delegate;
    
    IBOutlet UITextView *textView;
    
    IBOutlet UIView *loadingView;
    IBOutlet UIView *__weak accessoryView;
    
    NSString *url;
    ASIHTTPRequest *request;
    NSMutableDictionary *arrayInputData;
    NSString *formSubmit;
}
@property (nonatomic, weak) id <AlerteModoViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *accessoryView;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) NSMutableDictionary *arrayInputData;
@property (nonatomic, strong) NSString *formSubmit;

@end

@protocol AlerteModoViewControllerDelegate
- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller;
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller;
@end