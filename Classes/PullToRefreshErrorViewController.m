//
//  PullToRefreshErrorViewController.m
//  HFRplus
//
//  Created by Shasta on 25/05/2014.
//
//


#import "PullToRefreshErrorViewController.h"
#import "HFRplusAppDelegate.h"

@interface PullToRefreshErrorViewController ()

@end

@implementation PullToRefreshErrorViewController
@synthesize image, label, dico;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDico:(NSDictionary*) dic
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dico = [NSDictionary dictionaryWithDictionary:dic];
        
    }
    return self;
}

- (void)loadView {
    
    NSLog(@"loadView %d %d", (int)[self.dico objectForKey:@"status"], kNoAuth);
    
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectZero];
    //bgView.backgroundColor = [UIColor greenColor];
    
    NSString *imageNamed;
    
    switch ([[self.dico valueForKey:@"status"] intValue]) {
        case kNoAuth: {
            imageNamed = @"info";
            break;
        }
        case kNoResults: {
            imageNamed = @"check";
            break;
        }
        case kMaintenance: {
            imageNamed = @"error";
            break;
        }
        default: {
            imageNamed = @"info";
            break;
        }
    }
    self.image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNamed]];
    //self.image.backgroundColor = [UIColor redColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.label setText:[dico valueForKey:@"message"]];
    //self.label.backgroundColor = [UIColor redColor];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setFont:[UIFont systemFontOfSize:14]];
    [self.label setNumberOfLines:0];
    
    [bgView addSubview:self.image];
    [bgView addSubview:self.label];
    
    self.view = bgView;
    
    NSLog(@"END");
}

-(void)sizeToFit {
    
    NSLog(@"=============== sizeToFit");

    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];

        

    
    
    // grab the window frame and adjust it for orientation
    UIView *rootView = [[[UIApplication sharedApplication] keyWindow]
                        rootViewController].view;
    
    CGRect originalFrame = CGRectZero;
    CGRect adjustedFrame = CGRectZero;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UITabBarController *tabBar = [[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:0];
        originalFrame = [tabBar.view bounds];
        
        adjustedFrame.size.height = originalFrame.size.height;
        adjustedFrame.size.width = originalFrame.size.width;
        /*
        if (UIDeviceOrientationIsLandscape(o)) {
            adjustedFrame.size.height = originalFrame.size.height;
            adjustedFrame.size.width = originalFrame.size.width;
        }
        else
        {
            adjustedFrame.size.height = originalFrame.size.width;
            adjustedFrame.size.width = originalFrame.size.height;
        }
         */
        
    } else {
        originalFrame = [[UIScreen mainScreen] bounds];
        adjustedFrame = [rootView convertRect:originalFrame fromView:nil];
    }
    
    //NSLog(@"originalFrame %@", NSStringFromCGRect(originalFrame));
    //NSLog(@"adjustedFrame %@", NSStringFromCGRect(adjustedFrame));

    
    //iOS7/iPhone Status : 22 - Nav : 32/44 - Tab : 49
    //iOS6/iPhone Status : 22 - Nav : 32/44 - Tab : 49
    
    //iOS7/iPad   Status : 20 - Nav : 44 - Tab : 56
    //iOS6/iPad   Status : 20 - Nav : 44 - Tab : 49

    
    NSLog(@"status %f", MIN([[UIApplication sharedApplication] statusBarFrame].size.height, [[UIApplication sharedApplication] statusBarFrame].size.width));
    NSLog(@"naviga %f", self.navigationController.navigationBar.frame.size.height);
    NSLog(@"tabbar %f", self.tabBarController.tabBar.frame.size.height);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {

            adjustedFrame.size.height -= (20+44+56);
        }
        else {
            adjustedFrame.size.height -= (44+49);

        }

    }
    else
    {
        if (UIDeviceOrientationIsLandscape(o)) {
            adjustedFrame.size.height -= (22+32+49);
        }
        else {
            adjustedFrame.size.height -= (22+44+49);
        }
    }
    
    //NSLog(@"adjustedFrame %f", adjustedFrame.size.height);
    
    
    self.view.frame = adjustedFrame;
    
    //img/labl position
    CGRect imageFrame = self.image.frame;
    imageFrame.origin.x = adjustedFrame.size.width / 2 - imageFrame.size.width / 2;
    imageFrame.origin.y = adjustedFrame.size.height / 2 - imageFrame.size.height / 2 - 15;
    //NSLog(@"labelSize %@", NSStringFromCGPoint(imageFrame.origin));

    self.image.frame = imageFrame;
    
    
    CGRect labelFrame = self.label.frame;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(adjustedFrame.size.width, 2000)];
    //NSLog(@"labelSize %@", NSStringFromCGSize(labelSize));
    labelFrame.size = labelSize;
    labelFrame.size.width = adjustedFrame.size.width;
    
    labelFrame.origin.x = 0;
    labelFrame.origin.y = imageFrame.origin.y + imageFrame.size.height + 9;
    
    self.label.frame = labelFrame;

    [(UITableView *)self.view.superview setTableHeaderView:self.view];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self sizeToFit];
}

-(void)OrientationChanged {
    
    [self sizeToFit];

    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrientationChanged)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
