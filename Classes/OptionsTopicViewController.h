//
//  OptionsTopicViewController.h
//  HFRplus
//
//  Created by FLK on 11/08/11.
//

#import <UIKit/UIKit.h>

@protocol OptionsTopicViewControllerDelegate;

@interface OptionsTopicViewController : UIViewController {
    id <OptionsTopicViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <OptionsTopicViewControllerDelegate> delegate;
-(IBAction)repondre;

@end

@protocol OptionsTopicViewControllerDelegate
- (void)optionsTopicViewControllerDidFinish:(OptionsTopicViewController *)controller;
@end