//
//  ForumCellView.m
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import "ForumCellView.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation ForumCellView
@synthesize titleLabel, flagLabel, catImage;

- (void)awakeFromNib {
    //NSLog(@"awakeFromNib");

    [super awakeFromNib];
    
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        [flagLabel setHighlightedTextColor:[UIColor whiteColor]];
        //[catImage setHighlightedTextColor:[UIColor whiteColor]];
        
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
    [titleLabel setTextColor:[ThemeColors cellTextColor:theme]];
    [flagLabel setTextColor:[ThemeColors cellBorderColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    UIImage *tintedCat = [ThemeColors tintImage:self.catImage.image withColor:[ThemeColors cellIconColor:theme]];
    [self.catImage setImage:tintedCat];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)viewDidUnload {
    //NSLog(@"viewDidUnload");
    self.titleLabel = nil;
    self.flagLabel = nil;
}
-(void)dealloc {
    //NSLog(@"dealloc");
    [self viewDidUnload];
}

@end
