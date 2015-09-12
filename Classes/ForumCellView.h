//
//  ForumCellView.h
//  HFRplus
//
//  Created by FLK on 11/09/2015.
//
//

#import <UIKit/UIKit.h>

@interface ForumCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *flagLabel;
    IBOutlet UIImageView *catImage;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *flagLabel;
@property (nonatomic, retain) IBOutlet UIImageView *catImage;

@end
