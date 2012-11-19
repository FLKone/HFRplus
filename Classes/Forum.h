//
//  Forum.h
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import <Foundation/Foundation.h>


@interface Forum : NSObject {
	NSString *aTitle;
	NSString *aURL;
	NSString *aID;
	NSMutableArray *subCats;
}

@property (nonatomic, retain) NSString *aTitle;
@property (nonatomic, retain) NSString *aURL;
@property (nonatomic, retain) NSString *aID;
@property (nonatomic, retain) NSMutableArray *subCats;

@end