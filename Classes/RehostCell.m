//
//  RehostCell.m
//  HFRplus
//
//  Created by Shasta on 16/12/2013.
//
//

#import "RehostCell.h"
#import "RehostImage.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation RehostCell
@synthesize previewImage, rehostImage;
@synthesize miniBtn, previewBtn, fullBtn, spinner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.miniBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.previewBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.fullBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //
    }
    else
    {
        self.miniBtn.layer.cornerRadius = 5; // this value vary as per your desire
        self.miniBtn.clipsToBounds = YES;
        
        self.previewBtn.layer.cornerRadius = 5; // this value vary as per your desire
        self.previewBtn.clipsToBounds = YES;
        
        self.fullBtn.layer.cornerRadius = 5; // this value vary as per your desire
        self.fullBtn.clipsToBounds = YES;

    }
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)configureWithRehostImage:(RehostImage *)image;
{
    self.rehostImage = image;
    
    [self.miniBtn setHidden:YES];
    [self.previewBtn setHidden:YES];
    [self.fullBtn setHidden:YES];
    [self.previewImage setHidden:YES];
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    NSString *url = self.rehostImage.nolink_preview;
	url = [url stringByReplacingOccurrencesOfString:@"[img]" withString:@""];
	url = [url stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
	url = [url stringByReplacingOccurrencesOfString:@"hfr-rehost.net" withString:@"reho.st"];
    //NSLog(@"url = %@", url);

    __weak RehostCell *self_ = self;

    [self.previewImage sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //
        if (image) {
            [self_.previewImage setImage:image];
            [self_.previewImage setHidden:NO];
            
            [self_.miniBtn setHidden:NO];
            [self_.previewBtn setHidden:NO];
            [self_.fullBtn setHidden:NO];
            [self_.miniBtn setHidden:NO];
        }
        
        [self_.spinner stopAnimating];
    }];
    
}

-(IBAction)copyFull {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copier le BBCode" message:@"avec ou sans lien?"
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Avec!", @"Sans!", @"Le lien uniquement!", nil];
	
	[alert setTag:111];
	[alert show];
}

-(IBAction)copyPreview {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copier le BBCode" message:@"avec ou sans lien?"
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Avec!", @"Sans!", @"Le lien uniquement!", nil];
	
	[alert setTag:222];
	[alert show];
}

-(IBAction)copyMini {
	//NSLog(@"indexPath %@", self.indexPath);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copier le BBCode" message:@"avec ou sans lien?"
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Avec!", @"Sans!", @"Le lien uniquement!", nil];
	
	[alert setTag:333];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"";
    
    switch (buttonIndex) {
		case 1:
		{
			switch (alertView.tag) {
				case 111:
					pasteboard.string = rehostImage.link_full;
					break;
				case 222:
					pasteboard.string = rehostImage.link_preview;
					break;
				case 333:
					pasteboard.string = rehostImage.link_miniature;
					break;
				default:
					break;
			}
			break;
		}
		case 2:
			switch (alertView.tag) {
				case 111:
					pasteboard.string = rehostImage.nolink_full;
					break;
				case 222:
					pasteboard.string = rehostImage.nolink_preview;
					break;
				case 333:
					pasteboard.string = rehostImage.nolink_miniature;
					break;
				default:
					break;
			}
			break;
        case 3:
        {
            
			switch (alertView.tag) {
				case 111:
					pasteboard.string = [[rehostImage.nolink_full stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
					break;
				case 222:
					pasteboard.string = [[rehostImage.nolink_preview stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
					break;
				case 333:
					pasteboard.string = [[rehostImage.nolink_miniature stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
					break;
				default:
					break;
			}
			break;
        }
		default:
            
			break;
	}

    //NSLog(@"%@", pasteboard.string);
    if (pasteboard.string.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReceived" object:pasteboard.string];
    }


}
@end
