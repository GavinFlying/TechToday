//
//  CLFLoginController.m
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFLoginController.h"
#import "CLFCommonHeader.h"

@implementation CLFLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nightBackgroundColor = CLFNightViewColor;
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackArrow"] forState:UIControlStateNormal];
    leftButton.nightTitleColor = CLFNightTextColor;
    [leftButton addTarget:self action:@selector(backToHomeView) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 20, 24);
    leftButton.nightBackgroundColor = CLFNightBarColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.frame = CGRectMake(0, 0, 20, 24);
    rightButton.nightBackgroundColor = CLFNightBarColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"登录";
    titleLabel.font = CLFArticleTitleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.nightTextColor = CLFNightTextColor;
    titleLabel.frame = CGRectMake(0, 0, 80, 20);
    self.navigationItem.titleView = titleLabel;
}

- (void)backToHomeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
