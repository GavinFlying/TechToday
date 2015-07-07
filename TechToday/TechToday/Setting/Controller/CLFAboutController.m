//
//  CLFAboutController.m
//  jinri
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import "CLFAboutController.h"
#import "CLFCommonHeader.h"

#import "CLFHomeViewController.h"
#import "CLFAppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "CLFNavigationController.h"

@implementation CLFAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.nightBackgroundColor = CLFNightViewColor;
    [self setupNavigationBar];
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
