//
//  RangeOfCharacters.h
//  HFR+
//
//  Created by Lace on 14/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (RangeOfCharacters)
/* note "Characters" is plural in the methods. It has poor readability, hard to 
 * distinguish from the rangeOfCharacterFromSet: methods, but it's standard Apple 
 * convention.
 */
-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet;
-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask;
-(NSRange)rangeOfCharactersFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask range:(NSRange)range;

// like the above, but return a string rather than a range
-(NSString*)substringFromSet:(NSCharacterSet*)aSet;
-(NSString*)substringFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask;
-(NSString*)substringFromSet:(NSCharacterSet*)aSet options:(NSStringCompareOptions)mask range:(NSRange)range;

-(NSString*)decodeSpanUrlFromString;
-(NSString*)decodeSpanUrlFromString2;

@end