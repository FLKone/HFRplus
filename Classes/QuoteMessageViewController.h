//
//  QuoteMessageViewController.h
//  HFR+
//
//  Created by Lace on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMessageViewController.h"

@interface QuoteMessageViewController : AddMessageViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate> {
	NSString *urlQuote;
	
	UIPickerView		*myPickerView;
	NSMutableArray				*pickerViewArray;
	UIActionSheet		*actionSheet;
	
	UIButton		*catButton;
}
@property (nonatomic, retain) NSString *urlQuote;

@property (nonatomic, retain) UIPickerView *myPickerView;
@property (nonatomic, retain) NSMutableArray *pickerViewArray;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIButton *catButton;

-(void)showPicker;
- (CGRect)pickerFrameWithSize:(CGSize)size;
-(void)dismissActionSheet;

-(void)loadDataInTableView:(NSData *)contentData;

@end