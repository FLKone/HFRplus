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

    self.title = @"Live";
    self.tabBarItem.title = @"Live";

    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLive)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;

}

-(void)cancelLive {
    NSLog(@"cancelLive");
}

@end
