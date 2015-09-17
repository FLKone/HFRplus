//
//  SettingsViewController.m
//  HFRplus
//
//  Created by FLK on 05/07/12.
//

#import "SettingsViewController.h"
#import "HFRplusAppDelegate.h"

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        //...
    }
    return self;
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
    
	if ([key isEqualToString:@"EmptyCacheButton"]) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Vider le cache ?" message:@"Tous les onglets (Catégories, Vos Sujets etc.) seront reinitialisés.\nAttention donc si vous êtes en train de lire un sujet intéressant :o" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Oui !", nil];
		[alert show];
	}
    else if ([key isEqualToString:@"SetCheckpoint"]) {

        //[TestFlight passCheckpoint:@"DEBUG"];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [[HFRplusAppDelegate sharedAppDelegate] resetApp];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ImageCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    NSString *SmileCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmileCache"];
    
	if ([fileManager fileExistsAtPath:ImageCachePath])
	{
		[fileManager removeItemAtPath:ImageCachePath error:NULL];
	}
    
	if ([fileManager fileExistsAtPath:SmileCachePath])
	{
		[fileManager removeItemAtPath:SmileCachePath error:NULL];
	}
    
    
    
}



#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    //NSLog(@"settingsViewControllerDidEnd");
	
	// your code here to reconfigure the app for changed settings
}

@end


