//
//  FavoriteCell.m
//  HFRplus
//
//  Created by FLK on 22/07/10.
//

#import "FavoriteCell.h"
#import "Constants.h"


@implementation FavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        // Initialization code
		//Titre Topic
		
		UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 22)];
		labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[labelTitle setFont:[UIFont boldSystemFontOfSize:14.0]];
		[labelTitle setAdjustsFontSizeToFitWidth:NO];
		[labelTitle setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelTitle setBackgroundColor:[UIColor blueColor]];
		[labelTitle setTextAlignment:NSTextAlignmentLeft];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [labelTitle setHighlightedTextColor:[UIColor whiteColor]];
        }
		[labelTitle setTag:999];
		[labelTitle setTextColor:[UIColor blackColor]];
		[labelTitle setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:labelTitle atIndex:1];
		[labelTitle release];
		
		UILabel *labelMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 27, 128, 18)];
		labelMsg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[labelMsg setFont:[UIFont systemFontOfSize:13.0]];
		[labelMsg setAdjustsFontSizeToFitWidth:NO];
		[labelMsg setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelMsg setBackgroundColor:[UIColor blueColor]];
		[labelMsg setTextAlignment:NSTextAlignmentLeft];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [labelMsg setHighlightedTextColor:[UIColor whiteColor]];
        }
		[labelMsg setTag:998];
		[labelMsg setTextColor:[UIColor grayColor]];
		[labelMsg setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:labelMsg atIndex:2];
		[labelMsg release];
		
		UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(140, 27, 170, 18)];
		labelDate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[labelDate setFont:[UIFont systemFontOfSize:11.0]];
		[labelDate setAdjustsFontSizeToFitWidth:NO];
		[labelDate setLineBreakMode:NSLineBreakByTruncatingTail];
		//[labelDate setBackgroundColor:[UIColor redColor]];
		[labelDate setTextAlignment:NSTextAlignmentRight];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            [labelDate setHighlightedTextColor:[UIColor whiteColor]];
        }
		[labelDate setTag:997];
		[labelDate setTextColor:[UIColor colorWithRed:42/255.f green:116/255.f blue:217/255.f alpha:1.00]];
		[labelDate setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:labelDate atIndex:3];		
		[labelDate release];
				
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	//NSLog(@"dealloc favorite cell");

    [super dealloc];
}


@end
