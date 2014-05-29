//
//  SplitViewController.h
//  HFRplus
//
//  Created by FLK on 15/08/10.
//

#import <UIKit/UIKit.h>

@interface SplitViewController : UISplitViewController <UISplitViewControllerDelegate>
{
    UIPopoverController *popOver;
    UIBarButtonItem *mybarButtonItem;
}

@property (nonatomic, retain) UIPopoverController *popOver;
@property (nonatomic, retain) UIBarButtonItem *mybarButtonItem;

-(void)MoveRightToLeft;
-(void)MoveLeftToRight;

@end
