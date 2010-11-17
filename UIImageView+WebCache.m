/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#import "UIImageViewCustom.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
	//NSLog(@"setImageWithURL %@", [url absoluteURL]);
	
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    UIImage *cachedImage = nil;
    if (url)
    {
        cachedImage = [manager imageWithURL:url];
    }

    if (cachedImage)
    {
		//NSLog(@"cachedImage %f - %f", cachedImage.size.width, cachedImage.size.height);

        self.image = cachedImage;
		
		if( [[self class] instancesRespondToSelector:@selector(configureCustom)] ) {
			[(UIImageViewCustom *)self configureCustom];
		}
    }
    else
    {
        if (placeholder)
        {
            self.image = placeholder;
        }

        if (url)
        {
            [manager downloadWithURL:url delegate:self];
        }
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
	//NSLog(@"didFinishWithImage %f - %f", image.size.width, image.size.height);
	
    self.image = image;
	
	if( [[self class] instancesRespondToSelector:@selector(configureCustom)] ) {
		[(UIImageViewCustom *)self configureCustom];
	}
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
	//NSLog(@"didFinishFail %@", error);
	
	if( [[self class] instancesRespondToSelector:@selector(configureFail)] ) {
		[(UIImageViewCustom *)self configureFail];
	}
	
}


@end
