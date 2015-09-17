//
//  CreditsViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "CreditsViewController.h"
#import "HFRplusAppDelegate.h"
#import "UIWebView+Tools.h"


@implementation CreditsViewController
@synthesize myWebView;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Crédits";

    [super viewDidLoad];
    
	[self.myWebView hideGradientBackground];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.myWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	
	[super viewDidAppear:animated];

    //v1
	//[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"] isDirectory:NO]]];
    
    //v2
    NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@"ios7"];
    }
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@""];

	[myWebView loadHTMLString:htmlString baseURL:baseURL];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[self.myWebView stopLoading];

	self.myWebView.delegate = nil;
	self.myWebView = nil;

}


- (void)dealloc {
	//NSLog(@"dealloc CVC");
	
	[self viewDidUnload];

}

#pragma mark -
#pragma mark WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%d, got:%d", UIWebViewNavigationTypeLinkClicked, navigationType);
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;
        [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
		return NO;
	}
	
	return YES;
}

@end
