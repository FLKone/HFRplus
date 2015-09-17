//
//  SubCatTableViewController.h
//  HFRplus
//
//  Created by FLK on 02/07/12.
//

#import <UIKit/UIKit.h>

@interface SubCatTableViewController : UITableViewController
{
    NSArray *arrayData;
    UIPickerView *suPicker;
    NSString *notification;
}

@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) UIPickerView *suPicker;
@property (nonatomic, strong) NSString *notification;

@end
