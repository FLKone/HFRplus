//
//  MPViewController.h
//  HFRplus
//
//  Created by FLK on 23/07/10.
//

#import <UIKit/UIKit.h>
#import "TopicsTableViewController.h"


@interface HFRMPViewController : TopicsTableViewController {
    bool reloadOnAppear;
    UIBarButtonItem *actionButton;
    UIBarButtonItem *reloadButton;

}
@property bool reloadOnAppear;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIBarButtonItem *reloadButton;


- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest;
- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest;
- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest;

@end
