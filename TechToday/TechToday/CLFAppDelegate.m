//
//  AppDelegate.m
//  TechToday
//
//  Created by CaiGavin on 15/5/14.
//  Copyright (c) 2015年 CaiGavin. All rights reserved.
//

#import "CLFAppDelegate.h"
#import "CLFHomeViewController.h"
#import "CLFNavigationController.h"
#import "MBProgressHUD+MJ.h"
#import "CLFReachability.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "CLFSettingViewController.h"
#import "CLFArticleCacheTool.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "RNCachingURLProtocol.h"

@interface CLFAppDelegate () <UIAlertViewDelegate>

@property CLFReachability *internetReachable;

@end

@implementation CLFAppDelegate

+ (CLFAppDelegate *)globalDelegate {
    return (CLFAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置 shareSDK 分享模块
    [ShareSDK registerApp:@"8b803b4051a6"];
    
    [ShareSDK  connectSinaWeiboWithAppKey:@"2329308416"
                                appSecret:@"f6d10661b4e122963abbea4cc0905a93"
                              redirectUri:@"http://jinri.info"];
    
    //添加微信应用  http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx7528d998fb4c375b"
                           appSecret:@"67ed6149eacbb2dec1b35574bb5a180b"
                           wechatCls:[WXApi class]];

    // 设置 drawerViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawerViewController;
    [self configureDrawerViewController];
    [self.window makeKeyAndVisible];
    
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    
    // 统计应用打开次数
    [self appLaunchTimes];
    
    // 删除过期数据 --> 契合 TechToday
    [CLFArticleCacheTool deleteExpiredData];
    
    
    // 检查网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _internetReachable = [CLFReachability reachabilityForInternetConnection];
    [self reachabilityChanged:(NSNotification *)kReachabilityChangedNotification];
    [_internetReachable startNotifier];
    
    // 分配缓存
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:50 * 1024 * 1024 diskPath:@"WebViewCache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    application.statusBarStyle = UIStatusBarStyleLightContent;
    return YES;
}

#pragma mark - about network reachability

/**
 *  当网络连接中断时提醒用户
 */
- (void)reachabilityChanged:(NSNotification *)notice {
    NetworkStatus internetStatus = [[CLFReachability sharedCLFReachability] currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            [MBProgressHUD showError:@"网络连接异常" toView:self.drawerViewController.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.drawerViewController.view];
            });
            break;
        }
        case ReachableViaWiFi: {
//            [MBProgressHUD showMessage:@"正通过WiFi访问网络" toView:self.drawerViewController.view];
            break;
        }
        case ReachableViaWWAN: {
//            [MBProgressHUD showMessage:@"正通过移动数据流量访问网络" toView:self.drawerViewController.view];
            break;
        }
    }
//    [MBProgressHUD hideHUDForView:self.drawerViewController.view];
}

#pragma mark - setup drawerViewController

- (JVFloatingDrawerViewController *)drawerViewController {
    if (!_drawerViewController) {
        _drawerViewController = [[JVFloatingDrawerViewController alloc] init];
    }
    return _drawerViewController;
}

- (UITableViewController *)leftDrawerViewController {
    if (!_leftDrawerViewController) {
        _leftDrawerViewController = [[CLFSettingViewController alloc] init];
    }
    return _leftDrawerViewController;
}

- (CLFNavigationController *)centerNavigationController {
    if (!_centerNavigationController) {
        CLFHomeViewController *home = [[CLFHomeViewController alloc] init];
        _centerNavigationController = [[CLFNavigationController alloc] initWithRootViewController:home];
    }
    return _centerNavigationController;
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    if (!_drawerAnimator) {
        _drawerAnimator = [[JVFloatingDrawerSpringAnimator alloc] init];
    }
    return _drawerAnimator;
}

- (void)configureDrawerViewController {
    self.drawerViewController.leftViewController = self.leftDrawerViewController;
    self.drawerViewController.centerViewController = self.centerNavigationController;
    self.drawerViewController.animator = self.drawerAnimator;
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"Sky"];
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

#pragma mark - lauch times && ask for rating
/**
 *  若用户累计启动程序达到30次,则弹窗请求用户前往 App Store 评分
 */
- (void)appLaunchTimes {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger launchTime = [defaults integerForKey:@"launchTime"];
    
    if (launchTime) {
        launchTime ++;
    } else {
        launchTime = 1;
    }
    
    if (30 == launchTime) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"喜欢TechToday吗?"
                                                        message:@"亲~赏个好评吧~O(∩_∩)O~~"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"准了!", nil];
        [alert show];
        launchTime = 0;
    }
    [defaults setInteger:launchTime forKey:@"launchTime"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            break;
        }
        case 1: {
            NSString *appid = @"1021176188";
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8", appid];
            NSURL *url = [NSURL URLWithString:str];
            [[UIApplication sharedApplication] openURL:url];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger launchTime = [defaults integerForKey:@"launchTime"];
            launchTime = -666666;
            [defaults setInteger:launchTime forKey:@"launchTime"];
            break;
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self appLaunchTimes];
}

#pragma mark - others

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

@end
