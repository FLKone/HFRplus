//
//  TopicCellView.m
//  HFRplus
//
//  Created by FLK on 23/09/10.
//

#import "TopicCellView.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


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

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect adjustedFrame = self.accessoryView.frame;
    adjustedFrame.origin.x += 10.0f;
    self.accessoryView.frame = adjustedFrame;
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    [titleLabel setTextColor:[ThemeColors textColor:theme]];
    [msgLabel setTextColor:[ThemeColors topicMsgTextColor:theme]];
    [timeLabel setTextColor:[ThemeColors tintColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    if(topicViewed){
        Theme theme = [[ThemeManager sharedManager] theme];
        [titleLabel setTextColor:[ThemeColors lightTextColor:theme]];
    }
}

-(BOOL)topicViewed{
    return topicViewed;
}

-(void)setTopicViewed:(BOOL)isTopicViewed{
    topicViewed = isTopicViewed;
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[ThemeColors cellHighlightBackgroundColor:[[ThemeManager sharedManager] theme]]]; // set color here
    [self setSelectedBackgroundView:selectedBackgroundView];

}


@end
