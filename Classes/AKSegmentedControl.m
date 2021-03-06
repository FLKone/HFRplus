//
//  AKSegmentedControl.m
//  HFRplus
//
//  Created by FLK on 06/10/10.
//

#import "AKSegmentedControl.h"

@implementation AKSegmentedControl

- (void)setSelectedSegmentIndex:(NSInteger)toValue {
	// Trigger UIControlEventValueChanged even when re-tapping the selected segment.
	
	if (toValue==self.selectedSegmentIndex) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
	[super setSelectedSegmentIndex:toValue];        
}

@end