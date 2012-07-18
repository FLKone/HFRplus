//
//  HFRNavigationController.m
//  HFRplus
//
//  Created by FLK on 19/07/12.
//

#import "HFRNavigationController.h"
#import "HFRplusAppDelegate.h"

@interface HFRNavigationController ()

@end

@implementation HFRNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* for iOS6 support
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"none"]) {
        return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (BOOL)shouldAutorotate
{
    NSLog(@"shouldAutorotate %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"]);

    return YES;
}
*/

@end
