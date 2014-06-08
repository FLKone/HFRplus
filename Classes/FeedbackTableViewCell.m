//
//  FeedbackTableViewCell.m
//  HFRplus
//
//  Created by Shasta on 27/05/2014.
//
//

#import "FeedbackTableViewCell.h"

@implementation FeedbackTableViewCell
@synthesize pseudoLabel, avisLabel, commLabel, dateLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [pseudoLabel release];
    [avisLabel release];
    [commLabel release];
    [dateLabel release];
    [super dealloc];
}
@end
