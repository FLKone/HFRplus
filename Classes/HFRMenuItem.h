//
//  HFRMenuItem.h
//  HFRplus
//
//  Created by Shasta on 12/10/10.
//


@interface HFRMenuItem : UIMenuItem {
	int index;
	SEL selector;
}
@property int index;
@property SEL selector;
@end
