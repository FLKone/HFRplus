//
//  HFRTextView.m
//  HFRplus
//
//  Created by FLK on 13/09/2015.
//
//

#import "HFRTextView.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "HFRplusAppDelegate.h"

@implementation HFRTextView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    NSLog(@"awakeFromNib");
    [super awakeFromNib]; // Don't forget to call super
    
    //Do more intitialization here
    

    UIImage *menuImgCopy = [UIImage imageNamed:@"CopyFilled-20"];
    UIImage *menuImgCut = [UIImage imageNamed:@"CutFilled-20"];
    UIImage *menuImgPaste = [UIImage imageNamed:@"PasteFilled-20"];
    
    UIImage *menuImgBold = [UIImage imageNamed:@"BoldEFilled-20"];
    UIImage *menuImgItalic = [UIImage imageNamed:@"ItalicFilled-20"];
    UIImage *menuImgUnderline = [UIImage imageNamed:@"UnderlineFilled-20"];
    UIImage *menuImgStrike = [UIImage imageNamed:@"StrikethroughFilled-20"];
    
    UIImage *menuImgSpoiler = [UIImage imageNamed:@"InvisibleFilled-20"];
    UIImage *menuImgQuote = [UIImage imageNamed:@"QuoteEFilled-20"];
    UIImage *menuImgLink = [UIImage imageNamed:@"LinkFilled-20"];
    UIImage *menuImgImage = [UIImage imageNamed:@"XlargeIconsFilled-20"];
    
    UIMenuItem *textCutItem = [[UIMenuItem alloc] initWithTitle:@"HFRCut" action:@selector(textCut:) image:menuImgCut];
    UIMenuItem *textCopyItem = [[UIMenuItem alloc] initWithTitle:@"HFRCopy" action:@selector(textCopy:) image:menuImgCopy];
    UIMenuItem *textPasteItem = [[UIMenuItem alloc] initWithTitle:@"HFRPaste" action:@selector(textPaste:) image:menuImgPaste];
    
    UIMenuItem *textBoldItem = [[UIMenuItem alloc] initWithTitle:@"B" action:@selector(textBold:) image:menuImgBold];
    UIMenuItem *textItalicItem = [[UIMenuItem alloc] initWithTitle:@"I" action:@selector(textItalic:) image:menuImgItalic];
    UIMenuItem *textUnderlineItem = [[UIMenuItem alloc] initWithTitle:@"U" action:@selector(textUnderline:) image:menuImgUnderline];
    UIMenuItem *textStrikeItem = [[UIMenuItem alloc] initWithTitle:@"S" action:@selector(textStrike:) image:menuImgStrike];
    
    UIMenuItem *textSpoilerItem = [[UIMenuItem alloc] initWithTitle:@"SPOILER" action:@selector(textSpoiler:) image:menuImgSpoiler];
    UIMenuItem *textQuoteItem = [[UIMenuItem alloc] initWithTitle:@"QUOTE" action:@selector(textQuote:) image:menuImgQuote];
    UIMenuItem *textLinkItem = [[UIMenuItem alloc] initWithTitle:@"URL" action:@selector(textLink:) image:menuImgLink];
    UIMenuItem *textImgItem = [[UIMenuItem alloc] initWithTitle:@"IMG" action:@selector(textImg:) image:menuImgImage];
    
    // On rajoute les menus pour le style
    
    /*
     UIMenuItem *textBoldItem = [[[UIMenuItem alloc] initWithTitle:@"B" action:@selector(textBold:)] autorelease];
     UIMenuItem *textItalicItem = [[[UIMenuItem alloc] initWithTitle:@"I" action:@selector(textItalic:)] autorelease];
     UIMenuItem *textUnderlineItem = [[[UIMenuItem alloc] initWithTitle:@"U" action:@selector(textUnderline:)] autorelease];
     UIMenuItem *textStrikeItem = [[[UIMenuItem alloc] initWithTitle:@"S" action:@selector(textStrike:)] autorelease];
     
     UIMenuItem *textSpoilerItem = [[[UIMenuItem alloc] initWithTitle:@"SPOILER" action:@selector(textSpoiler:)] autorelease];*/
    UIMenuItem *textFixeItem = [[UIMenuItem alloc] initWithTitle:@"FIXED" action:@selector(textFixe:)];
    //UIMenuItem *textCppItem = [[[UIMenuItem alloc] initWithTitle:@"CPP" action:@selector(textStrike:)] autorelease];
    //UIMenuItem *textMailItem = [[[UIMenuItem alloc] initWithTitle:@"@" action:@selector(textStrike:)] autorelease];
    
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:textCutItem, textCopyItem, textPasteItem,
                                                           textBoldItem, textItalicItem, textUnderlineItem, textStrikeItem,
                                                           textSpoilerItem, textQuoteItem, textLinkItem, textImgItem, textFixeItem, nil]];
    
}


