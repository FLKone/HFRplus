//
//  parseMessagesOperation.m
//  HFRplus
//
//  Created by FLK on 06/08/10.
//

#import "Constants.h"

#import "ParseMessagesOperation.h"
#import "LinkItem.h"
#import "RegexKitLite.h"
#import "HTMLParser.h"

#import "RangeOfCharacters.h"
#import <CommonCrypto/CommonDigest.h>

#import "ASIHTTPRequest.h"
#import "BlackList.h"

@interface ParseMessagesOperation ()
@property (nonatomic, assign) id <ParseMessagesOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) LinkItem *workingEntry;
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, assign) int index;
@property (nonatomic, retain) NSOperationQueue *queue;
@end

@implementation ParseMessagesOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, reverse, index, queue;

-(id)initWithData:(NSData *)data index:(int)theIndex reverse:(BOOL)isReverse delegate:(id <ParseMessagesOperationDelegate>)theDelegate
//- (id)initWithData:(NSData *)data delegate:(id <ParseMessagesOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
		self.index = theIndex;
		self.reverse = isReverse;

        self.queue = [[[NSOperationQueue alloc] init] autorelease];

    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{

    [dataToParse release];
    [workingEntry release];
    [workingArray release];
    	
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	if ([self isCancelled])
	{
		//NSLog(@"main canceled");		
	}	
	self.workingArray = [NSMutableArray array];

	NSError * error = nil;
	HTMLParser *myParser = [[HTMLParser alloc] initWithData:dataToParse error:&error];
	
	if (![self isCancelled])
	{
		[self.delegate didStartParsing:myParser];
        
        
        [self parseData:myParser];
        
        [self.queue waitUntilAllOperationsAreFinished];
        
        if (![self isCancelled])
        {
            [self.delegate didFinishParsing:self.workingArray];
            
        }
        
	}
    
    [myParser release], myParser = nil;
	
	[pool release];
	


}

