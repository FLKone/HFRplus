//
//  IASKSpecifierValuesViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKSpecifierValuesViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKMultipleValueSelection.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "Constants.h"

#define kCellValue      @"kCellValue"

@interface IASKSpecifierValuesViewController()

@property (nonatomic, strong, readonly) IASKMultipleValueSelection *selection;

@end

@implementation IASKSpecifierValuesViewController

@synthesize tableView=_tableView;
@synthesize currentSpecifier=_currentSpecifier;
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;

- (void)setSettingsStore:(id <IASKSettingsStore>)settingsStore {
    _settingsStore = settingsStore;
    _selection.settingsStore = settingsStore;
}

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.view = _tableView;

    _selection = [IASKMultipleValueSelection new];
    _selection.tableView = _tableView;
    _selection.settingsStore = _settingsStore;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
        _selection.specifier = _currentSpecifier;
    }
    
    if (_tableView) {
        [_tableView reloadData];

		// Make sure the currently checked item is visible
        [_tableView scrollToRowAtIndexPath:_selection.checkedItem
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setThemeFromNotification:) //note the ":" - should take an NSNotification as parameter
                                                 name:kThemeChangedNotification
                                               object:nil];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}


-(void)setThemeFromNotification:(NSNotification *)notification{
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}

-(void)setThemeColors:(Theme)theme{
    self.tableView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.tableView.separatorColor = [ThemeColors cellBorderColor:theme];
    [_tableView reloadData];

    
}

- (void)viewDidAppear:(BOOL)animated {
	[_tableView flashScrollIndicators];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    //_selection.tableView = nil;
}

- (void)dealloc {
    NSLog(@"deallocdeallocdeallocdealloc");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentSpecifier multipleValuesCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:kCellValue];
    NSArray *titles         = [_currentSpecifier multipleTitles];
	
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue];
    }

    [_selection updateSelectionInCell:cell indexPath:indexPath];

    @try {
		[[cell textLabel] setText:[self.settingsReader titleForStringId:[titles objectAtIndex:indexPath.row]]];
	}
	@catch (NSException * e) {}
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    
    [[ThemeManager sharedManager] applyThemeToCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_selection selectRowAtIndexPath:indexPath];
}

- (CGSize)contentSizeForViewInPopover {
    return [[self view] sizeThatFits:CGSizeMake(320, 2000)];
}

@end
