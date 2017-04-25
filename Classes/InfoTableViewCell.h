//
//  InfoTableViewCell.h
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import <UIKit/UIKit.h>

@interface InfoTableViewCell : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UIImageView *infoImage;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *infoImage;

@end