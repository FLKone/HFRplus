//
//  MenuButton.m
//  HFRplus
//
//  Created by Shasta on 16/06/13.
//
//

#import "MenuButton.h"

@implementation MenuButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan");
    
    [super touchesBegan:touches withEvent:event];
    //self.highlighted = self.selected = !self.selected;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesMoved");

    [super touchesMoved:touches withEvent:event];
    //self.selected = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesEnded SEL %d HIGH %d", self.selected, self.highlighted);
    
    [super touchesEnded:touches withEvent:event];
    //self.selected = self.highlighted;
}

- (void)setSelected:(BOOL)selected{
    //NSLog(@"setSelected");
    
    [super setSelected:selected];
    //self.selected = YES;
}


- (void)setHighlighted:(BOOL)highlighted{
    //NSLog(@"setHighlighted %d", highlighted);
    //NSLog(@"SEL %d HIGH %d", self.selected, self.highlighted);

    [super setHighlighted:highlighted];

    
    if (self.selected) {
        //[super setHighlighted:NO];
    }
    else
    {
        //NSLog(@"set HL %d", highlighted);
        //[super setHighlighted:NO];
        //self.selected = YES;
    }
    //self.selected = YES;
}

@end