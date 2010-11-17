//
//  PhotoViewController.h
//  HFRplus
//
//  Created by Shasta on 17/09/10.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewControllerDelegate;
@class ImageScrollView;


@interface PhotoViewController : UIViewController <UIScrollViewDelegate> {
	id <PhotoViewControllerDelegate> delegate;
	
	IBOutlet UIScrollView *pagingScrollView;
	IBOutlet UIToolbar *navigationBar;
	IBOutlet UIToolbar *bottomBar;
	
	NSString *imageURL;
	
	
	NSArray *imageData;
	
	NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	
	NSUInteger __count;
	NSUInteger visibleIndex;
	BOOL loaded;
	BOOL isRotate;
	BOOL isToolbarScrolling;

}
@property (nonatomic, assign) id <PhotoViewControllerDelegate> delegate;
@property (nonatomic, retain) UIScrollView *pagingScrollView;
@property (nonatomic, retain) UIToolbar *navigationBar;
@property (nonatomic, retain) UIToolbar *bottomBar;

@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSArray *imageData;

@property NSUInteger __count;
@property NSUInteger visibleIndex;
@property BOOL loaded;
@property BOOL isRotate;
@property BOOL isToolbarScrolling;

-(IBAction)cancel;

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (void)reconfigurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;

- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForPagingScrollView;

- (NSString *)imageAtIndex:(NSUInteger)index;
- (NSString *)urlAtIndex:(NSUInteger)index;
- (NSUInteger)imageCount;

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;

-(void)switchBars;
-(void)showBars;
-(void)hideBars;
-(void)updateBars;

-(IBAction)nextImage;
-(IBAction)previousImage;
-(IBAction)showActions;
-(IBAction)loadUrl;

@end


@protocol PhotoViewControllerDelegate
- (void)photoViewControllerDidFinish:(PhotoViewController *)controller;
@end