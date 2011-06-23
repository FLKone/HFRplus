//
//  BrowserViewController.h
//  HFRplus
//
//  Created by Shasta on 19/06/11.
//  Copyright 2011 FLK. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BrowserViewControllerDelegate;

@interface BrowserViewController : UIViewController <UIWebViewDelegate> {
    id <BrowserViewControllerDelegate> delegate;
    
	UIWebView* myWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView* myWebView;
@property (nonatomic, assign) id <BrowserViewControllerDelegate> delegate;

-(IBAction)cancel;

@end



@protocol BrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(BrowserViewController *)controller;
@end