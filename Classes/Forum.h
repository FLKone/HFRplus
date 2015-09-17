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
    NSString *aID;
	NSMutableArray *subCats;
}

@property (nonatomic, strong) NSString *aTitle;
@property (nonatomic, strong) NSString *aURL;
@property (nonatomic, strong) NSString *aID;

@property (nonatomic, strong) NSMutableArray *subCats;

-(int)getHFRID;
-(NSString *)getImage;
-(NSString *)URLforType:(FLAGTYPE)type;

@end