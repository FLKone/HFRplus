//
//  OptionsTopicViewController.h
//  HFRplus
//
//  Created by Lace on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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