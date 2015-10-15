//
//  HFRTabBar.m
//  HFRplus
//
//  Created by FLK on 15/10/2015.
//
//

#import "HFRTabBar.h"
#import <objc/runtime.h> // Needed for method swizzling

@implementation UITabBar(HFRTabBar)

+ (void)load
{
    NSLog(@"load UITabBar");
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(sizeThatFits:));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_sizeThatFits:));
    method_exchangeImplementations(original, swizzled);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"HFRTabBar");
}
*/
-(CGSize)swizzled_sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    //sizeThatFits.height = 44;
    
    return sizeThatFits;
}


@end
