//
//  ForumCellView.m
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import "ForumCellView.h"
#import "Constants.h"

@implementation ForumCellView
@synthesize titleLabel, flagLabel, catImage;

- (void)awakeFromNib {
    NSLog(@"awakeFromNib");

    [super awakeFromNib];
    
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [titleLabel setHighlightedTextColor:[UIColor whiteColor]];
        [flagLabel setHighlightedTextColor:[UIColor whiteColor]];
        //[catImage setHighlightedTextColor:[UIColor whiteColor]];
        
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)viewDidUnload {
    NSLog(@"viewDidUnload");
    self.titleLabel = nil;
    self.flagLabel = nil;
}
-(void)dealloc {
    NSLog(@"dealloc");
    [self viewDidUnload];
}

@end
