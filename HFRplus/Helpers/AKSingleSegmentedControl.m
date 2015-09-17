#import "AKSingleSegmentedControl.h"
#import "Constants.h"

@implementation AKSingleSegmentedControl

- (id)initWithItem:(id)item {
    NSArray *a = [NSArray arrayWithObject:item];
    return [super initWithItems:a];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger oldValue = self.selectedSegmentIndex;
    
    //NSLog(@"touchesBegan %d", oldValue);
    
    [super touchesBegan:touches withEvent:event];
    
    //NSLog(@"selectedSegmentIndex %d", self.selectedSegmentIndex);
    
    if ( oldValue == self.selectedSegmentIndex )
    {
        [self setSelectedSegmentIndex:-1];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }        

    }
}

@end