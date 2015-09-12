//
//  InfoTableViewCell.m
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import "InfoTableViewCell.h"
#import "Constants.h"

@implementation InfoTableViewCell
@synthesize titleLabel, infoImage;

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        //[catImage setHighlightedTextColor:[UIColor whiteColor]];
        
    }
}


- (void)dealloc {
    
    [titleLabel release];
    [infoImage release];
    
    [super dealloc];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
