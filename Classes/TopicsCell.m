//
//  TopicsCell.m
//  HFR+
//
//  Created by FLK on 03/08/10.
//

#import "TopicsCell.h"


@implementation TopicsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		
		//NSLog(@"Cell Origin %f %f", self.superview.frame.origin.x, self.superview.frame.origin.y);
		//NSLog(@"Cell Size %f %f", self.superview.frame.size.width, self.superview.frame.size.height);

		UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 290, 22)];
		labelTitle.transform = CGAffineTransformIdentity;
		labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[labelTitle setBackgroundColor:[UIColor redColor]];
		
		[labelTitle setFont:[UIFont boldSystemFontOfSize:14.0]];
		[labelTitle setAdjustsFontSizeToFitWidth:NO];
		[labelTitle setLineBreakMode:UILineBreakModeTailTruncation];
		[labelTitle setTextAlignment:UITextAlignmentLeft];
		[labelTitle setHighlightedTextColor:[UIColor whiteColor]];
		[labelTitle setTag:999];
		[labelTitle setTextColor:[UIColor blackColor]];
		[labelTitle setNumberOfLines:0];
		
		[self.contentView insertSubview:labelTitle atIndex:1];
		[labelTitle release];
		
		
		
		UILabel *labelMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 27, 120, 18)];
		labelMsg.transform = CGAffineTransformIdentity;
		
		labelMsg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[labelMsg setBackgroundColor:[UIColor blueColor]];

		[labelMsg setFont:[UIFont systemFontOfSize:13.0]];
		[labelMsg setAdjustsFontSizeToFitWidth:NO];
		[labelMsg setLineBreakMode:UILineBreakModeTailTruncation];
		[labelMsg setTextAlignment:UITextAlignmentLeft];
		[labelMsg setHighlightedTextColor:[UIColor whiteColor]];
		[labelMsg setTag:998];
		[labelMsg setTextColor:[UIColor darkGrayColor]];
		[labelMsg setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:labelMsg atIndex:2];
		[labelMsg release];
		
		UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(130, 27, 160, 18)];
		labelDate.transform = CGAffineTransformIdentity;
	
		labelDate.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[labelDate setBackgroundColor:[UIColor greenColor]];

		[labelDate setFont:[UIFont systemFontOfSize:11.0]];
		[labelDate setAdjustsFontSizeToFitWidth:NO];
		[labelDate setLineBreakMode:UILineBreakModeTailTruncation];
		[labelDate setTextAlignment:UITextAlignmentRight];
		[labelDate setHighlightedTextColor:[UIColor whiteColor]];
		[labelDate setTag:997];
		[labelDate setTextColor:[UIColor colorWithRed:42/255.f green:116/255.f blue:217/255.f alpha:1.00]];
		[labelDate setNumberOfLines:0];
		//[label setOpaque:YES];
		
		[self.contentView insertSubview:labelDate atIndex:3];		
		[labelDate release];
		 
    }
    return self;
}

- (void)dealloc {
	//NSLog(@"dealloc custom cell topic");

    [super dealloc];
}

@end
