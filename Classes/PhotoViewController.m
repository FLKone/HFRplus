//
//  PhotoViewController.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "HFRplusAppDelegate.h"

#import "PhotoViewController.h"
#import "ImageScrollView.h"
#import "HTMLNode.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+WebCache.h"

#define PADDING  10

@implementation PhotoViewController
@synthesize delegate;
@synthesize pagingScrollView, navigationBar, imageURL, imageData, __count, visibleIndex, loaded, isRotate, bottomBar;//, imageView
@synthesize isToolbarScrolling, selectedIndex;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
	 // ...
	 // Pass the selected object to the new view controller.
 }
 return self;
 }
 */

- (void)loadView 
{        
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageDownloaderPhotos:)
												 name:@"imageDownloadedPhotos" object:nil];

	[super loadView];
	
	[self setWantsFullScreenLayout:YES];

	self.__count = NSNotFound;
	self.loaded = NO;
	self.isRotate = NO;
	self.isToolbarScrolling = NO;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [pagingScrollView addGestureRecognizer:singleTap];
    [singleTap release];
	
	//NSLog(@"loadView");
	
    // Step 1: make the outer paging scroll view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	
	pagingScrollView.frame = pagingScrollViewFrame;
	//[pagingScrollView.layer setBorderColor: [[UIColor yellowColor] CGColor]];
	//[pagingScrollView.layer setBorderWidth: 1.0];
	
    //pagingScrollView.backgroundColor = [UIColor redColor];
    
    pagingScrollView.pagingEnabled = YES;
	
	pagingScrollView.clipsToBounds = NO;
	
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * [self imageCount],
                                              pagingScrollViewFrame.size.height);
	
	pagingScrollView.delegate = self;
	//pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	//pagingScrollView.backgroundColor = [UIColor blueColor];
	
	[[[navigationBar items] objectAtIndex:2] setTitle:[NSString stringWithFormat:@"1 sur %d", [self imageCount]]];
	
    // Step 2: prepare to tile content
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
	
	[self tilePages];

    CGRect pagingScrollViewFrame2 = pagingScrollView.frame;
    [pagingScrollView setContentOffset:CGPointMake((pagingScrollViewFrame2.size.width * selectedIndex), 0.0) animated:NO];
    
    [self updateBars];
    

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//NSLog(@"viewDidLoad");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	
	
}

- (void)viewWillDisappear:(BOOL)animated {	
    [super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  

    
	isRotate = YES;
	
	visibleIndex = [[visiblePages anyObject] index];
	//NSLog(@"visible before %d", visibleIndex);

	//for (ImageScrollView *page in recycledPages) {
		//NSLog(@"recycled %d", page.index);
		//page.hidden = YES;
	//}	
	
	if (loaded) { // Do not hide bars on first rotation
		[self hideBars];
	}

	loaded = YES;
  
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{


    
    pagingScrollView.contentSize = CGSizeMake(pagingScrollView.frame.size.width * [self imageCount],
                                              pagingScrollView.frame.size.height);
	
	//NSLog(@"didRotateFromInterfaceOrientation");
	
	// Re-configure visible pages
	for (ImageScrollView *page in visiblePages) {
        [self reconfigurePage:page forIndex:page.index];
    }	

	CGRect pagingScrollViewFrame = pagingScrollView.frame;
	[pagingScrollView setContentOffset:CGPointMake((pagingScrollViewFrame.size.width * visibleIndex), 0.0) animated:NO];

	//[UIView beginAnimations:nil context:nil];
	//[UIView setAnimationDuration:0.2];		
	//[pagingScrollView setAlpha:1];
	//[UIView commitAnimations];

	//for (ImageScrollView *page in recycledPages) {
	//	page.hidden = NO;
	//}	
	//NSLog(@"rotate End");
	isRotate = NO;
      
}	

- (void)cancel {
	[self.delegate photoViewControllerDidFinish:self];	
}

#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    //NSLog(@"handleSingleTap");
	[self switchBars];
}

#pragma mark -
#pragma mark Toolbars configuration

-(void)showBars {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[navigationBar setAlpha:1];
	[bottomBar setAlpha:1];
	
	[UIView commitAnimations];	
}

-(void)hideBars {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];		
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[navigationBar setAlpha:0];
	[bottomBar setAlpha:0];
	
	[UIView commitAnimations];	
}
-(void)switchBars {
	
	if ([[UIApplication sharedApplication] isStatusBarHidden])
		[self showBars];
	else 
		[self hideBars];
	
}

