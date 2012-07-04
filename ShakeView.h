//
//  ShakeView.h
//  HFRplus
//
//  Created by FLK on 17/07/10.
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