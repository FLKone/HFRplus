//
//  CreditsViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "CreditsViewController.h"


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
}

- (void)viewDidAppear:(BOOL)animated
{
	
	[super viewDidAppear:animated];
	
	//[myWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"]  encoding:NSASCIIStringEncoding error:NULL] baseURL:nil];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"] isDirectory:NO]]];
	
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

    [super dealloc];
}

#pragma mark -
#pragma mark WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%d, got:%d", UIWebViewNavigationTypeLinkClicked, navigationType);
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
		return NO;
	}
	
	return YES;
}

@end
