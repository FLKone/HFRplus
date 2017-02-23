//
//  FeedbackTableViewCell.m
//  HFRplus
//
//  Created by Shasta on 27/05/2014.
//
//

#import "FeedbackTableViewCell.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation FeedbackTableViewCell
@synthesize pseudoLabel, avisLabel, commLabel, dateLabel;

- (void)awakeFromNib
{
    // Initialization code
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    [pseudoLabel setTextColor:[ThemeColors cellIconColor:theme]];
    [dateLabel setTextColor:[ThemeColors tintColor:theme]];
    [commLabel setTextColor:[ThemeColors cellTextColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
