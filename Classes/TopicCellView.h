//
//  TopicCellView.h
//  HFRplus
//
//  Created by Shasta on 23/09/10.
//  Copyright 2010 FLK. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TopicCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *msgLabel;
    IBOutlet UILabel *timeLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;


@end
