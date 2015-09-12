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

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *infoImage;

@end