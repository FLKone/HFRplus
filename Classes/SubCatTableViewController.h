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
}

@property (nonatomic, retain) NSArray *arrayData;
@property (nonatomic, retain) UIPickerView *suPicker;

@end
