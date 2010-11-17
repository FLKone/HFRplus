//
//  RangeOfCharacters.m
//  HFR+
//
//  Created by Lace on 14/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RangeOfCharacters.h"

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
	NSString *linkBase16 = [NSString stringWithString:@"0A12B34C56D78E9F"];
	NSString *linkQuoteUnCrypted = [[[NSString alloc] init] autorelease];
	
	NSRange chRange, clRange;
	
	int i = 0;
		
	//NSLog(@"linkQuoteCrypted : %@", linkQuoteCrypted);
	linkQuoteUnCrypted = @"";
	
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
	NSString *linkBase16 = [NSString stringWithString:@"0A12B34C56D78E9F"];
	NSString *linkQuoteUnCrypted = [[[NSString alloc] init] autorelease];
	
	NSRange chRange, clRange;
	
	int i = 0;
	
	//NSLog(@"linkQuoteCrypted : %@", linkQuoteCrypted);
	linkQuoteUnCrypted = @"";
	
	for (i=0; i<linkQuoteCrypted.length; i+=2){
		
		chRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:i]]];
		clRange = [linkBase16 rangeOfString:[NSString stringWithFormat:@"%c", [linkQuoteCrypted characterAtIndex:(i+1)]]];	
		//NSLog(@"%d - %c /// %d - %c", i, [linkQuoteCrypted characterAtIndex:i], i+1, [linkQuoteCrypted characterAtIndex:i+1]);
		
		linkQuoteUnCrypted = [linkQuoteUnCrypted stringByAppendingFormat:@"%c", (chRange.location*16)+clRange.location];
	}
	
    return linkQuoteUnCrypted;
}

@end