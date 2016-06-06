//
//  LiveMessagesTableViewController.h
//  HFRplus
//
//  Created by FLK on 04/06/2016.
//
//

#import "MessagesTableViewController.h"

@interface LiveMessagesTableViewController : BaseMessagesTableViewController
{
        NSTimer *liveTimer;
}

@property (nonatomic, strong) NSTimer *liveTimer;

-(void)stopTimer;
-(void)setupTimer:(int)sec;

@end
