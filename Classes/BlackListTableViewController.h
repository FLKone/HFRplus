//
//  BlackListTableViewController.h
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface BlackListTableViewController : UITableViewController <UIAlertViewDelegate> {
    NSMutableArray *blackListDict;
}

@property (nonatomic, retain) NSMutableArray *blackListDict;

@end
