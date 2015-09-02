//
//  RangeOfCharacters.m
//  HFRplus
//
//  Created by FLK on 14/07/10.
//

#import "RangeOfCharacters.h"
#import "RegexKitLite.h"

@implementation NSString (RangeOfCharacters)
-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet {
    return [self rangeOfCharactersFromSet:aSet options:0];
}

-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask {
    NSRange range = {0,[self length]};
    return [self rangeOfCharactersFromSet:aSet options:mask range:range];
}

-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask range:(NSRange)range {
    NSInteger start, curr, end, step=1;
    if (mask & NSBackwardsSearch) {
        step = -1;
        start = range.location + range.length - 1;
        end = range.location-1;
    } else {
        start = range.location;
        end = start + range.length;
    }
    if (!(mask & NSAnchoredSearch)) {
        // find first character in set
        for (;start != end; start += step) {
            if ([aSet characterIsMember:[self characterAtIndex:start]]) {
#ifdef NOGOTO
                break;
#else
                // Yeah, a goto. If you don't like them, define NOGOTO.
                // Method will work the same, it will just make unneeded
                // test whether character at start is in aSet
                goto FoundMember;
#endif
            }
        }
#ifndef NOGOTO
        goto NoSuchMember;
#endif
    }
    if (![aSet characterIsMember:[self characterAtIndex:start]]) {
    NoSuchMember:
        // no characters found within given range
        range.location = NSNotFound;
        range.length = 0;
        return range;
    }
	
FoundMember:
    for (curr = start; curr != end; curr += step) {
        if (![aSet characterIsMember:[self characterAtIndex:curr]]) {
            break;
        }
    }
    if (curr < start) {
        // search was backwards
        range.location = curr+1;
        range.length = start - curr;
    } else {
        range.location = start;
        range.length = curr - start;
    }
    return range;
}

-(NSString*)substringFromSet:(NSCharacterSet*)aSet {
    return [self substringFromSet:aSet options:0];
}

-(NSString*)substringFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask  {
    NSRange range = {0,[self length]};
    return [self substringFromSet:aSet options:mask range:range];
}
-(NSString*)substringFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask range:(NSRange)range {
    range = [self rangeOfCharactersFromSet:aSet options:mask range:range];
    
	if (NSNotFound == range.location) {
        return nil;
    }
    return [self substringWithRange:range]; 
}


-(NSString*)decodeSpanUrlFromString {
	
	NSString *linkQuoteCrypted = [self substringFromIndex:20];
	NSString *linkBase16 = @"0A12B34C56D78E9F";
	NSString *linkQuoteUnCrypted = [[[NSString alloc] initWithString:@""] autorelease];
	
	NSRange chRange, clRange;
	
	int i = 0;
		
	//NSLog(@"linkQuoteCrypted : %@", linkQuoteCrypted);
	
	for (i=0; i<linkQuoteCrypted.length; i+=2){
		
		chRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:i]]];
		clRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:(i+1)]]];	
		//NSLog(@"%d - %c /// %d - %c", i, [linkQuoteCrypted characterAtIndex:i], i+1, [linkQuoteCrypted characterAtIndex:i+1]);
		
		linkQuoteUnCrypted = [linkQuoteUnCrypted stringByAppendingFormat:@"%c", (chRange.location*16)+clRange.location];
	}
	
    return linkQuoteUnCrypted;
}

-(NSString*)decodeSpanUrlFromString2 {
	
	NSString *linkQuoteCrypted = [self substringFromIndex:12];
	NSString *linkBase16 = @"0A12B34C56D78E9F";
	NSString *linkQuoteUnCrypted = [[[NSString alloc] initWithString:@""] autorelease];
	
	NSRange chRange, clRange;
	
	int i = 0;
	
	//NSLog(@"linkQuoteCrypted : %@", linkQuoteCrypted);
	
	for (i=0; i<linkQuoteCrypted.length; i+=2){
		
		chRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:i]]];
		clRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:(i+1)]]];	
		//NSLog(@"%d - %c /// %d - %c", i, [linkQuoteCrypted characterAtIndex:i], i+1, [linkQuoteCrypted characterAtIndex:i+1]);
		
		linkQuoteUnCrypted = [linkQuoteUnCrypted stringByAppendingFormat:@"%c", (chRange.location*16)+clRange.location];
	}
	
    return linkQuoteUnCrypted;
}

