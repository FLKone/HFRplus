//
//  SettingsViewController.h
//  HFRplus
//
//  Created by FLK on 05/07/12.
//

#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"

@interface SettingsViewController : IASKAppSettingsViewController <IASKSettingsDelegate, UIAlertViewDelegate, UITableViewDelegate> {
    
}

@property (nonatomic, strong) NSString *theme;

@end
