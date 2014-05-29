//
//  BrowserViewController.m
//  HFRplus
//
//  Created by FLK on 19/06/11.
//

#import "BrowserViewController.h"
#import "HFRplusAppDelegate.h"
#import "RangeOfCharacters.h"


@implementation BrowserViewController
@synthesize delegate, myWebView, currentUrl, fullBrowser;


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (![self.title isEqualToString:theTitle]) {
        self.title = theTitle;
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSString *)theURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentUrl = [NSString stringWithString:theURL];
        self.fullBrowser = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    NSLog(@"deallocdeallocdeallocdeallocdealloc");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)cancel {
    [self viewDidUnload];
    
    if (self.fullBrowser && [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController respondsToSelector:@selector(MoveRightToLeft)]) {
        [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController MoveLeftToRight];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
        //[self.delegate browserViewControllerDidFinish:self];
    }
}

- (void)navPlus {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[HFRplusAppDelegate sharedAppDelegate].splitViewController respondsToSelector:@selector(MoveRightToLeft:)])
    {
        if ([[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
            //on load
            [((BrowserViewController *)[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController).myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.myWebView.request.URL.absoluteString]]];
        }
        else {
            //on move/decale
            //[self cancel];
            [[HFRplusAppDelegate sharedAppDelegate].splitViewController MoveRightToLeft:self.myWebView.request.URL.absoluteString];

        }
        [self dismissModalViewControllerAnimated:NO];

    }
}

- (void)reload {
    [self.myWebView reload];
}

#pragma mark - View lifecycle
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.currentUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C25 Safari/419.3" forHTTPHeaderField:@"User-Agent"];

    [self.myWebView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
    

    if (!self.fullBrowser) {
        // close
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
        self.navigationItem.leftBarButtonItem = doneButton;
    }
    
    
    // reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
	
    NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:segmentBarItem, nil];
    [segmentBarItem release];
    
    if (self.fullBrowser) {
        
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
        
        [myButtonArray addObject:doneButton];
        [doneButton release];
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIBarButtonItem *navPButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigateur✚", nil) style:UIBarButtonItemStylePlain target:self action:@selector(navPlus)] autorelease];
        
        [myButtonArray addObject:navPButton];
        [navPButton release];
    }
    
	self.navigationItem.rightBarButtonItems = myButtonArray;
    
    
    [[self.myWebView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    [[self.myWebView scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];


    [segmentBarItem release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	[self.myWebView stopLoading];

	self.myWebView.delegate = nil;
	self.myWebView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if (![enabled isEqualToString:@"none"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

@end
