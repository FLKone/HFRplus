//
//  RehostCell.h
//  HFRplus
//
//  Created by Shasta on 16/12/2013.
//
//

#import <UIKit/UIKit.h>
@class RehostImage;

@interface RehostCell : UITableViewCell <UIAlertViewDelegate> {
    UIImageView *previewImage;
    UIButton *miniBtn;
    UIButton *previewBtn;
    UIButton *fullBtn;
    UIActivityIndicatorView *spinner;
    RehostImage *rehostImage;
}

@property (nonatomic, strong) IBOutlet UIImageView *previewImage;
@property (nonatomic, strong) IBOutlet UIButton *miniBtn;
@property (nonatomic, strong) IBOutlet UIButton *previewBtn;
@property (nonatomic, strong) IBOutlet UIButton *fullBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RehostImage *rehostImage;

-(IBAction)copyFull;
-(IBAction)copyPreview;
-(IBAction)copyMini;
-(void)configureWithRehostImage:(RehostImage *)image;

@end
