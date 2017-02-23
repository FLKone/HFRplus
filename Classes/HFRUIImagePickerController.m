//
//  HFRUIImagePickerController.m
//  HFRplus
//
//  Created by Aynolor on 18.02.17.
//
//

#import "HFRUIImagePickerController.h"
#import "ThemeColors.h"
#import "ThemeManager.h"

@interface HFRUIImagePickerController ()

@end

@implementation HFRUIImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [ThemeColors statusBarStyle:[[ThemeManager sharedManager] theme]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
