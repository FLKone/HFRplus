//
//  Topic.h
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import <Foundation/Foundation.h>


@interface Topic : NSObject {
	//NSString *_aTitle;
	NSString *aURL;

	int aRepCount;
	
	BOOL isViewed;
	
	NSString *aURLOfFirstPage;
    
	NSString *aURLOfFlag;
	NSString *aTypeOfFlag;

	NSString *aURLOfLastPost;
	NSString *aURLOfLastPage;
	
	NSString *aDateOfLastPost;
	NSString *aAuthorOfLastPost;

	NSString *aAuthorOrInter;
    
    int maxTopicPage;
    int curTopicPage;
    
	int postID;
	int catID;
    
    bool isSticky;
    bool isClosed;
}

@property (nonatomic, strong) NSString *_aTitle;
- (void)setATitle:(NSString *)n;
@property (nonatomic, strong) NSString *aURL;

@property int aRepCount;
@property BOOL isViewed;

@property (nonatomic, strong) NSString *aURLOfFirstPage;

@property (nonatomic, strong) NSString *aURLOfFlag;
@property (nonatomic, strong) NSString *aTypeOfFlag;

@property (nonatomic, strong) NSString *aURLOfLastPost;
@property (nonatomic, strong) NSString *aURLOfLastPage;
@property (nonatomic, strong) NSString *aDateOfLastPost;
@property (nonatomic, strong) NSString *aAuthorOfLastPost;

@property (nonatomic, strong) NSString *aAuthorOrInter;

@property int maxTopicPage;
@property int curTopicPage;

@property int postID;
@property int catID;

@property bool isSticky;
@property bool isClosed;

- (NSString*) aTitle;

@end
