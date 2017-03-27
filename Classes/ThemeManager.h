//
//  ThemeManager.h
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface ThemeManager : NSObject{
    Theme theme;
}

@property Theme theme;

+ (id)sharedManager;
- (void)applyThemeToCell:(UITableViewCell *)cell;
- (void)applyThemeToTextField:(UITextField *)textfield;

@end
