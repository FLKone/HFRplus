//
//  FavoriteCell.m
//  HFRplus
//
//  Created by FLK on 22/07/10.
//

#import "FavoriteCell.h"
#import "Constants.h"
#import "ThemeColors.h"
#import "ThemeManager.h"


@implementation FavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        // Initialization code
		//Titre Topic
		
		self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 22)];
		self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[self.labelTitle setFont:[UIFont boldSystemFontOfSize:14.0]];
		[self.labelTitle setAdjustsFontSizeToFitWidth:NO];
		[self.labelTitle setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelTitle setBackgroundColor:[UIColor blueColor]];
		[self.labelTitle setTextAlignment:NSTextAlignmentLeft];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [self.labelTitle setHighlightedTextColor:[UIColor whiteColor]];
        }
		[self.labelTitle setTag:999];
		[self.labelTitle setTextColor:[UIColor blackColor]];
		[self.labelTitle setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:self.labelTitle atIndex:1];
		
		self.labelMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 27, 128, 18)];
		self.labelMsg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[self.labelMsg setFont:[UIFont systemFontOfSize:13.0]];
		[self.labelMsg setAdjustsFontSizeToFitWidth:NO];
		[self.labelMsg setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelMsg setBackgroundColor:[UIColor blueColor]];
		[self.labelMsg setTextAlignment:NSTextAlignmentLeft];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [self.labelMsg setHighlightedTextColor:[UIColor whiteColor]];
        }
		[self.labelMsg setTag:998];
		[self.labelMsg setTextColor:[UIColor grayColor]];
		[self.labelMsg setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:self.labelMsg atIndex:2];
		
		self.labelDate = [[UILabel alloc] initWithFrame:CGRectMake(140, 27, 170, 18)];
		self.labelDate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[self.labelDate setFont:[UIFont systemFontOfSize:11.0]];
		[self.labelDate setAdjustsFontSizeToFitWidth:NO];
		[self.labelDate setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelDate setBackgroundColor:[UIColor redColor]];
		[self.labelDate setTextAlignment:NSTextAlignmentRight];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [self.labelDate setHighlightedTextColor:[UIColor whiteColor]];
        }
		[self.labelDate setTag:997];
		[self.labelDate setTextColor:[UIColor colorWithRed:42/255.f green:116/255.f blue:217/255.f alpha:1.00]];
		[self.labelDate setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:self.labelDate atIndex:3];
				
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    [self.labelTitle setTextColor:[ThemeColors textColor:theme]];
    [self.labelMsg setTextColor:[ThemeColors topicMsgTextColor:theme]];
    [self.labelDate setTextColor:[ThemeColors tintColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
