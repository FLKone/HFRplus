//
//  Forum.h
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Forum : NSObject {
	NSString *aTitle;
	NSString *aURL;
	NSMutableArray *subCats;
}

@property (nonatomic, retain) NSString *aTitle;
@property (nonatomic, retain) NSString *aURL;
@property (nonatomic, retain) NSMutableArray *subCats;

-(int)getHFRID;
-(NSString *)getImage;
-(NSString *)URLforType:(FLAGTYPE)type;

@end