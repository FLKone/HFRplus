//
//  BrowserViewController.h
//  HFRplus
//
//  Created by FLK on 19/06/11.
//

#import <UIKit/UIKit.h>
@protocol BrowserViewControllerDelegate;

@interface BrowserViewController : UIViewController <UIWebViewDelegate> {
    id <BrowserViewControllerDelegate> delegate;
    
	UIWebView* myWebView;
	NSString* currentUrl;
    
    BOOL fullBrowser;

}

@property (nonatomic, retain) IBOutlet UIWebView* myWebView;
@property (nonatomic, retain) NSString* currentUrl;
@property (nonatomic, assign) id <BrowserViewControllerDelegate> delegate;
@property BOOL fullBrowser;

-(IBAction)cancel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSString *)theURL;

@end



@protocol BrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(BrowserViewController *)controller;
@end