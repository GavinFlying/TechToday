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

@interface CLFAppDelegate () <UIAlertViewDelegate>

@property CLFReachability *internetReachable;

@end

@implementation CLFAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ShareSDK registerApp:@"8b803b4051a6"];
    
    [ShareSDK  connectSinaWeiboWithAppKey:@"2329308416"
                                appSecret:@"f6d10661b4e122963abbea4cc0905a93"
                              redirectUri:@"http://jinri.info"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawerViewController;
    [self configureDrawerViewController];
    [self.window makeKeyAndVisible];
    
    [self appLaunchTimes];
    
    [CLFArticleCacheTool deleteExpiredData];

    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    _internetReachable = [CLFReachability reachabilityForInternetConnection];
    [self reachabilityChanged:(NSNotification *)kReachabilityChangedNotification];
    [_internetReachable startNotifier];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:50 * 1024 * 1024 diskPath:@"WebViewCache"];
    [NSURLCache setSharedURLCache:sharedCache];
    return YES;
}

- (void)reachabilityChanged:(NSNotification *)notice {
    NetworkStatus internetStatus = [[CLFReachability sharedCLFReachability] currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            [MBProgressHUD showError:@"网络连接异常"];
            break;
        }
        case ReachableViaWiFi: {
//            NSLog(@"The internet is working via WIFI");
            break;
        }
        case ReachableViaWWAN: {
//            NSLog(@"The internet is working via WWAN");
            break;
        }
    }
}

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
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"sky"];
}

+ (CLFAppDelegate *)globalDelegate {
    return (CLFAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

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
            NSString *appid = @"725296055";
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

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self appLaunchTimes];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