- (NSString *)stringByDecodingXMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
	
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
	
    [scanner setCharactersToBeSkipped:nil];
	
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
			
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
			
            if (gotNumber) {
                [result appendFormat:@"%C", charCode];
				
				[scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
				
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				
				
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity];
				
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
				
            }
			
        }
        else {
			NSString *amp;
			
			[scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
			[result appendString:amp];
			
			/*
			 NSString *unknownEntity = @"";
			 [scanner scanUpToString:@";" intoString:&unknownEntity];
			 NSString *semicolon = @"";
			 [scanner scanString:@";" intoString:&semicolon];
			 [result appendFormat:@"%@%@", unknownEntity, semicolon];
			 NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
			 */
        }
		
    }
    while (![scanner isAtEnd]);
	
finish:
    return result;
}


-(NSString*) decodeHtmlUnicodeCharacters: (NSString*) html {
	NSString* result = [html copy];
	NSArray* matches = [result arrayOfCaptureComponentsMatchedByRegex: @"\\&#([\\d]+);"];
	
	if (![matches count]) 
		return result;
	
	for (int i=0; i<[matches count]; i++) {
		NSArray* array = [matches objectAtIndex: i];
		NSString* charCode = [array objectAtIndex: 1];
		int code = [charCode intValue];
		NSString* character = [NSString stringWithFormat:@"%C", code];
		result = [result stringByReplacingOccurrencesOfString: [array objectAtIndex: 0]
												   withString: character];      
	}   
	return result; 
}

-(NSString*)stringByRemovingAnchor {
    
    NSString *regexString  = @".*#([^&]+).*";
    NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
    NSRange   searchRange = NSMakeRange(0, self.length);
    NSError  *error2        = NULL;
    //int numPage;
    
    matchedRange = [self rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
    
    if (matchedRange.location == NSNotFound) {

    }
    else {
        self = [self substringToIndex:(matchedRange.location - 1)];
    }

    
    
    return self;
    
}

-(NSString*)wordAfterString:(NSString*)searchString
{
    NSRange searchRange, foundRange, foundRange2, resultRange;//endRange
	
    foundRange = [self rangeOfString:searchString];
    //endRange = [selfString rangeOfString:@"&subcat"];
	
    if ((foundRange.length == 0) ||
        (foundRange.location == 0))
    {
        // searchString wasn't found or it was found first in the string
        return @"";
    }
    // start search before the found string
    //searchRange = NSMakeRange(foundRange.location, endRange.location-foundRange.location);
	
	searchRange.location = foundRange.location;
	searchRange.length = foundRange.length + 4;
	
	//NSLog (@"URLS: %@", selfString);
	//NSLog (@"URLS: %@", arrayFavs3);
	
	foundRange2 = [self rangeOfString:@"&" options:NSBackwardsSearch range:searchRange];
	
	
    resultRange = NSMakeRange(foundRange.location+foundRange.length, foundRange2.location-foundRange.location-foundRange.length);
	
    return [self substringWithRange:resultRange];
}

- (NSString*)removeEmoji {
    __block NSMutableString* temp = [NSMutableString string];
    
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}

- (NSString *)filterTU {
    
    self = [self stringByReplacingOccurrencesOfString:@"topic unique" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"T.U." withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"topik unique" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"toupik ounik" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"topique unique" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"topic unik" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"topik unik" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"topic officiel" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"TOPIKUNIK" withString:@"TU" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];

    return self;
}

- (NSString *)stripHTML
{
    NSRange range;
    NSString *str = [self copy];
    while ((range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        str = [str stringByReplacingCharactersInRange:range withString:@""];
    return str;
}



@end

@implementation UILabel (MultiLineAutoSize)

- (void)adjustFontSizeToFit
{
    UIFont *font = self.font;
    CGSize size = self.frame.size;
    
    for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumFontSize; maxSize -= 1.f)
    {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        if(labelSize.height <= size.height)
        {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout];
}

@end