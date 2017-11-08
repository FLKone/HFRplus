//
//  MigrationViewController.m
//  HFRplus
//
//  Created by FLK on 05/11/2017.
//
//

#import "MigrationViewController.h"
#import "HFRplusAppDelegate.h"
#import "UIWebView+Tools.h"
#import "ThemeColors.h"
#import "ThemeManager.h"

@implementation MigrationViewController
@synthesize myWebView, forApp, fromVersion;
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
    self.title = @"Annonce";

    [super viewDidLoad];

    [self.myWebView hideGradientBackground];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.myWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }

    //Bouton Finish
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    self.navigationItem.rightBarButtonItem = doneButton;



    UIBarButtonItem *maskButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Masquer", nil) style:UIBarButtonItemStyleDone target:self action:@selector(mask)];
    self.navigationItem.leftBarButtonItem = maskButton;



}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
    [self loadPage];
}

-(void)setThemeColors:(Theme)theme{
    [self.view setBackgroundColor:[ThemeColors greyBackgroundColor:theme]];
    [self.myWebView setBackgroundColor:[ThemeColors greyBackgroundColor:theme]];
    [self.myWebView setOpaque:NO];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];

    //v1
    //[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"] isDirectory:NO]]];



}

- (void)finish {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)mask {
    [self finish];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", defaults);

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"menu_migration"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSUserDefaults *defaults2 = [NSUserDefaults standardUserDefaults];
    BOOL mig = [defaults boolForKey:@"menu_migration"];

    if (mig) {
        NSLog(@"menu_migration = YES");
    } else {
        NSLog(@"menu_migration = NO");
    }

    NSLog(@"%@", defaults2);
}

-(void)loadPage {
    //v2
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];

    NSString *htmlString;

    if (self.forApp == kForRedface) {
        htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"migration.redface" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    } else {
        htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"migration.classic" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    }

    if (self.fromVersion == kFromLegacy) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@"legacy %%iosversion%%"];
    } else if (self.fromVersion == kFromModern) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@"modern %%iosversion%%"];
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@"ios7"];
    } else {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@""];
    }

    NSString *cssString = [ThemeColors creditsCss:[[ThemeManager sharedManager] theme]];
    //NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"; // 2
    // NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString]; // 3
    htmlString =[htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:[NSString stringWithFormat:@"<style>%@</style></head>", cssString]];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *cssString = [ThemeColors creditsCss:[[ThemeManager sharedManager] theme]];
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"; // 2
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString]; // 3
    [webView stringByEvaluatingJavaScriptFromString:javascriptWithCSSString]; // 4
}
@end
