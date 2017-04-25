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

@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) UIBarButtonItem *mybarButtonItem;

-(void)MoveRightToLeft;
-(void)MoveRightToLeft:(NSString *)url;
-(void)NavPlus:(NSString *)url;

-(void)MoveLeftToRight;

@end
