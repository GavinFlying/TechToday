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
#import "MBProgressHUD+MJ.h"
#import "CLFCacheClearTool.h"

@interface CLFSettingViewController () <UIAlertViewDelegate>

@end

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
//        case 0: {
////            cell.iconImage = [UIImage imageNamed:@"SettingLogin"];
////            cell.titleText = @"登录/注册";
//            break;
//        }
        case 0: {
            cell.iconImage = [UIImage imageNamed:@"SettingNightMode"];
            cell.titleText = @"夜间模式";
            UISwitch *nightModeSwitch = [[UISwitch alloc] init];
            [nightModeSwitch addTarget:self action:@selector(nightModeChange) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = nightModeSwitch;
            break;
        }
        case 1: {
            cell.iconImage = [UIImage imageNamed:@"SettingNoImageMode"];
            cell.titleText = @"无图模式";
            UISwitch *nightModeSwitch = [[UISwitch alloc] init];
            [nightModeSwitch addTarget:self action:@selector(noImageModeChange) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = nightModeSwitch;
            break;
        }
        case 2: {
            cell.iconImage = [UIImage imageNamed:@"SettingLogin"];
            cell.titleText = @"清理缓存";
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
//            [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
//            [destinationViewController goToLoginController];
            break;
        }
        case 1: {
            break;
        }
        case 2: {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDir = [paths objectAtIndex:0];
            CGFloat cacheSize = [CLFCacheClearTool DirectorySizeAtPath:cachesDir];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"缓存清理"
                                                            message:[NSString stringWithFormat:@"目前共有 %.2fM 缓存,确定要清理吗?", cacheSize]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
            
            break;
        }
        case 3: {
//            [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
//            [destinationViewController goToAboutController];
            [self sendSuggestionsEmail];
            break;
        }
        case 4: {
//            NSString *str = [NSString stringWithFormat:
//                             @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
//                             myAppID ];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
            NSString *str = @"itms://itunes.com/apps/wechat";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            break;
        }
        case 5: {
            [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
            [destinationViewController goToAboutController];
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
//
- (void)sendSuggestionsEmail {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            [self displayComposerSheet];
        } else {
            [self launchMailAppOnDevice];
        }
    } else {
        [self launchMailAppOnDevice];
    }
}

- (void)displayComposerSheet {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.navigationBar.tintColor = [UIColor whiteColor];
    
    
    mailPicker.mailComposeDelegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mailPicker setSubject:@"TechToday意见反馈"];
        
        NSArray *toRecipients = [NSArray arrayWithObject:@"gavinflying@126.com"];
        [mailPicker setToRecipients:toRecipients];
        
        NSString *emailBody =@"请留下您的宝贵建议和意见：\n\n\n";
        [mailPicker setMessageBody:emailBody isHTML:NO];

        [self presentViewController:mailPicker animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    });
}

- (void)launchMailAppOnDevice {
    NSString *recipients = @"mailto:gavinflying@126.com&subject=意见反馈";
    NSString *body = @"&body=请留下您的宝贵建议和意见：\n\n\n";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled: {
            [MBProgressHUD showError:@"邮件发送取消"];
            break;
        }
        case MFMailComposeResultSaved: {
            [MBProgressHUD showSuccess:@"邮件保存成功"];
            break;
        }
        case MFMailComposeResultSent: {
            [MBProgressHUD showSuccess:@"邮件发送成功"];
            break;
        }
        case MFMailComposeResultFailed: {
            [MBProgressHUD showError:@"邮件发送失败"];
            break;
        }
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
//                                                    message:@""
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            break;
        }
        case 1: {
//            [MBProgressHUD showMessage:@"清除中"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDir = [paths objectAtIndex:0];
            [CLFCacheClearTool clearCacheAtPath:cachesDir completion:nil];
            break;
        }
    }
}



@end
