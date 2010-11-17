//
//  Topic.h
//  HFRplus
//
//  Created by Lace on 19/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Topic : NSObject {
	NSString *aTitle;
	NSString *aURL;

	int aRepCount;
	
	BOOL isViewed;
	
	NSString *aURLOfFlag;
	NSString *aTypeOfFlag;

	NSString *aURLOfLastPost;
	NSString *aURLOfLastPage;
	
	NSString *aDateOfLastPost;
	NSString *aAuthorOfLastPost;

	NSString *aAuthorOrInter;
}

@property (nonatomic, retain) NSString *aTitle;
@property (nonatomic, retain) NSString *aURL;

@property int aRepCount;
@property BOOL isViewed;

@property (nonatomic, retain) NSString *aURLOfFlag;
@property (nonatomic, retain) NSString *aTypeOfFlag;

@property (nonatomic, retain) NSString *aURLOfLastPost;
@property (nonatomic, retain) NSString *aURLOfLastPage;
@property (nonatomic, retain) NSString *aDateOfLastPost;
@property (nonatomic, retain) NSString *aAuthorOfLastPost;

@property (nonatomic, retain) NSString *aAuthorOrInter;

@end
