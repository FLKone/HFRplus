//
//  LiveMessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 04/06/2016.
//
//

#import "LiveMessagesTableViewController.h"

@implementation LiveMessagesTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil andUrl:(NSString *)theTopicUrl])) {
        // Custom initialization
        NSLog(@"init %@", theTopicUrl);
        self.isLive = YES;
        self.gestureEnabled = NO;
        self.paginationEnabled = NO;
        self.autoUpdate = YES;
    }
    return self;
}

@end
