//
//  HFRDebugViewController.h
//  HFRplus
//
//  Created by FLK on 20/07/12.
//

#import <UIKit/UIKit.h>

@interface HFRDebugViewController : UIViewController
{
    UITextView *textView;
    NSDate *baseDate;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSDate *baseDate;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (retain, nonatomic) IBOutlet UISegmentedControl *choixURL;


-(IBAction) network_base;
-(IBAction) network_asi;
-(IBAction)changeURL:(id)sender;
- (IBAction)debug_notif:(id)sender;

@end
