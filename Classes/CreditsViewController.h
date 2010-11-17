//
//  CreditsViewController.h
//  HFR+
//
//  Created by Lace on 25/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreditsViewController : UIViewController <UIWebViewDelegate> {
	UIWebView* myWebView;
}
@property (nonatomic, retain) IBOutlet UIWebView* myWebView;

@end
