//
//  TopicCellView.m
//  HFRplus
//
//  Created by FLK on 23/09/10.
//

#import "TopicSearchCellView.h"
#import "Constants.h"


@implementation TopicSearchCellView

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

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        [msgLabel setHighlightedTextColor:[UIColor whiteColor]];
        [timeLabel setHighlightedTextColor:[UIColor whiteColor]];
        
    }
}

- (void)dealloc {

	[titleLabel release];
	[msgLabel release];
	[timeLabel release];	
	
    [super dealloc];
}


@end
