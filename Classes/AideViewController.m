//
//  AideViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "AideViewController.h"


@implementation AideViewController
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
	self.title = @"Aide";

    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	
	[super viewDidAppear:animated];
	
	//[myWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"]  encoding:NSASCIIStringEncoding error:NULL] baseURL:nil];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"aide" ofType:@"html"]isDirectory:NO]]];
	
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
	
    [super dealloc];
}


@end
