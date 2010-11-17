//
//  ShakeView.h
//  HFR+
//
//  Created by Lace on 17/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShakeView : UIView {
	id view_delegate; //the delegate object

}
-(void) setShakeDelegate:(id)new_delegate;  //set delegate method

@end

@interface NSObject (ShakeDelegate)
-(void) shakeHappened:(ShakeView*)view;   //This is the delegate method, that my ViewController should implement in order to respond to the shake event.
@end