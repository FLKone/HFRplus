//
//  AideViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "AideViewController.h"
#import "UIWebView+Tools.h"
#import "HFRplusAppDelegate.h"

@implementation AideViewController
@synthesize myWebView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Aide";

    [super viewDidLoad];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [myWebView loadHTMLString:@"" baseURL:baseURL];

	[self.myWebView hideGradientBackground];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.myWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	
	[super viewDidAppear:animated];

    //v1
	//[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"aide" ofType:@"html"] isDirectory:NO]]];

    //v2
    NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aide" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%d, got:%d | url:%@", UIWebViewNavigationTypeLinkClicked, navigationType, [aRequest.URL absoluteString]);
	
	return YES;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	[self.myWebView stopLoading];


	self.myWebView.delegate = nil;
	self.myWebView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	

}


- (void)dealloc {
	//NSLog(@"dealloc AVC");
	
	[self viewDidUnload];
	
}


@end
