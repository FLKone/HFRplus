//
//  AKSegmentedControl.m
//  HFRplus
//
//  Created by Shasta on 06/10/10.
//  Copyright 2010 FLK. All rights reserved.
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