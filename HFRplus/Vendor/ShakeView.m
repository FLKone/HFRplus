//
//  ShakeView.m
//  HFRplus
//
//  Created by FLK on 17/07/10.
//

#import "ShakeView.h"


@implementation ShakeView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(void) setShakeDelegate:(id)new_delegate
{
	view_delegate = new_delegate;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
		//NSLog(@"IT SHOOK ME");	
		if ([view_delegate respondsToSelector:@selector(shakeHappened:)])
			[view_delegate shakeHappened:self]; //not necessary to pass yourself along.
		
	}
	
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{ return YES; }

- (void)dealloc {
    [super dealloc];
}


@end
