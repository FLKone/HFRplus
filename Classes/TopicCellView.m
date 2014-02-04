//
//  TopicCellView.m
//  HFRplus
//
//  Created by FLK on 23/09/10.
//

#import "TopicCellView.h"
#import "Constants.h"


@implementation TopicCellView

@synthesize titleLabel;
@synthesize msgLabel;
@synthesize timeLabel;


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
