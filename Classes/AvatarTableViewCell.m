//
//  AvatarTableViewCell.m
//  HFRplus
//
//  Created by Shasta on 27/05/2014.
//
//

#import "AvatarTableViewCell.h"
#import "Constants.h"

@implementation AvatarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
    
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        CGRect oldFrame = self.imageView.frame;
        oldFrame.origin.x += 10;
        self.imageView.frame = oldFrame;
        
        CGRect oldFrame2 = self.textLabel.frame;
        oldFrame2.origin.x += 10;
        self.textLabel.frame = oldFrame2;
    }
    
    /*
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame =          CGRectMake(55,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
        self.detailTextLabel.frame =    CGRectMake(55,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
    */
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
