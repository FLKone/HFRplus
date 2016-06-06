//
//  MessagesTableViewController.h
//  HFRplus
//
//  Created by FLK on 07/07/10.
//


#import <UIKit/UIKit.h>

#import "BaseMessagesTableViewController.h"

@class HTMLNode;

@interface MessagesTableViewController : BaseMessagesTableViewController {
    UIToolbar *aToolbar;
}

@property (nonatomic, strong) UIToolbar *aToolbar;
-(void)setupPageToolbar:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser;

@end
