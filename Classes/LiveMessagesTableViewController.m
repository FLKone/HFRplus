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
    self.gestureEnabled = YES;
    self.paginationEnabled = YES;
    self.autoUpdate = YES;

    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = nil;
}

@end
