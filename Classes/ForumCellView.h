//
//  ForumCellView.h
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import <UIKit/UIKit.h>

@interface ForumCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *flagLabel;
    IBOutlet UIImageView *catImage;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *flagLabel;
@property (nonatomic, strong) IBOutlet UIImageView *catImage;

@end
