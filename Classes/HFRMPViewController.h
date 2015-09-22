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

}
@property bool reloadOnAppear;


- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest;
- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest;
- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest;

@end
