//
//  MessageWebView.h
//  HFRplus
//
//  Created by Shasta on 02/05/13.
//
//

#import <UIKit/UIKit.h>
@class MessagesTableViewController;

@interface MessageWebView : UIWebView {
    MessagesTableViewController *controll;
}
@property (nonatomic, strong) MessagesTableViewController *controll;

@end
