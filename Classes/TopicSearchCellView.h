//
//  TopicCellView.h
//  HFRplus
//
//  Created by FLK on 23/09/10.
//

#import <UIKit/UIKit.h>


@interface TopicSearchCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *msgLabel;
    IBOutlet UILabel *timeLabel;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *msgLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;


@end
