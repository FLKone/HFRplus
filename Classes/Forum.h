//
//  Forum.h
//  HFRplus
//
//  Created by Lace on 19/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Forum : NSObject {
	NSString *aTitle;
	NSString *aURL;
	NSString *aID;
	NSArray *subCats;
}

@property (nonatomic, retain) NSString *aTitle;
@property (nonatomic, retain) NSString *aURL;
@property (nonatomic, retain) NSString *aID;
@property (nonatomic, retain) NSArray *subCats;

@end
