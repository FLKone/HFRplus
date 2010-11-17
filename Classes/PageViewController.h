//
//  PageViewController.h
//  HFRplus
//
//  Created by Shasta on 10/10/10.
//  Copyright 2010 FLK. All rights reserved.
//
#import <unistd.h>
#import <UIKit/UIKit.h>

#import "RangeOfCharacters.h"
#import "RegexKitLite.h"
#import <QuartzCore/QuartzCore.h>

@interface PageViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	NSString *currentUrl;	
	int pageNumber;
	
	//Header & Footer
	int firstPageNumber;
	int lastPageNumber;
	NSString *firstPageUrl;
	NSString *lastPageUrl;
	
	//Right Toolbar Items
	NSString *nextPageUrl;
	NSString *previousPageUrl;
	
	UITextField *pageNumberField;
}
@property (nonatomic, retain) NSString *currentUrl;
@property int pageNumber;

@property int firstPageNumber;
@property int lastPageNumber;
@property (nonatomic, retain) NSString *firstPageUrl;
@property (nonatomic, retain) NSString *lastPageUrl;

@property (nonatomic, retain) NSString *nextPageUrl;
@property (nonatomic, retain) NSString *previousPageUrl;

@property (nonatomic, retain) UITextField *pageNumberField;


-(void)choosePage;
-(void)goToPage:(NSString *)pageType;
-(void)gotoPageNumber:(int)number;
-(void)fetchContent;

-(void)nextPage:(id)sender;
-(void)previousPage:(id)sender;
-(void)firstPage:(id)sender;
-(void)lastPage:(id)sender;

@end
