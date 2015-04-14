//
//  BrowserViewController.m
//  HFRplus
//
//  Created by FLK on 19/06/11.
//

#import "BrowserViewController.h"
#import "HFRplusAppDelegate.h"
#import "RangeOfCharacters.h"
#import <WebKit/WebKit.h>


@implementation BrowserViewController
@synthesize delegate, myWebView, currentUrl, fullBrowser, myModernWebView;


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

- (void)webView:(WKWebView *)localWebView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)localWebView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [localWebView evaluateJavaScript:[NSString stringWithFormat:@"document.title"] completionHandler:^(id response, NSError *error) {
        if (![self.title isEqualToString:response]) {
            self.title = response;
        }
    }];

    
}


- (id)initWithURL:(NSString *)theURL
{
    self = [super init];
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
    //NSLog(@"deallocdeallocdeallocdeallocdealloc");
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
            if ([WKWebView class]) {
                [((BrowserViewController *)[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController).myModernWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.myModernWebView.URL.absoluteString]]];

            }
            else {
                [((BrowserViewController *)[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController).myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.myWebView.request.URL.absoluteString]]];
                
            }
        }
        else {
            //on move/decale
            //[self cancel];
            if ([WKWebView class]) {
                [[HFRplusAppDelegate sharedAppDelegate].splitViewController MoveRightToLeft:self.myModernWebView.URL.absoluteString];
            }
            else {
                [[HFRplusAppDelegate sharedAppDelegate].splitViewController MoveRightToLeft:self.myWebView.request.URL.absoluteString];
            }


        }
        [self cancel];
    }
}

- (void)reload {
    [self.myWebView reload];
    [self.myModernWebView reload];
}

- (void)goBack {
    [self.myWebView goBack];
    [self.myModernWebView goBack];
}

- (void)goForward {
    [self.myWebView goForward];
    [self.myModernWebView goForward];
}

#pragma mark - View lifecycle
- (BOOL)prefersStatusBarHidden{
    return NO;
}

-(void)loadView {
    
    UIView *view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
    if ([WKWebView class]) {
        myModernWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        myModernWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        myModernWebView.navigationDelegate = self;
        myModernWebView.allowsBackForwardNavigationGestures = YES;
        
        [self.view addSubview:myModernWebView];
    }
    else {
        myWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        myWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        myWebView.delegate = self;
        myWebView.scalesPageToFit = YES;
        
        [self.view addSubview:myWebView];
    }
    
    CGRect toolbarFrame = self.view.frame;
    toolbarFrame.size.height = 44;
    toolbarFrame.origin.y = self.view.frame.size.height - 44;
    toolbarFrame.origin.x = 0;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    
    
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowback"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];

    UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowforward"] style:UIBarButtonItemStyleBordered target:self action:@selector(goForward)];

    
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    
    //Add buttons to the array
    NSArray *items = [NSArray arrayWithObjects: systemItem1, flexItem, systemItem2, nil];
    
    //release buttons
    [systemItem1 release];
    [systemItem2 release];
    [flexItem release];
    
    //add array of buttons to toolbar
    [toolbar setItems:items animated:NO];
    
    [self.view addSubview:toolbar];
    [toolbar release];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.currentUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //[request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C25 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    if ([WKWebView class]) {
        [self.myModernWebView loadRequest:request];
    }
    else {
        [self.myWebView loadRequest:request];
    }

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
    
    if ([WKWebView class]) {
        [[self.myModernWebView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
        [[self.myModernWebView scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    }
    else {
        [[self.myWebView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
        [[self.myWebView scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    }

    [segmentBarItem release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.

    if ([WKWebView class]) {
        [self.myModernWebView stopLoading];
        self.myModernWebView.navigationDelegate = nil;
    }
    else {
        [self.myWebView stopLoading];
        self.myWebView.delegate = nil;
    }
    
    self.myWebView = nil;
    self.myModernWebView = nil;
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
