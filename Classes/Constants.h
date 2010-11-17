//
//  Constants.h
//  HFR+
//
//  Created by FLK on 05/08/10.
//

#import <Foundation/Foundation.h>

typedef enum {
	kIdle,
	kMaintenance,
	kNoResults,
	kComplete
} STATUS;

#define kForumURL				@"http://forum.hardware.fr"

#define kTimeoutMini		30
#define kTimeoutMaxi		60

#define MAX_HEIGHT 1200.0f 
#define MAX_CELL_CONTENT 300.0f
#define MAX_TEXT_WIDTH 250.0f

#ifndef DEBUG_LOGS
	#define DEBUG_LOGS 0
#endif