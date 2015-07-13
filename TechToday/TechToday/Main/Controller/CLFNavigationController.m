//
//  CLFNavigationController.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFNavigationController.h"
#import "CLFArticleDetailController.h"
#import "CLFCommonHeader.h"
#import "CLFAppDelegate.h"
#import "CLFLoginController.h"
#import "CLFAboutController.h"
#import "JVFloatingDrawerViewController.h"
#import "CLFSettingViewController.h"
#import "UIImage+CLF.h"

@interface CLFNavigationController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *viewControllerScreenshots;
@property (strong, nonatomic) UIImageView    *lastViewControllerScreenshot;
@property (strong, nonatomic) UIView         *shadowView;
@property (weak, nonatomic)   UIView         *statusBarView;

@end

@implementation CLFNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    self.view.layer.shadowOpacity = 0.4;
    self.view.layer.shadowOffset = CGSizeMake(-2, 0);
    self.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    [self changeNavigationBarMode];
}

#pragma mark - default navigationBar style

/**
 *  设置默认的NavigationBar样式 如"意见反馈"这个页面的样式
 */
+ (void)initialize {
    [self setupNavigationBarTheme];
    [self setupBarButtonItemTheme];
}

+ (void)setupNavigationBarTheme {
    NSLog(@"setupNavigationBar");
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
    [navigationBar setTitleTextAttributes:textAttrs];
}

+ (void)setupBarButtonItemTheme {
    NSLog(@"setupBarButton");
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [barButtonItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:textAttrs forState:UIControlStateHighlighted];
}

#pragma mark - about statusBar

/**
 *  在启动页把statusBar隐藏掉
 */ 
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        _statusBarView.hidden = YES;
    }
    return self;
}

- (UIView *)statusBarView {
    if (!_statusBarView) {
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
        statusBarView.backgroundColor = CLFUIMainColor;
        statusBarView.nightBackgroundColor = CLFNightBarColor;
        [self.view addSubview:statusBarView];
        _statusBarView = statusBarView;
    }
    return _statusBarView;
}

#pragma mark - add feature : dragging to right and back to homePage

/**
 *  截屏功能
 */
- (void)createScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    [self.viewControllerScreenshots addObject:screenshot];
}

/**
 *  用于存储上一个View的截屏
 */
- (UIImageView *)lastViewControllerScreenshot {
    if (!_lastViewControllerScreenshot) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIImageView *lastViewControllerScreenshot = [[UIImageView alloc] init];
        lastViewControllerScreenshot.frame = window.bounds;
        _lastViewControllerScreenshot = lastViewControllerScreenshot;
    }
    return _lastViewControllerScreenshot;
}

/**
 *  向右拖动页面时显示的阴影
 */
- (UIView *)shadowView {
    if (!_shadowView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *shadowView = [[UIView alloc] init];
        shadowView.backgroundColor = [UIColor blackColor];
        shadowView.frame = window.bounds;
        _shadowView = shadowView;
    }
    return _shadowView;
}

/**
 *  存储 Views 的截屏
 */
- (NSMutableArray *)viewControllerScreenshots {
    if (!_viewControllerScreenshots) {
        _viewControllerScreenshots = [NSMutableArray array];
    }
    return _viewControllerScreenshots;
}

/**
 *  当从 homePage 切换到 articleDetail 页面的时候,截图.
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *previousViewController = [self.viewControllers lastObject];
    if (previousViewController) {
        [self createScreenshot];
    }
    if ([viewController isKindOfClass:[CLFArticleDetailController class]]) {
        self.statusBarView.hidden = NO;
    } else {
//        self.statusBarView.hidden = YES; // 其实可以不用.当备用吧
    }
    [super pushViewController:viewController animated:animated];
}

/**
 *  为详情页增加右拉返回homeViewController的功能.右拉时以截图替代被移出window的view
 */
- (void)dragging:(UIPanGestureRecognizer *)panRecognizer {
    if (1 >= self.viewControllers.count) {
        return;
    }

    CGFloat tx = [panRecognizer translationInView:self.view].x;
    self.shadowView.alpha = 1 - tx / CGRectGetWidth(self.view.frame) * 1.7;
    if (0 > tx) {
        return;
    }
    
    if (UIGestureRecognizerStateEnded == panRecognizer.state
        || UIGestureRecognizerStateCancelled == panRecognizer.state) {
        CGFloat x = self.view.frame.origin.x;

        if (CGRectGetWidth(self.view.frame) * 0.5 <= x) {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.frame), 0);
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                [self.lastViewControllerScreenshot removeFromSuperview];
                [self.shadowView removeFromSuperview];
                self.view.transform = CGAffineTransformIdentity;
                [self.viewControllerScreenshots removeLastObject];
                self.statusBarView.hidden = YES;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformIdentity;
            }];
        }
    } else {
        self.view.transform = CGAffineTransformMakeTranslation(tx, 0);
        self.lastViewControllerScreenshot.image = self.viewControllerScreenshots[self.viewControllerScreenshots.count - 1];
        JVFloatingDrawerViewController *drawViewController = [CLFAppDelegate globalDelegate].drawerViewController;
        // 插入截图的时候,要注意分析drawViewController上面有几层(有多少subView)
        [drawViewController.view insertSubview:self.lastViewControllerScreenshot atIndex:1];
        [drawViewController.view insertSubview:self.shadowView aboveSubview:self.lastViewControllerScreenshot];
    }
}

#pragma mark - others

/**
 *  切换到 about 页面
 */
- (void)goToAboutController {
    CLFAboutController *about = [[CLFAboutController alloc] init];
    CLFNavigationController *nav = [[CLFNavigationController alloc] initWithRootViewController:about];
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 *  根据当前是夜间模式还是普通模式切换navigationBar的样式
 */
- (void)changeNavigationBarMode {
    UINavigationBar *navigationBarOfCurrentView = self.navigationBar;
    UINavigationBar *navigationBarOfAllView = [UINavigationBar appearance];
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        [navigationBarOfCurrentView setBackgroundImage:[UIImage resizeImageWithName:@"NavigationbarNightBackground"] forBarMetrics:UIBarMetricsDefault];
        [navigationBarOfAllView setBackgroundImage:[UIImage resizeImageWithName:@"NavigationbarNightBackground"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [navigationBarOfCurrentView setBackgroundImage:[UIImage resizeImageWithName:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
        [navigationBarOfAllView setBackgroundImage:[UIImage resizeImageWithName:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
    }
}

// TODO : 切换到登录页面
//- (void)goToLoginController {
//    CLFLoginController *login = [[CLFLoginController alloc] init];
//    CLFNavigationController *nav = [[CLFNavigationController alloc] initWithRootViewController:login];
//    [self presentViewController:nav animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

