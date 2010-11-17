//
//  MPViewController.h
//  HFR+
//
//  Created by Lace on 23/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicsTableViewController.h"


@interface HFRMPViewController : TopicsTableViewController {

}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest;
- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest;
- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest;

@end
