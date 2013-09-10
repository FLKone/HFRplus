//
//  HFRDebugViewController.m
//  HFRplus
//
//  Created by FLK on 20/07/12.
//

#import "HFRDebugViewController.h"
#import "HFRplusAppDelegate.h"

#include <assert.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

#import "ASIHTTPRequest.h"

#define kBenchUrlForum   @"http://forum.hardware.fr"
#define kBenchUrlCategorie   @"http://forum.hardware.fr/hfr/Hardware/liste_sujet-1.htm"
#define kBenchUrlTopic   @"http://forum.hardware.fr/hfr/apple/officiel-application-hfr-sujet_1711_1.htm"

@implementation HFRDebugViewController
@synthesize choixURL;

@synthesize textView, baseDate, dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.baseDate = [[NSDate alloc] init];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"SSS"];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Des Bugs";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setChoixURL:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
	
	if (![enabled isEqualToString:@"none"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)addText:(NSString *)text {
    dispatch_async( dispatch_get_main_queue(), ^{
        // running synchronously on the main thread now -- call the handler
        [self.textView setText:[NSString stringWithFormat:@"%f\t\t%@\n%@", [[NSDate date] timeIntervalSinceDate:self.baseDate], text, [self.textView text]]];

    });

}

-(NSString *)getURL {
    switch (self.choixURL.selectedSegmentIndex) {
        case 0:
            return kBenchUrlForum;
            break;
        case 1:
            return kBenchUrlCategorie;
            break;
        case 2:
            return kBenchUrlTopic;
            break;
        default:
            return @"http://121225";
            break;
    }
}

#pragma mark -
#pragma mark network_base

-(IBAction) network_base {

    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[self getURL]]
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    self.baseDate = [NSDate date];
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [self.textView setText:[NSString stringWithFormat:@"%f\t\t@NSURLConnection (%@)", [[NSDate date] timeIntervalSinceDate:self.baseDate], [self getURL]]];
        
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self addText:@"didReceiveResponse"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self addText:@"didReceiveData"];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self addText:@"didFailWithError"];


    // release the connection, and the data object
    [connection release];

    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self addText:@"connectionDidFinishLoading"];
    
    // release the connection, and the data object
    [connection release];
}

#pragma mark -
#pragma mark network_asi

-(IBAction) network_asi {
    ASIHTTPRequest *con = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getURL]]];
    
	[con setShouldRedirect:NO];

    [con setDelegate:self];

	[con setDidStartSelector:@selector(fetchContentStarted:)];
	[con setDidFinishSelector:@selector(fetchContentComplete:)];
	[con setDidFailSelector:@selector(fetchContentFailed:)];

    [con setDownloadProgressDelegate:self];
    [con setShowAccurateProgress:YES];

    self.baseDate = [NSDate date];
    [con startAsynchronous];
    [self.textView setText:[NSString stringWithFormat:@"%f\t\t@ASIHTTPRequest (%@)", [[NSDate date] timeIntervalSinceDate:self.baseDate], [self getURL]]];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    [self addText:@"fetchContentStarted"];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    [self addText:@"fetchContentComplete"];
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    [self addText:@"fetchContentFailed"];	
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
    [self addText:@"didReceiveBytes"];	
}

/*
#pragma mark -
#pragma mark network_af

-(IBAction) network_af {

    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[self getURL]]
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:60.0];    
    
    AFHTTPRequestOperation *con = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    
    [con setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [self addText:@"setDownloadProgressBlock"];
    }];
    
    [con setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self addText:@"setCompletionBlockWithSuccess"];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self addText:@"setCompletionBlockWithFailure"];
    }];
    
    self.baseDate = [NSDate date];
    [con start];
    [self.textView setText:[NSString stringWithFormat:@"%f\t\t@AFHTTPRequestOperation (%@)", [[NSDate date] timeIntervalSinceDate:self.baseDate], [self getURL]]];
}
*/

- (IBAction)changeURL:(id)sender {
}


- (void)dealloc {
    [choixURL release];
    [super dealloc];
}
@end
