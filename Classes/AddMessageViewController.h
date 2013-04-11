//
//  AddMessageViewController.h
//  HFRplus
//
//  Created by FLK on 16/08/10.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@protocol AddMessageViewControllerDelegate;

@interface AddMessageViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIWebViewDelegate> {
	id <AddMessageViewControllerDelegate> delegate;
	
	//bb
	UITextView *textView;
	
	NSMutableDictionary *arrayInputData;
	NSString *formSubmit;
	
	UIView *accessoryView;

	NSRange lastSelectedRange;

	BOOL loaded; //to load data only once
	BOOL isDragging;

	UIWebView *smileView;
	UISegmentedControl *segmentControler;
	UISegmentedControl *segmentControlerPage;
	
	//UIScrollView *scrollViewer;
	UITextField *textFieldSmileys;
	NSMutableArray *smileyArray;
	int smileyPage;
	UITableView *commonTableView;
	NSMutableDictionary *usedSearchDict;
	NSMutableArray *usedSearchSortedArray;
    
    NSString *smileyCustom;
	
	BOOL haveTitle;
	UITextField *textFieldTitle;

	BOOL haveTo;
	UITextField *textFieldTo;
	
	BOOL haveCategory;
	UITextField *textFieldCat;
	
	int offsetY;

	IBOutlet UIView *loadingView;
	ASIHTTPRequest *request;
	ASIHTTPRequest *requestSmile;
	
    id _popover;    
	NSString *refreshAnchor;
    
}

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, assign) id <AddMessageViewControllerDelegate> delegate;

@property (retain, nonatomic) ASIHTTPRequest *request;
@property (retain, nonatomic) ASIHTTPRequest *requestSmile;

//bb
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property BOOL haveCategory;
@property BOOL haveTitle;
@property BOOL haveTo;
@property (nonatomic, retain) UITextField *textFieldTitle;
@property (nonatomic, retain) UITextField *textFieldTo;
@property (nonatomic, retain) UITextField *textFieldCat;
@property int offsetY;

@property (nonatomic, retain) IBOutlet UIWebView *smileView;
@property (nonatomic, retain) NSString *smileyCustom;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControler;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControlerPage;
@property (nonatomic, retain) IBOutlet UITextField *textFieldSmileys;
@property (nonatomic, retain) NSMutableArray *smileyArray;
@property int smileyPage;
@property (nonatomic, retain) IBOutlet UITableView *commonTableView;
@property (nonatomic, retain) NSMutableDictionary *usedSearchDict;
@property (nonatomic, retain) NSMutableArray *usedSearchSortedArray;

//@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewer;
@property (nonatomic, retain) id popover;
@property (nonatomic, retain) NSString *refreshAnchor;


@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) NSString *formSubmit;

@property NSRange lastSelectedRange;
@property BOOL loaded;
@property BOOL isDragging;

@property (nonatomic, assign) IBOutlet UIView *accessoryView;

-(IBAction)cancel;
-(IBAction)done;
-(IBAction)segmentFilterAction:(id)sender;
-(IBAction)textFieldSmileChange:(id)sender;

-(void)fetchSmileys;
-(void)loadSmileys:(int)page;
-(void)didSelectSmile:(NSString *)smile;
-(void)initData;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)setupResponder;

@end

@protocol AddMessageViewControllerDelegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller;
- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller;
@end