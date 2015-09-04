//
//  TestViewController.h
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import <UIKit/UIKit.h>
@protocol TestModoViewControllerDelegate;

@interface TestViewController : UIViewController {
    id <TestModoViewControllerDelegate> delegate;
    NSString *url;
    IBOutlet UITextView *textView;
}

@property (nonatomic, assign) id <TestModoViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (retain, nonatomic) IBOutlet UITextView *textView;

@end

@protocol TestModoViewControllerDelegate
- (void)alertModoViewControllerDidFinish:(TestViewController *)controller;
- (void)alertModoViewControllerDidFinishOK:(TestViewController *)controller;
@end