-(void)imageDownloaderPhotos: (NSNotification *) notification {
	//NSLog(@"imageDownloaderPhotos %@", notification);
	//NSLog(@"index %@", [notification object]);

	int index = [[visiblePages anyObject] index];

	if (index == [[notification object] intValue]) {
		//NSLog(@"OK %d", index);
		
		if ([[visiblePages anyObject] isOK]) {
			//NSLog(@"isOK");
			
			[[[bottomBar items] objectAtIndex:0] setEnabled:YES];
		}
		else {
			[[[bottomBar items] objectAtIndex:0] setEnabled:NO];
			
		}
	}

}

-(void)updateBars {
	//NSLog(@"refreshArrow");
	int index = [[visiblePages anyObject] index];
	
	if ([[visiblePages anyObject] isOK]) {
		[[[bottomBar items] objectAtIndex:0] setEnabled:YES];
	}
	else {
		[[[bottomBar items] objectAtIndex:0] setEnabled:NO];

	}
	
	int curP = index + 1;
	int lastP = [self imageCount];
	
	[[[navigationBar items] objectAtIndex:2] setTitle:[NSString stringWithFormat:@"%d sur %d", curP, lastP]];
	
	if (curP > 1) {
		//NSLog(@"previous");
		[[[bottomBar items] objectAtIndex:2] setEnabled:YES];
	}
	else {
		//NSLog(@"pas previous");
		[[[bottomBar items] objectAtIndex:2] setEnabled:NO];

	}

	if (curP < lastP) {
		//NSLog(@"next");
		[[[bottomBar items] objectAtIndex:4] setEnabled:YES];
	}
	else {
		//NSLog(@"pas next");
		[[[bottomBar items] objectAtIndex:4] setEnabled:NO];
		
	}
	

	if ([[self urlAtIndex:index] length] > 0) {
		[[[bottomBar items] objectAtIndex:6] setEnabled:YES];
	}
	else {
		[[[bottomBar items] objectAtIndex:6] setEnabled:NO];
	}


	
}
-(IBAction)nextImage {
	if (!self.isToolbarScrolling) {
		
		int curP = [[visiblePages anyObject] index] + 1;
		int lastP = [self imageCount];
		
		if (curP < lastP) {

			self.isToolbarScrolling = YES;
	
			CGRect pagingScrollViewFrame = pagingScrollView.frame;
			[pagingScrollView setContentOffset:CGPointMake((pagingScrollViewFrame.size.width * curP), 0.0) animated:YES];
		}
	}

}
-(IBAction)previousImage {
	if (!self.isToolbarScrolling) {
		//NSLog(@"previousImage OK");

		int curP = [[visiblePages anyObject] index] + 1;
		//NSLog(@"curP %d", curP);

		if (curP > 1) {
			//NSLog(@"previousImage KO");

			self.isToolbarScrolling = YES;

			CGRect pagingScrollViewFrame = pagingScrollView.frame;
			[pagingScrollView setContentOffset:CGPointMake((pagingScrollViewFrame.size.width * (curP - 2)), 0.0) animated:YES];
		}
	}
}
-(IBAction)showActions {
	//NSLog(@"showActions %@", [visiblePages anyObject]);
    //int index = [[[visiblePages anyObject] subviews] objectAtIndex:0];
	
	if ([[visiblePages anyObject] isOK]) {
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		
		UIImage *tmpImg = [(UIImageView *)[[visiblePages anyObject] viewForZoomingInScrollView:nil] image];
		[library writeImageToSavedPhotosAlbum:[tmpImg CGImage] orientation:(ALAssetOrientation)[tmpImg imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
			if (error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Erreur lors de l'enregistrement"
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[alert release];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"L'image a été sauvegardée."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[alert release];
			}
		}];
		
		[library release];
	}
	
}

