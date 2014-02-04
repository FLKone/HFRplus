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

@property (nonatomic, retain) IBOutlet UIImageView *previewImage;
@property (nonatomic, retain) IBOutlet UIButton *miniBtn;
@property (nonatomic, retain) IBOutlet UIButton *previewBtn;
@property (nonatomic, retain) IBOutlet UIButton *fullBtn;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) RehostImage *rehostImage;

-(IBAction)copyFull;
-(IBAction)copyPreview;
-(IBAction)copyMini;
-(void)configureWithRehostImage:(RehostImage *)image;

@end
