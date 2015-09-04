//
//  AlerteModoViewController.h
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import <UIKit/UIKit.h>

@protocol AlerteModoViewControllerDelegate;

@interface AlerteModoViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate>{
    id <AlerteModoViewControllerDelegate> delegate;
    NSString *url;
    IBOutlet UITextView *textView;
}

@property (nonatomic, assign) id <AlerteModoViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (retain, nonatomic) IBOutlet UITextView *textView;

@end

@protocol AlerteModoViewControllerDelegate
- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller;
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller;
@end