-(void)parseData:(HTMLParser *)myParser{
	
	if ([self isCancelled]) {
		return;
	}
	

    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutAvatar];    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *diskCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"] retain];
	
	if (![fileManager fileExistsAtPath:diskCachePath])
	{
		//NSLog(@"createDirectoryAtPath");
		[[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	else {
		//NSLog(@"pas createDirectoryAtPath");
	}

	HTMLNode * bodyNode = [myParser body]; //Find the body tag

	//NSLog(@"rawContentsOfNode bodyNode : %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));
	
	NSArray * messagesNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"messagetable" allowPartial:NO]; //Get all the <img alt="" />

	//NSLog(@"%f message %d", [thenT timeIntervalSinceNow] * -1000.0, [messagesNodes count]);
	
	for (HTMLNode * messageNode2 in messagesNodes) { //Loop through all the tags
		
		//NSAutoreleasePool * pool2 = [[NSAutoreleasePool alloc] init];
		
		HTMLNode * messageNode = [messageNode2 firstChild];
		
		if (![self isCancelled]) {
			//NSDate *then = [NSDate date]; // Create a current date
			
			//NSLog(@"====================================/nrawContentsOfNode messageNode : %@", rawContentsOfNode([messageNode2 _node], [myParser _doc]));


			
			HTMLNode * authorNode = [messageNode findChildWithAttribute:@"class" matchingName:@"s2" allowPartial:NO];
			
			LinkItem *fasTest = [[LinkItem alloc] init];
			
			if ([[[[messageNode parent] parent] getAttributeNamed:@"class"] isEqualToString:@"messagetabledel"]) {
				fasTest.isDel = YES;
			}
			else {
				fasTest.isDel = NO;
			}

			
			
			fasTest.postID = [[[messageNode firstChild] firstChild] getAttributeNamed:@"name"];
			
			fasTest.name = [authorNode allContents];
			fasTest.name = [fasTest.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			//fasTest.name = [[fasTest.name componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
			
			if ([fasTest.name isEqualToString:@"Publicité"]) {
				[fasTest release];
				//[pool2 drain];
				continue;
			}
            
            if ([[BlackList shared] isBL:fasTest.name]) {
                [fasTest setIsBL:YES];
            }
            
			HTMLNode * avatarNode = [messageNode findChildWithAttribute:@"class" matchingName:@"avatar_center" allowPartial:NO];
			HTMLNode * contentNode = [messageNode findChildWithAttribute:@"id" matchingName:@"para" allowPartial:YES];
            fasTest.dicoHTML = rawContentsOfNode([contentNode _node], [myParser _doc]);
            
            if (![fasTest isBL]) {
                for (NSDictionary *dic in [[BlackList shared] getAll]) {
                    if ([fasTest.dicoHTML rangeOfString:[dic objectForKey:@"word"] options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [fasTest setIsBL:YES];
                        break;
                    }
                }
            }
            
			//NSDate *then1 = [NSDate date]; // Create a current date

			/* OLD SLOW
			HTMLNode * quoteNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"answer" allowPartial:NO] parent];
			NSString *linkQuoteUnCrypted = [[quoteNode className] decodeSpanUrlFromString];
			
			HTMLNode * editNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"edit" allowPartial:NO] parent];
			NSString *linkEditUnCrypted = [[editNode className] decodeSpanUrlFromString];

			fasTest.urlQuote = linkQuoteUnCrypted;
			fasTest.urlEdit = linkEditUnCrypted;
			*/
			// NEW FAST
			HTMLNode * quoteNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"answer" allowPartial:NO] parent];
			fasTest.urlQuote = [quoteNode className];
			
			HTMLNode * editNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"edit" allowPartial:NO] parent];
			fasTest.urlEdit = [editNode className];

            HTMLNode * alertNode = [messageNode findChildWithAttribute:@"href" matchingName:@"/user/modo.php" allowPartial:YES];
            fasTest.urlAlert = [alertNode getAttributeNamed:@"href"];
                        
			HTMLNode * profilNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"profil" allowPartial:NO] parent];
			fasTest.urlProfil = [profilNode getAttributeNamed:@"href"];
            
            
			
			HTMLNode * addFlagNode = [messageNode findChildWithAttribute:@"href" matchingName:@"addflag" allowPartial:YES];
			fasTest.addFlagUrl = [addFlagNode getAttributeNamed:@"href"];

			HTMLNode * quoteJSNode = [messageNode findChildWithAttribute:@"onclick" matchingName:@"quoter('hardwarefr'" allowPartial:YES];
			fasTest.quoteJS = [quoteJSNode getAttributeNamed:@"onclick"];

			HTMLNode * MPNode = [messageNode findChildWithAttribute:@"href" matchingName:@"/message.php?config=hfr.inc&cat=prive&sond=&p=1&subcat=&dest=" allowPartial:YES];
			fasTest.MPUrl = [MPNode getAttributeNamed:@"href"];
			
			//NSDate *then2 = [NSDate date]; // Create a current date



			//NSDate *then3 = [NSDate date]; // Create a current date

			
			//fasTest.messageNode = contentNode;
			
			HTMLNode * dateNode = [messageNode findChildWithAttribute:@"class" matchingName:@"toolbar" allowPartial:NO];
			if ([dateNode allContents]) {

				//fasTest.messageDate = [[[NSString stringWithFormat:@"%@", [dateNode allContents]] stringByReplacingOccurrencesOfString:@"Posté le " withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];	
				NSString *regularExpressionString = @".*([0-9]{2})-([0-9]{2})-([0-9]{4}).*([0-9]{2}):([0-9]{2}):([0-9]{2}).*";
				fasTest.messageDate = [[dateNode allContents] stringByReplacingOccurrencesOfRegex:regularExpressionString withString:@"$1-$2-$3 $4:$5:$6"];
			}
			else {
				fasTest.messageDate = @"";
			}
			
            //edit citation
			HTMLNode * editedNode = [messageNode findChildWithAttribute:@"class" matchingName:@"edited" allowPartial:NO];
            if ([editedNode allContents]) {
                NSString *regularExpressionString = @".*Message cité ([^<]+) fois.*";
                fasTest.quotedNB = [[[[editedNode allContents] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByDecodingXMLEntities];
                if (fasTest.quotedNB) {
                    fasTest.quotedLINK = [[editedNode findChildTag:@"a"] getAttributeNamed:@"href"];
                }
                
                NSString *regularExpressionString2 = @".*Message édité par ([^<]+).*";
                fasTest.editedTime = [[[[editedNode allContents] stringByMatching:regularExpressionString2 capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByDecodingXMLEntities];
                
                //NSLog(@"editedTime = %@", fasTest.editedTime);
                //NSLog(@"quotedLINK = %@", fasTest.quotedLINK);
            }

            
			/*NSString *regularExpressionString = @"oijlkajsdoihjlkjasdoimbrows://[^/]+/(.*)";
			stringByMatching:regularExpressionString capture:1L]
			NSPredicate *regExErrorPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExError];
			BOOL isRegExError = [regExErrorPredicate evaluateWithObject:[request responseString]];*/
			
			fasTest.imageUI = nil;

			//NSDate *then4 = [NSDate date]; // Create a current date

            //NSLog(@"%f BEFORE AVAT", [thenT timeIntervalSinceNow] * -1000.0);

            //AVATAR BY NAME v2
            
            //Key for pseudo
            const char *str = [fasTest.name UTF8String];
            unsigned char r[CC_MD5_DIGEST_LENGTH];
            CC_MD5(str, strlen(str), r);
            NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                  r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
            
            NSString *key = [diskCachePath stringByAppendingPathComponent:filename];
            
            if ([fileManager fileExistsAtPath:key]) // on check si on a deja l'avatar pour cette key
            {
                fasTest.imageUI = key;
            }
            else { 
                NSString *tmpURL = [[avatarNode firstChild] getAttributeNamed:@"src"];
                
                if (tmpURL.length > 0) { // si on a pas, on check si on a une URL
                    //NSLog(@"on DL");                                    
					//async dl 
                    
                    ASIHTTPRequest *operation = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tmpURL]];
                    [operation setCompletionBlock:^{
                        //NSLog(@"setCompletionBlock");
                        [fileManager createFileAtPath:key contents:[operation responseData] attributes:nil];
                        fasTest.imageUI = key;
                    }];
                    [operation setFailedBlock:^{
                                                NSLog(@"setFailedBlock");
                        fasTest.imageUI = nil;
                    }];
                                        
                    [self.queue addOperation:operation];
                    //async dl                    
                    
                }
            }
            //== AVATAR BY NAME v2
            
			if ([self isCancelled]) {
				[fasTest release];
				break;
			}
			
			[self.workingArray addObject:fasTest];
			[fasTest release];
			
			
			
			//NSLog(@"TOPICS Time elapsed then0		: %f", [then0 timeIntervalSinceDate:then]);
			//NSLog(@"TOPICS Time elapsed then1		: %f", [then1 timeIntervalSinceDate:then0]);
			//NSLog(@"TOPICS Time elapsed then2		: %f", [then2 timeIntervalSinceDate:then1]);
			//NSLog(@"TOPICS Time elapsed then3		: %f", [then3 timeIntervalSinceDate:then2]);
			//NSLog(@"TOPICS Time elapsed then4		: %f", [then4 timeIntervalSinceDate:then3]);
			
			//NSLog(@"TOPICS Time elapsed now			: %f", [now timeIntervalSinceDate:then4]);
			//NSLog(@"TOPICS Time elapsed Total		: %f", [now timeIntervalSinceDate:then]);
			
		}
		else {
			//canceled
			break;
		}

		
		//[pool2 drain];
		
		//break;
	}

	//NSDate *nowT = [NSDate date]; // Create a current date

	//NSLog(@"TOPICS Parse Time elapsed Total		: %f", [nowT timeIntervalSinceDate:thenT]);

	[fileManager release];
	
	[diskCachePath release];

}

@end