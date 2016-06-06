//
//  LiveMessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 04/06/2016.
//
//

#import "LiveMessagesTableViewController.h"

@implementation LiveMessagesTableViewController
// Live
@synthesize liveTimer;

#pragma mark -
#pragma mark Data lifecycle

- (void)fetchContent:(int)from
{
    [self stopTimer];

    [super fetchContent:from];
}
-(void)dealloc {
    [self stopTimer];
}

#pragma mark -
#pragma mark View lifecycle management

- (void)viewDidLoad {
    NSLog(@"LvDid %@", self.topicName);
    self.gestureEnabled = NO;

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

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"viewDidAppear");

    [super viewDidAppear:animated];

    if (!self.firstLoad) {

        [self stopTimer];
        [self setupTimer:2];
    }

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

-(void)newMessagesAutoAdded:(int)number {
    NSLog(@"newMessagesAutoAdded %d", number);

    if (self.tabBarController.selectedIndex != 3) {

        [self stopTimer];

        //  NSLog(@">> %@ < %@", self.tabBarItem, [NSString stringWithFormat:@"%d", [self.tabBarItem.badgeValue intValue] + number]);
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           int curV = [[[[HFRplusAppDelegate sharedAppDelegate].rootController tabBar] items] objectAtIndex:3].badgeValue.intValue;
                           [[[[[HFRplusAppDelegate sharedAppDelegate].rootController tabBar] items] objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d", curV + number]];
                       });

    }
    else {
        [self setupTimer:5];
        
    }

}

-(void)appInBackground:(NSNotification *)notification {
    NSLog(@"appInBackground");
    [self stopTimer];
}

-(void)appInForeground:(NSNotification *)notification {
    NSLog(@"appInForeground");

    [self setupTimer:10];
}

-(void)stopTimer {
    NSLog(@"STOP TIMER");
    [self.liveTimer invalidate];
    self.liveTimer = nil;
}

-(void)setupTimer:(int)sec {
    [self stopTimer];

    NSLog(@"SETUP TIMER %d", sec);
    self.liveTimer = [NSTimer scheduledTimerWithTimeInterval:sec
                                                      target:self
                                                    selector:@selector(liveTimerSelector)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)liveTimerSelector
{
    //NSLog(@"liveTimer");

    [self performSelectorInBackground:@selector(liveTimerSelectorBack) withObject:nil];
}

- (void)liveTimerSelectorBack
{

    @autoreleasepool {

        [self stopTimer];

        NSLog(@"liveTimerBack");

        [self searchNewMessages:kNewMessageFromUpdate];
        // If another same maintenance operation is already sceduled, cancel it so this new operation will be executed after other
        // operations of the queue, so we can group more work together
        //[periodicMaintenanceOperation cancel];
        //self.periodicMaintenanceOperation = nil;
        
    }
    
}

@end
