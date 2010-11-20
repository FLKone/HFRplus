//
//  AddMessageViewController.h
//  HFR+
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
	
	//UIScrollView *scrollViewer;
	UITextField *textFieldSmileys;

	
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

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControler;
@property (nonatomic, retain) IBOutlet UITextField *textFieldSmileys;

//@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewer;


@property (nonatomic, retain) NSMutableDictionary *arrayInputData;
@property (nonatomic, retain) NSString *formSubmit;

@property NSRange lastSelectedRange;
@property BOOL loaded;
@property BOOL isDragging;

@property (nonatomic, assign) IBOutlet UIView *accessoryView;

-(IBAction)cancel;
-(IBAction)done;
-(IBAction)segmentFilterAction:(id)sender;

-(void)fetchSmileys;
-(void)didSelectSmile:(NSString *)smile;
-(void)initData;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)setupResponder;

@end

@protocol AddMessageViewControllerDelegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller;
- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller;
@end