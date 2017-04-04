//
//  SettingsViewController.m
//  HFRplus
//
//  Created by FLK on 05/07/12.
//

#import "SettingsViewController.h"
#import "HFRplusAppDelegate.h"
#import "IASKSettingsReader.h"
#import "ThemeColors.h"
#import "ThemeManager.h"

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

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
     IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    settingsVC.neverShowPrivacySettings = YES;
    NSLog(@"awakeFromNib");
    
    self.delegate = self;
}

-(void)viewDidLoad {
    //NSLog(@"viewDidLoadviewDidLoadviewDidLoadviewDidLoad");
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    
    NSSet *hiddenKeys;
    
    // Désactivation de la configuration du thème pour iOS 5-6
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        hiddenKeys = [NSSet setWithObjects:@"theme", nil];
    }
    
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];
    IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    
    if (!enabled) {
        hiddenKeys = [hiddenKeys setByAddingObject:@"menu_debug_entry"];
    }
    
    //NSLog(@"hiddenKeys %@", hiddenKeys);
    
    settingsVC.hiddenKeys = hiddenKeys;//enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}



#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    //NSLog(@"settingDidChange %@", notification);

    if ([notification.object isEqual:@"menu_debug"]) {
        //IASKAppSettingsViewController *activeController = self;
        NSSet *hiddenKeys;
        
        // Désactivation de la configuration du thème pour iOS 5-6
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            hiddenKeys = [NSSet setWithObjects:@"theme", nil];
        }
        
        BOOL enabled = (BOOL)[[notification.userInfo objectForKey:@"menu_debug"] intValue];
        
        IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    
        //((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]).hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
        
        if (!enabled) {
            hiddenKeys = [hiddenKeys setByAddingObject:@"menu_debug_entry"];
        }
        
        //NSLog(@"hiddenKeys %@", hiddenKeys);
        
        settingsVC.hiddenKeys = hiddenKeys;//enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
        
        //[activeController setHiddenKeys:enabled ? nil : [NSSet setWithObjects:@"AutoConnectTest", nil] animated:YES];
        
    }else if([notification.object isEqual:@"theme"]) {
        
        Theme theme = (Theme)[[notification.userInfo objectForKey:@"theme"] intValue];
        [[ThemeManager sharedManager] setTheme:theme];
        [self setThemeColors:theme];
    }
    
    [self.tableView reloadData];
}

-(void)setThemeColors:(Theme)theme{
    [self.navigationController.navigationBar setBackgroundImage:[ThemeColors imageFromColor:[ThemeColors navBackgroundColor:theme]] forBarMetrics:UIBarMetricsDefault];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationController.navigationBar setTintColor:[ThemeColors tintColor:theme]];
    }

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors textColor:theme]}];
    [self.navigationController.navigationBar setNeedsDisplay];
    self.view.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.tableView.separatorColor = [ThemeColors cellBorderColor:theme];

    [self.tableView reloadData];

}


-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *hv = (UITableViewHeaderFooterView *)view;
    hv.textLabel.textColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *hv = (UITableViewHeaderFooterView *)view;
    hv.textLabel.textColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[ThemeManager sharedManager] applyThemeToCell:cell];
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
    //NSLog(@"settingsViewController");
    
    
    
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


