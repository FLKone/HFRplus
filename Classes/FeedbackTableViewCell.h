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
@property (strong, nonatomic) IBOutlet UILabel *pseudoLabel;
@property (strong, nonatomic) IBOutlet UILabel *avisLabel;
@property (strong, nonatomic) IBOutlet UILabel *commLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
