//
//  BrowserViewController.h
//  HFRplus
//
//  Created by FLK on 19/06/11.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol BrowserViewControllerDelegate;

@interface BrowserViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> {
    id <BrowserViewControllerDelegate> __weak delegate;
    
	UIWebView* myWebView;
	WKWebView* myModernWebView;
	NSString* currentUrl;
    
    BOOL fullBrowser;
    BOOL needDismiss;

}

@property (nonatomic, strong) UIWebView * myWebView;
@property (nonatomic, strong) WKWebView * myModernWebView;
@property (nonatomic, strong) NSString* currentUrl;
@property (nonatomic, weak) id <BrowserViewControllerDelegate> delegate;
@property BOOL fullBrowser;
@property BOOL needDismiss;

-(IBAction)cancel;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSString *)theURL;
- (id)initWithURL:(NSString *)theURL;

@end