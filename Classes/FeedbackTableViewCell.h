//
//  FeedbackTableViewCell.h
//  HFRplus
//
//  Created by Shasta on 27/05/2014.
//
//

#import <UIKit/UIKit.h>

@interface FeedbackTableViewCell : UITableViewCell {
    UILabel *pseudoLabel;
    UILabel *avisLabel;
    UILabel *commLabel;
    UILabel *dateLabel;

}
@property (retain, nonatomic) IBOutlet UILabel *pseudoLabel;
@property (retain, nonatomic) IBOutlet UILabel *avisLabel;
@property (retain, nonatomic) IBOutlet UILabel *commLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;

@end
