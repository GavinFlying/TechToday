//
//  AppDelegate.h
//  TechToday
//
//  Created by CaiGavin on 15/5/14.
//  Copyright (c) 2015年 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class JVFloatingDrawerViewController;
@class JVFloatingDrawerSpringAnimator;
@class CLFNavigationController;

@interface CLFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow                       *window;

@property (strong, nonatomic) JVFloatingDrawerViewController *drawerViewController;
@property (strong, nonatomic) JVFloatingDrawerSpringAnimator *drawerAnimator;
@property (strong, nonatomic) UITableViewController          *leftDrawerViewController;
@property (strong, nonatomic) CLFNavigationController        *centerNavigationController;

// 是否开启无图模式
@property (assign, nonatomic, getter=isNoImageModeOn) BOOL   noImageModeOn;

+ (CLFAppDelegate *)globalDelegate;

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;

@end

