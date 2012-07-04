//
//  AideViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <UIKit/UIKit.h>


@interface AideViewController : UIViewController <UIWebViewDelegate> {
	UIWebView* myWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView* myWebView;


@end
