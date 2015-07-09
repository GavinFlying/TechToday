//
//  CLFSettingViewController.m
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFSettingViewController.h"
#import "CLFSettingCell.h"
#import "CLFAppDelegate.h"
#import "CLFNavigationController.h"
#import "JVFloatingDrawerViewController.h"
#import "CLFLoginController.h"

@implementation CLFSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat topContentInset = CLFScreenH * CLFSettingTableViewContentTopInsetToScreenHeightRatio;
    CGFloat leftContentInset = - topContentInset * 0.125;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(topContentInset, leftContentInset, 0.0, 0.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CLFSettingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFSettingCell *cell = [CLFSettingCell cellWithTableView:tableView];
    switch (indexPath.row) {
        case 0: {
            cell.iconImage = [UIImage imageNamed:@"SettingLogin"];
            cell.titleText = @"登录/注册";
            break;
        }
        case 1: {
            cell.iconImage = [UIImage imageNamed:@"SettingNightMode"];
            cell.titleText = @"夜间模式";
            UISwitch *nightModeSwitch = [[UISwitch alloc] init];
            [nightModeSwitch addTarget:self action:@selector(nightModeChange) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = nightModeSwitch;
            break;
        }
        case 2: {
            cell.iconImage = [UIImage imageNamed:@"SettingNoImageMode"];
            cell.titleText = @"无图模式";
            UISwitch *nightModeSwitch = [[UISwitch alloc] init];
            [nightModeSwitch addTarget:self action:@selector(noImageModeChange) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = nightModeSwitch;
            break;
        }
        case 3: {
            cell.iconImage = [UIImage imageNamed:@"SettingSuggestions"];
            cell.titleText = @"意见反馈";
            break;
        }
        case 4: {
            cell.iconImage = [UIImage imageNamed:@"SettingLike"];
            cell.titleText = @"给个好评";
            break;
        }
        case 5: {
            cell.iconImage = [UIImage imageNamed:@"SettingAbout"];
            cell.titleText = @"关于我们";
            break;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CLFSettingCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFNavigationController *destinationViewController = [[CLFAppDelegate globalDelegate] centerNavigationController];
    switch (indexPath.row) {
        case 0: {
            [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
            [destinationViewController goToLoginController];
            break;
        }
        case 1: {
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            break;
        }
        case 4: {
            break;
        }
        case 5: {
            [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
            [destinationViewController goToAboutController];
            break;
        }
    }
}

- (void)nightModeChange {
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        [DKNightVersionManager dawnComing];
    } else {
        [DKNightVersionManager nightFalling];
    }
    if ([self.delegate respondsToSelector:@selector(reloadViewData)]) {
        [self.delegate reloadViewData];
    }
    CLFNavigationController *centerController = [[CLFAppDelegate globalDelegate] centerNavigationController];
    [centerController changeNavigationBarMode];
}

- (void)noImageModeChange {
    if ([self.delegate respondsToSelector:@selector(reloadViewData)]) {
        [self.delegate noImageModeChanged];
    }
}

@end
