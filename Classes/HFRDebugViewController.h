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

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSDate *baseDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UISegmentedControl *choixURL;

- (IBAction)MakeItRain:(id)sender;

-(IBAction) network_base;
-(IBAction) network_asi;
-(IBAction)changeURL:(id)sender;

@end
