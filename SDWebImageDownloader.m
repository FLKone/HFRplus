/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"

@interface SDWebImageDownloader ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation SDWebImageDownloader
@synthesize url, delegate, connection, imageData;

#pragma mark Public Methods

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate
{
    SDWebImageDownloader *downloader = [[[SDWebImageDownloader alloc] init] autorelease];
    downloader.url = url;
    downloader.delegate = delegate;
    [downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return downloader;
}

+ (void)setMaxConcurrentDownloads:(NSUInteger)max
{
    // NOOP
}

- (void)start
{
	//NSLog(@"url: %@", url);
	
    // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests
	//
	//NSURLRequestReloadIgnoringLocalCacheData
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
    // Ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
    [request release];

    if (connection)
    {
        self.imageData = [NSMutableData data];
    }
    else
    {
		//NSLog(@"delegate %@", delegate);
        if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
        {
            [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:nil];
        }
    }
}

- (void)cancel
{
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
	//NSLog(@"didReceiveData");

    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
	//NSLog(@"didReceiveResponse");
	if ([response respondsToSelector:@selector(statusCode)])
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400)
		{
			[aConnection cancel];  // stop connecting; no more delegate messages
			NSDictionary *errorInfo
			= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
												  NSLocalizedString(@"Server returned status code %d",@""),
												  statusCode]
										  forKey:NSLocalizedDescriptionKey];
			NSError *statusError
			= [NSError errorWithDomain:@"HTTPPropertyStatusCode"
								  code:statusCode
							  userInfo:errorInfo];
			[self connection:aConnection didFailWithError:statusError];
		}
	}
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	//NSLog(@"connectionDidFinishLoading %@", [aConnection description]);

    self.connection = nil;

    if ([delegate respondsToSelector:@selector(imageDownloaderDidFinish:)])
    {
        [delegate performSelector:@selector(imageDownloaderDidFinish:) withObject:self];
    }

    if ([delegate respondsToSelector:@selector(imageDownloader:didFinishWithImage:)])
    {
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [delegate performSelector:@selector(imageDownloader:didFinishWithImage:) withObject:self withObject:image];
        [image release];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//NSLog(@"didFailWithError %@", delegate);
	//NSLog(@"didFailWithError %@", error);

    if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
    {
        [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
    }

    self.connection = nil;
    self.imageData = nil;
}

#pragma mark NSObject

- (void)dealloc
{
    [url release], url = nil;
    [connection release], connection = nil;
    [imageData release], imageData = nil;
    [super dealloc];
}


@end