- (BOOL)canPerformAction: (SEL)action withSender: (id)sender {
    //NSLog(@"MWVINADDTW %@ %lu", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count);

    
    
    if (action == @selector(textBold:)) return YES;
    if (action == @selector(textItalic:)) return YES;
    if (action == @selector(textUnderline:)) return YES;
    if (action == @selector(textStrike:)) return YES;
    if (action == @selector(textSpoiler:)) return YES;
    if (action == @selector(textQuote:)) return YES;
    if (action == @selector(textLink:)) return YES;
    if (action == @selector(textImg:)) return YES;
    if (action == @selector(textFixe:)) return YES;

    if (action == @selector(textCut:)) return [super canPerformAction:@selector(cut:) withSender:sender];
    if (action == @selector(textCopy:)) return [super canPerformAction:@selector(copy:) withSender:sender];
    if (action == @selector(textPaste:)) return [super canPerformAction:@selector(paste:) withSender:sender];
    
    if (action == @selector(cut:)) return NO;
    if (action == @selector(copy:)) return NO;
    if (action == @selector(select:)) return  [super canPerformAction:@selector(select:) withSender:sender];
    if (action == @selector(selectAll:)) return [super canPerformAction:@selector(selectAll:) withSender:sender];
    if (action == @selector(paste:)) return NO;

    if ([NSStringFromSelector(action) isEqualToString:@"replace:"]) return [super canPerformAction:action withSender:sender];
    if ([NSStringFromSelector(action) isEqualToString:@"_promptForReplace:"]) return [super canPerformAction:action withSender:sender];
    
    return NO;
}

