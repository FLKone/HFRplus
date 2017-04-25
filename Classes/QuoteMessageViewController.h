//
//  QuoteMessageViewController.h
//  HFRplus
//
//  Created by FLK on 17/08/10.
//

#import <UIKit/UIKit.h>
#import "AddMessageViewController.h"

@interface QuoteMessageViewController : AddMessageViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate> {
    NSString *urlQuote;
    NSString *textQuote;
	BOOL boldQuote;
    
	UIPickerView		*myPickerView;
	NSMutableArray				*pickerViewArray;
	UIActionSheet		*actionSheet;
	
	UIButton		*catButton;
}
@property (nonatomic, strong) NSString *urlQuote;
@property (nonatomic, strong) NSString *textQuote;
@property BOOL boldQuote;

@property (nonatomic, strong) UIPickerView *myPickerView;
@property (nonatomic, strong) NSMutableArray *pickerViewArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIButton *catButton;

-(void)showPicker:(id)sender;
- (CGRect)pickerFrameWithSize:(CGSize)size;
-(void)dismissActionSheet;

-(void)loadDataInTableView:(NSData *)contentData;

@end