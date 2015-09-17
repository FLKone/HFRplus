//
//  RehostImage.m
//  HFRplus
//
//  Created by Shasta on 15/12/2013.
//
//

#import "RehostImage.h"
#import "UIImage+Resize.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"

@implementation RehostImage

@synthesize version;

@synthesize link_full;
@synthesize link_miniature;
@synthesize link_preview;
@synthesize nolink_full;
@synthesize nolink_miniature;
@synthesize nolink_preview;
@synthesize timeStamp;
@synthesize deleted;

- (id)init {
	self = [super init];
	if (self) {
        self.link_full = [NSString string];
        self.link_miniature = [NSString string];
        self.link_preview = [NSString string];
        
        self.nolink_full = [NSString string];
        self.nolink_miniature = [NSString string];
        self.nolink_preview = [NSString string];
        
        self.timeStamp = [NSDate date];
        self.deleted = NO;
        self.version = 1;
	}
	return self;
}

// Implementation
- (void) encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"encodeWithCoder %@", self);
    
    [encoder encodeObject:link_full forKey:@"link_full"];
    [encoder encodeObject:link_miniature forKey:@"link_miniature"];
    [encoder encodeObject:link_preview forKey:@"link_preview"];

    [encoder encodeObject:nolink_full forKey:@"nolink_full"];
    [encoder encodeObject:nolink_miniature forKey:@"nolink_miniature"];
    [encoder encodeObject:nolink_preview forKey:@"nolink_preview"];
    
    [encoder encodeInt:version forKey:@"version"];
    [encoder encodeBool:deleted forKey:@"deleted"];
    
    [encoder encodeObject:timeStamp forKey:@"timeStamp"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {

        link_full = [decoder decodeObjectForKey:@"link_full"];
        link_miniature = [decoder decodeObjectForKey:@"link_miniature"];
        link_preview = [decoder decodeObjectForKey:@"link_preview"];

        nolink_full = [decoder decodeObjectForKey:@"nolink_full"];
        nolink_miniature = [decoder decodeObjectForKey:@"nolink_miniature"];
        nolink_preview = [decoder decodeObjectForKey:@"nolink_preview"];

        version = [decoder decodeIntForKey:@"version"];
        deleted = [decoder decodeBoolForKey:@"deleted"];

        timeStamp = [decoder decodeObjectForKey:@"timeStamp"];

        //NSLog(@"initWithCoder %@", self);
    }
    return self;
}

-(void)create {
    self.link_full = @"link_full";
    self.link_miniature = @"link_miniature";
    self.link_preview = @"link_preview";
    
    self.nolink_full = @"nolink_full";
    self.nolink_miniature = @"nolink_miniature";
    self.nolink_preview = @"nolink_preview";
}

-(void)upload:(UIImage *)picture;
{
    [self performSelectorInBackground:@selector(loadData:) withObject:picture];
}
-(void)loadData:(UIImage *)picture {
	
	
	@autoreleasepool {
	
	//UIImageOrientation    originalOrientation = picture.imageOrientation;
    
	//NSLog(@"image %f %f", picture.size.width, picture.size.height);
    /*
     switch (originalOrientation) {
     case UIImageOrientationUp:      //EXIF 1
     NSLog(@"EXIF 1 UIImageOrientationUp");
     break;
     
     case UIImageOrientationDown:    //EXIF 3
     NSLog(@"EXIF 3 UIImageOrientationDown");
     picture = [picture imageRotatedByDegrees:180];
     
     break;
     
     case UIImageOrientationLeft:    //EXIF 6
     NSLog(@"EXIF 6 UIImageOrientationLeft");
     //picture = [picture imageRotatedByDegrees:-90];
     break;
     
     case UIImageOrientationRight:   //EXIF 8
     NSLog(@"EXIF 8 UIImageOrientationRight");
     //picture = [picture imageRotatedByDegrees:90];
     break;
     
     default:
     NSLog(@"EXIF DEF");
     
     break;
     }
     */
    
        picture = [picture scaleAndRotateImage:picture];
        
        //NSLog(@"image %f %f", picture.size.width, picture.size.height);
        
	NSData* jpegImageData = UIImageJPEGRepresentation(picture, 1);
	
        [self performSelectorOnMainThread:@selector(loadData2:) withObject:jpegImageData waitUntilDone:NO];
    
    }
	
    
}

-(void)loadData2:(NSData *)jpegImageData {
    
    
	
	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:
                               [NSURL URLWithString:@"http://reho.st/upload"]];
    //[NSURL URLWithString:@"http://apps.flkone.com/hfrplus/api/upload.processor.php"]];
	
    
	
	NSString* filename = [NSString stringWithFormat:@"snapshot_%d.jpg", rand()];
	
	[request setData:jpegImageData withFileName:filename andContentType:@"image/jpeg" forKey:@"fichier"];
	//[request setData:jpegImageData withFileName:filename andContentType:@"image/jpeg" forKey:@"file"];
	[request setPostValue:@"Envoyer" forKey:@"submit"];
	[request setShouldRedirect:NO];
	[request setShowAccurateProgress:YES];
    
	request.uploadProgressDelegate = self;
	
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	
	[request startAsynchronous];
}

- (void)setProgress:(float)progress
{
    //NSLog(@"progress %f", progress);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progress] forKey:@"progress"]];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentStarted");
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    //NSLog(@"fetchContentComplete %@", [theRequest responseString]);
	//NSLog(@"fetchContentComplete");
	
	
	NSError * error = nil;
	//HTMLParser * myParser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:[self.urlQuote lowercaseString]] error:&error];
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:[theRequest responseData] error:&error];
	//NSLog(@"error %@", error);
	//NSDate *then0 = [NSDate date]; // Create a current date
	
	HTMLNode * bodyNode = [myParser body]; //Find the body tag
    
	NSArray *codeArray = [bodyNode findChildTags:@"code"];
	//NSLog(@"codeArray %d", codeArray.count);
	
	if (codeArray.count == 8) {
		// OK :D

		// If appropriate, configure the new managed object.
        self.link_full = [[codeArray objectAtIndex:0] allContents];
        self.link_preview = [[codeArray objectAtIndex:1] allContents];
        self.link_miniature = [[codeArray objectAtIndex:3] allContents];
        
        self.nolink_full = [[codeArray objectAtIndex:4] allContents];
        self.nolink_preview = [[codeArray objectAtIndex:5] allContents];
        self.nolink_miniature = [[codeArray objectAtIndex:7] allContents];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], self, nil] forKeys:[NSArray arrayWithObjects:@"progress", @"rehostImage", nil]]];
	}
	else {
		// ERROR .x
		//NSLog(@"ERROR: %@", [theRequest responseString]);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:@"Erreur inconnue :/"
													   delegate:self cancelButtonTitle:@"Tant pis..." otherButtonTitles:nil, nil];
		[alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0] forKey:@"progress"]];

		
	}

}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{

	//NSLog(@"fetchContentFailed %@", theRequest);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[[theRequest error] localizedDescription]
												   delegate:self cancelButtonTitle:@"Tant pis..." otherButtonTitles:nil, nil];
	
    [alert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0] forKey:@"progress"]];

}


@end
