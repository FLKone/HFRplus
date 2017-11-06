//
//  MigrationViewController.h
//  HFRplus
//
//  Created by FLK on 05/11/2017.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface MigrationViewController : UIViewController <UIWebViewDelegate> {
    UIWebView* myWebView;
    MIGVERSION fromVersion;
    MIGAPP forApp;
}

@property (nonatomic, strong) IBOutlet UIWebView* myWebView;
@property MIGVERSION fromVersion;
@property MIGAPP forApp;

@end