-(void)insertBBCode:(NSString *)code {
    NSMutableString *localtext = [self.text mutableCopy];
    
    NSRange localSelectedRange = self.selectedRange;
    NSLog(@"selectRng %lu %lu", (unsigned long)localSelectedRange.location, (unsigned long)localSelectedRange.length);
    
    //NSLog(@"selectedRange %d %d", selectedRange.location, selectedRange.location);
    
    bool wasSelected = NO;
    if (localSelectedRange.length) {
        wasSelected = YES;
    }
    
    [localtext insertString:[NSString stringWithFormat:@"[/%@]", code] atIndex:localSelectedRange.location+localSelectedRange.length];
    [localtext insertString:[NSString stringWithFormat:@"[%@]", code] atIndex:localSelectedRange.location];
    
    
    //NSLog(@"selectedRange %d %d", selectedRange.location, selectedRange.length);
    
    if (localSelectedRange.length > 0) {
        localSelectedRange.location += (code.length * 2) + 5 + localSelectedRange.length;
    }
    else {
        localSelectedRange.location += code.length + 2;
    }
    
    localSelectedRange.length = 0;
    
    
    
    self.text = localtext;
    self.selectedRange = localSelectedRange;
    
    if ([UIPasteboard generalPasteboard].string.length) {
        
        
        if ([code isEqualToString:@"url"] && wasSelected) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insérer le contenu du presse-papier?"
                                                            message:[NSString stringWithFormat:@"%@", [UIPasteboard generalPasteboard].string]
                                                           delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"[url= Oui ]", nil];
            [alert setTag:668];
            [alert show];
        }
        else if ([code isEqualToString:@"url"] && !wasSelected) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insérer le contenu du presse-papier?"
                                                            message:[NSString stringWithFormat:@"%@", [UIPasteboard generalPasteboard].string]
                                                           delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"[url= Oui ]", @"[url] Oui [/url]", nil];
            [alert setTag:667];
            [alert show];
        }
        else if (!wasSelected) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insérer le contenu du presse-papier?"
                                                            message:[NSString stringWithFormat:@"%@", [UIPasteboard generalPasteboard].string]
                                                           delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
            [alert setTag:666];
            [alert show];
        }

    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%ld = %ld", (long)buttonIndex, (long)alertView.tag);
    
    if ((buttonIndex == 1 && alertView.tag == 666) || (buttonIndex == 2 && alertView.tag == 667)) {
        NSRange localSelectedRange = self.selectedRange;
        NSLog(@"selectRng %lu %lu", (unsigned long)localSelectedRange.location, (unsigned long)localSelectedRange.length);
        
        NSMutableString *localtext = [self.text mutableCopy];
        
        [localtext insertString:[NSString stringWithFormat:@"%@", [UIPasteboard generalPasteboard].string] atIndex:localSelectedRange.location];
        self.text = localtext;
        localSelectedRange.location += [UIPasteboard generalPasteboard].string.length;
        localSelectedRange.length = 0;
        self.selectedRange =  localSelectedRange;
    }
    else if (alertView.tag == 667 || alertView.tag == 668) {
        
        if (buttonIndex == 1) { //url=

            
            NSRange localSelectedRange = self.selectedRange;
            //NSLog(@"selectRng %lu %lu", (unsigned long)localSelectedRange.location, (unsigned long)localSelectedRange.length);
            NSMutableString *localtext = [self.text mutableCopy];

            //On cherche [url] backward
            NSRange rangeToSearch = NSMakeRange(0, localSelectedRange.location); // get a range without the space character
            NSRange rangeOfSecondToLastSpace = [localtext rangeOfString:@"[url]" options:NSBackwardsSearch range:rangeToSearch];

            
            
            [localtext insertString:[NSString stringWithFormat:@"=%@", [UIPasteboard generalPasteboard].string] atIndex:rangeOfSecondToLastSpace.location  + 4];

            localSelectedRange.location += [UIPasteboard generalPasteboard].string.length + 4;
            localSelectedRange.length = 0;
            
            self.text = localtext;
            self.selectedRange =  localSelectedRange;
        }
    }
}


- (void)textCut:(id)sender {
    [super cut:(id)sender];
}
- (void)textCopy:(id)sender {
    [super copy:(id)sender];
}
- (void)textPaste:(id)sender {
    [super paste:(id)sender];
}



- (void)textBold:(id)sender{
    [self insertBBCode:@"b"];
}
- (void)textItalic:(id)sender{
    [self insertBBCode:@"i"];
}
- (void)textUnderline:(id)sender{
    [self insertBBCode:@"u"];
}
- (void)textStrike:(id)sender{
    [self insertBBCode:@"strike"];
}
- (void)textSpoiler:(id)sender{
    [self insertBBCode:@"spoiler"];
}
- (void)textFixe:(id)sender{
    [self insertBBCode:@"fixed"];
}
- (void)textQuote:(id)sender{
    [self insertBBCode:@"quote"];
}
- (void)textLink:(id)sender{
    [self insertBBCode:@"url"];
}
- (void)textImg:(id)sender{
    [self insertBBCode:@"img"];
}

@end