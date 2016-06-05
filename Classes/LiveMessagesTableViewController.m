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
    self.isLive = YES;

    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = nil;

    self.title = @"Live";
    self.tabBarItem.title = @"Live";

    UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionsLive:)];
    optionsBarItem.enabled = NO;

    NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];

    self.navigationItem.rightBarButtonItems = myButtonArray;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInBackground:) name:@"appInBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInForeground:) name:@"appInForeground" object:nil];

}

-(void)optionsLive:(id)sender {
    NSLog(@"cancelLive");


    [self.arrayActionsMessages removeAllObjects];

    [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Mettre fin au Live", @"stopLive", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.parentViewController isMemberOfClass:[UINavigationController class]]) {
        // olol
    }

    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:styleAlert.numberOfButtons-1 animated:YES];
        return;
    }
    else {
        styleAlert = [[UIActionSheet alloc] init];
    }

    styleAlert.delegate = self;

    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    for( NSDictionary *dico in arrayActionsMessages)
        [styleAlert addButtonWithTitle:[dico valueForKey:@"title"]];

    [styleAlert addButtonWithTitle:@"Annuler"];
    styleAlert.cancelButtonIndex = styleAlert.numberOfButtons-1;

    // use the same style as the nav bar
    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    [styleAlert showFromBarButtonItem:sender animated:YES];

}

-(void)stopLive {
    NSLog(@"stop Live");

    [self stopTimer];

    NSMutableArray *currCtrls = [NSMutableArray arrayWithArray:[HFRplusAppDelegate sharedAppDelegate].rootController.viewControllers];

    [currCtrls removeObjectAtIndex:3];

    [[HFRplusAppDelegate sharedAppDelegate].rootController setViewControllers:currCtrls animated:YES];
    [[HFRplusAppDelegate sharedAppDelegate].rootController setSelectedIndex:1];

}


-(void)appInBackground:(NSNotification *)notification {
    NSLog(@"appInBackground");
    [self stopTimer];
}

-(void)appInForeground:(NSNotification *)notification {
    NSLog(@"appInForeground");

    [self setupTimer:10];
}


@end
