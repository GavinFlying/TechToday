//
//  CLFAboutController.m
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFAboutController.h"
#import "CLFCommonHeader.h"
#import "CLFHomeViewController.h"
#import "CLFAppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "CLFNavigationController.h"
#import "NSString+CLF.h"

@interface CLFAboutController ()

@property (weak, nonatomic) UIView *appIconView;
@property (weak, nonatomic) UIView *appIntroView;

@end

@implementation CLFAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nightBackgroundColor = CLFNightViewColor;
    [self setupNavigationBar];
    [self setupAppIconView];
    [self setupAppIntroView];
}

- (UIView *)appIconView {
    if (!_appIconView) {
        UIView *appIconView = [[UIView alloc] init];
        
        CGFloat appIconViewX = 0;
        CGFloat appIconViewY = 0;
        CGFloat appIconViewW = CGRectGetWidth(self.view.frame);
        CGFloat appIconViewH = 138;
        appIconView.frame = CGRectMake(appIconViewX, appIconViewY, appIconViewW, appIconViewH);
        [self.view addSubview:appIconView];
        
        _appIconView = appIconView;
    }
    return _appIconView;
}

- (void)setupAppIconView {
    self.appIconView.backgroundColor = [UIColor blueColor];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    CGFloat iconViewX = 30;
    CGFloat iconViewY = 15;
    CGFloat iconViewW = 108;
    CGFloat iconViewH = 108;
    iconView.frame = CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH);
    iconView.image = [UIImage imageNamed:@"TechToday"];
    [self.appIconView addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"TechToday";
    titleLabel.font = CLFArticleTitleFont;
    titleLabel.textColor = [UIColor blackColor];
    
    CGSize titleSize = [NSString sizeOfText:titleLabel.text maxSize:CGSizeMake(200, MAXFLOAT) font:CLFArticleTitleFont];
    CGFloat titleX = CGRectGetMaxX(iconView.frame) + 15;
    CGFloat titleY = iconView.frame.origin.y + 5;
    titleLabel.frame = (CGRect){{titleX, titleY}, titleSize};
    [self.appIconView addSubview:titleLabel];
    
    UILabel *slogan1Label = [[UILabel alloc] init];
    slogan1Label.text = @"聚焦今日";
    slogan1Label.font = CLFArticleTitleFont;
    slogan1Label.textColor = [UIColor blackColor];
    
    CGSize slogan1Size = [NSString sizeOfText:titleLabel.text maxSize:CGSizeMake(200, MAXFLOAT) font:CLFArticleTitleFont];
    CGFloat slogan1X = CGRectGetMaxX(iconView.frame) + 15;
    CGFloat slogan1Y = CGRectGetMaxY(titleLabel.frame) + 5;
    slogan1Label.frame = (CGRect){{slogan1X, slogan1Y}, slogan1Size};
    [self.appIconView addSubview:slogan1Label];
    
    UILabel *slogan2Label = [[UILabel alloc] init];
    slogan2Label.text = @"拒绝昨日";
    slogan2Label.font = CLFArticleTitleFont;
    slogan2Label.textColor = [UIColor blackColor];
    
    CGSize slogan2Size = [NSString sizeOfText:titleLabel.text maxSize:CGSizeMake(200, MAXFLOAT) font:CLFArticleTitleFont];
    CGFloat slogan2X = CGRectGetMaxX(iconView.frame) + 15;
    CGFloat slogan2Y = CGRectGetMaxY(slogan1Label.frame) + 5;
    slogan2Label.frame = (CGRect){{slogan2X, slogan2Y}, slogan2Size};
    [self.appIconView addSubview:slogan2Label];
}

- (UIView *)appIntroView {
    if (!_appIntroView) {
        UITextField *appIntroView = [[UITextField alloc] init];
        
        CGFloat appIntroViewX = 0;
        CGFloat appIntroViewY = CGRectGetMaxY(self.appIconView.frame);
        CGFloat appIntroViewW = CGRectGetWidth(self.view.frame);
        CGFloat appIntroViewH = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.appIconView.frame);
        appIntroView.frame = CGRectMake(appIntroViewX, appIntroViewY, appIntroViewW, appIntroViewH);
        [self.view addSubview:appIntroView];
        
        _appIntroView = appIntroView;
    }
    return _appIntroView;
}

- (void)setupAppIntroView {
    self.appIntroView.backgroundColor = [UIColor whiteColor];
    
//    UITextField *appIntro = [[UITextField alloc] init];
//    appIntro.frame = self.appIntroView.bounds;
//    appIntro.text =
//    appIntro.font = CLFArticleDetailSourceFont;
//    appIntro.textColor = [UIColor blackColor];
//    [self.appIntroView addSubview:appIntro];
    
    UILabel *introLabel = [[UILabel alloc] init];
    
    NSString *titleText = @"TechToday是jinri.info的一款iOS客户端.TechToday是jinri.info的一款iOS客户端.TechToday是jinri.info的一款iOS客户端.TechToday是jinri.info的一款iOS客户端.TechToday是jinri.info的一款iOS客户端";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleText];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleText.length)];
    introLabel.attributedText = attrString;
    introLabel.frame = self.appIntroView.bounds;
    introLabel.numberOfLines = 0;
    introLabel.font = CLFArticleDetailSourceFont;
    introLabel.textColor = [UIColor blackColor];
    
    [self.appIntroView addSubview:introLabel];
}

- (void)setupNavigationBar {
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"NavigationbarBackArrow"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backToHomeView) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 20, 24);
    leftButton.nightBackgroundColor = CLFNightBarColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.frame = CGRectMake(0, 0, 20, 24);
    rightButton.nightBackgroundColor = CLFNightBarColor;
    [rightButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"关于我们";
    titleLabel.nightTextColor = CLFNightTextColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = CLFArticleTitleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.frame = CGRectMake(0, 0, 80, 20);
    self.navigationItem.titleView = titleLabel;
}

- (void)backToHomeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
