//
//  PollResultTableViewCell.m
//  HFRplus
//
//  Created by Shasta on 28/04/2014.
//
//

#import "PollResultTableViewCell.h"

@implementation PollResultTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setup {
    
}

- (void)dealloc {
    [_labelLabel release];
    [_pcLabel release];
    [_nbLabel release];
    [_pcLabelView release];
    [super dealloc];
}
@end
