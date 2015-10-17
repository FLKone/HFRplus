//
//  AddMessageViewController.h
//  HFRplus
//
//  Created by FLK on 16/08/10.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "FLWebViewProvider.h"
#import <WebKit/WebKit.h>
@protocol AddMessageViewControllerDelegate;

@interface AddMessageViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKNavigationDelegate, WKUIDelegate> {
	id <AddMessageViewControllerDelegate> __weak delegate;
	
	//bb
	UITextView *textView;
	
	NSMutableDictionary *arrayInputData;
	NSString *formSubmit;
	
	UIView *__weak accessoryView;

	NSRange lastSelectedRange;

	BOOL loaded; //to load data only once
    BOOL smileLoaded;
	BOOL isDragging;

    UIView <FLWebViewProvider> *smileView;
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
	
    //HFR REHOST
    UITableView *rehostTableView;
    NSMutableArray *rehostImagesArray;
    NSMutableArray* rehostImagesSortedArray;
    
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
    
    NSString *statusMessage;
}

@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, weak) id <AddMessageViewControllerDelegate> delegate;

@property (strong, nonatomic) ASIHTTPRequest *request;
@property (strong, nonatomic) ASIHTTPRequest *requestSmile;

//bb
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property BOOL haveCategory;
@property BOOL haveTitle;
@property BOOL haveTo;
@property (nonatomic, strong) UITextField *textFieldTitle;
@property (nonatomic, strong) UITextField *textFieldTo;
@property (nonatomic, strong) UITextField *textFieldCat;
@property int offsetY;

@property (nonatomic) UIView <FLWebViewProvider> *smileView;
@property (nonatomic, strong) NSString *smileyCustom;

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControler;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControlerPage;
@property (nonatomic, strong) IBOutlet UITextField *textFieldSmileys;
@property (nonatomic, strong) NSMutableArray *smileyArray;
@property int smileyPage;
@property (nonatomic, strong) IBOutlet UITableView *commonTableView;
@property (nonatomic, strong) NSMutableDictionary *usedSearchDict;
@property (nonatomic, strong) NSMutableArray *usedSearchSortedArray;

@property (nonatomic, strong) IBOutlet UITableView *rehostTableView;
@property (nonatomic, strong) NSMutableArray *rehostImagesArray;
@property (nonatomic, strong) NSMutableArray *rehostImagesSortedArray;

//@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewer;
@property (nonatomic, strong) id popover;
@property (nonatomic, strong) NSString *refreshAnchor;
@property (nonatomic, strong) NSString *statusMessage;


@property (nonatomic, strong) NSMutableDictionary *arrayInputData;
@property (nonatomic, strong) NSString *formSubmit;

@property NSRange lastSelectedRange;
@property BOOL loaded;
@property BOOL isDragging;
@property BOOL smileLoaded;

@property (nonatomic, weak) IBOutlet UIView *accessoryView;

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
-(bool)isDeleteMode;

@end

@protocol AddMessageViewControllerDelegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller;
- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller;
@end