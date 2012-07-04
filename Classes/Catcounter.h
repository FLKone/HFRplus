//
//  Catcounter.h
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import <Foundation/Foundation.h>


@interface Catcounter : NSObject {
	NSString *name;
	NSNumber *id;
	int length;
	int lengthB4;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *id;

@property int length;
@property int lengthB4;

@end
