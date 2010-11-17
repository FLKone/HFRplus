//
//  TopicCellView.m
//  HFRplus
//
//  Created by Shasta on 23/09/10.
//

#import "TopicCellView.h"


@implementation TopicCellView

@synthesize titleLabel;
@synthesize msgLabel;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {

	[titleLabel release];
	[msgLabel release];
	[timeLabel release];	
	
    [super dealloc];
}


@end