-(IBAction)loadUrl {
	int index = [[visiblePages anyObject] index];

	//NSLog(@"loadUrl %@", [self urlAtIndex:index]);
	[[HFRplusAppDelegate sharedAppDelegate] openURL:[self urlAtIndex:index]];
}
#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages 
{

	//NSLog(@"tilePages");
	
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
	
	//NSLog(@"%d - %d", firstNeededPageIndex, lastNeededPageIndex);
	
	
    // Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }

    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[ImageScrollView alloc] init] autorelease];
				//[page.layer setBorderColor: [[UIColor whiteColor] CGColor]];
				//[page.layer setBorderWidth: 1.0];
            }
			
			if (self.isRotate && index != visibleIndex) {
				//NSLog(@"added HIDDEN %d", index);

				page.hidden = YES;
			}
			else {
				//NSLog(@"added NORMAL %d", index);

				page.hidden = NO;
			}

            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    } 

}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
	//NSLog(@"configurePage %d", index);
	
    //NSLog(@"4 configurePage BEGIN bounds.size %f - %f", page.bounds.size.width, page.bounds.size.height);    
    
    
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
	
	//NSLog(@"self.view.frame %f %f - %f %f",	self.view.frame.origin.x, self.view.frame.origin.y,
	//	  self.view.frame.size.width, self.view.frame.size.height);
    
	//NSLog(@"page.frame %f %f - %f %f",	page.frame.origin.x, page.frame.origin.y,
	//	  page.frame.size.width, page.frame.size.height);
    
    [page displayImage:[self imageAtIndex:index]];
    
    //NSLog(@"4 configurePage END bounds.size %f - %f", page.bounds.size.width, page.bounds.size.height);    
    
}

- (void)reconfigurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
	//NSLog(@"reconfigurePage %d", index);


    page.index = index;
	
	CGRect pagingScrollViewFrame = pagingScrollView.frame;
	
    
    CGRect pageFrame = pagingScrollViewFrame;
    
    
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + PADDING;
    //pageFrame.origin.x = 0;
	
	

    page.frame = pageFrame;
	

    
	//NSLog(@"self.view.frame %f %f - %f %f",	self.view.frame.origin.x, self.view.frame.origin.y,
	//	  self.view.frame.size.width, self.view.frame.size.height);
    
	//NSLog(@"page.frame %f %f - %f %f",	page.frame.origin.x, page.frame.origin.y,
	//	  page.frame.size.width, page.frame.size.height);
    
    [page displayImage:[self imageAtIndex:index]];
    
    
}


#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidEndDecelerating");
	[self updateBars];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidScroll");
	if (!self.isToolbarScrolling) {
		[self hideBars];
	}		

	[self tilePages];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidEndScrollingAnimation");
	[self updateBars];

	self.isToolbarScrolling = NO;
}
#pragma mark -
#pragma mark  Frame calculations

- (CGRect)frameForPagingScrollView {
    

    CGRect frame = [[UIScreen mainScreen] bounds];
	
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    //CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	
	CGRect pagingScrollViewFrame = pagingScrollView.frame;

	//NSLog(@"pagingScrollViewFrame %d %f %f - %f %f", index, pagingScrollViewFrame.origin.x, pagingScrollViewFrame.origin.y,
	//	  pagingScrollViewFrame.size.width, pagingScrollViewFrame.size.height);	
	
    CGRect pageFrame = pagingScrollViewFrame;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + PADDING;
	
	//NSLog(@"pageFrame %d %f %f - %f %f", index, pageFrame.origin.x, pageFrame.origin.y,
	//	  pageFrame.size.width, pageFrame.size.height);
	
    return pageFrame;
}

#pragma mark -
#pragma mark Image wrangling
	 
- (NSString *)imageAtIndex:(NSUInteger)index {
	 // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
	 //NSString *path = self.imageURL;
	 NSString *path = [[[self imageData] objectAtIndex:index] objectForKey:@"alt"];
	 return path;//[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];    
}
	 
- (NSString *)urlAtIndex:(NSUInteger)index {
    // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
    //NSString *path = self.imageURL;
    NSString *path = [[[self imageData] objectAtIndex:index] objectForKey:@"longdesc"];
    return path;//[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];    
}

- (NSUInteger)imageCount {
	
    if (__count == NSNotFound) {
        __count = [[self imageData] count];
    }
	
    return __count;
}

#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	//NSLog(@"viewDidUnload");
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [pagingScrollView release];
    pagingScrollView = nil;	
	
    [navigationBar release];
    navigationBar = nil;		
	
	[bottomBar release];
	bottomBar = nil;	
	
    [recycledPages release];
    recycledPages = nil;
    [visiblePages release];
    visiblePages = nil;
	
}

- (void)dealloc {
	//NSLog(@"dealloc");
    [super dealloc];
	//[self viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageDownloadedPhotos" object:nil];

	[pagingScrollView release];	
	[navigationBar release];
	[imageData release];
}


@end
