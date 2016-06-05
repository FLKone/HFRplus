//
//  LiveMessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 04/06/2016.
//
//

#import "LiveMessagesTableViewController.h"

@implementation LiveMessagesTableViewController

- (void)viewDidLoad {
    NSLog(@"LvDid %@", self.topicName);
    self.gestureEnabled = NO;
    self.paginationEnabled = NO;
    self.autoUpdate = YES;

    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = nil;

    self.tabBarItem.title = @"Live";
}

@end
