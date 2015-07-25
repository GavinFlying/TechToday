//
//  CLFShareView.m
//  TechToday
//
//  Created by CaiGavin on 7/17/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFShareView.h"
#import <ShareSDK/ShareSDK.h>
#import "CLFCommonHeader.h"

@implementation CLFShareView

static id _publishContent;
static id _shareOptions;
static id _authOptions;

+ (void)shareWithContent:(id)publishContent shareOptions:(id)shareOptions authOptions:(id)authOptions {
    _publishContent = publishContent;
    _shareOptions = shareOptions;
    _authOptions = authOptions;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *shadowView = [[UIView alloc] init];
    CGFloat shadowViewX = 0;
    CGFloat shadowViewY = 0;
    CGFloat shadowViewW = CLFScreenW;
    CGFloat shadowViewH = CLFScreenH;
    shadowView.frame = CGRectMake(shadowViewX, shadowViewY, shadowViewW, shadowViewH);
    shadowView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.7f];
    shadowView.tag = 10;
    
    [window addSubview:shadowView];
    
    UIButton *shadowButton = [[UIButton alloc] init];
    shadowButton.frame = shadowView.bounds;
    shadowButton.backgroundColor = [UIColor clearColor];
    [shadowButton addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:shadowButton];

    UIView *shareView = [[UIView alloc] init];
    CGFloat shareViewW = 300 * CLFScreenWScale;
    CGFloat shareViewH = 180 * CLFScreenWScale;
    CGFloat shareViewX = (CLFScreenW - shareViewW) * 0.5;
    CGFloat shareViewY = (CLFScreenH - shareViewH) * 0.4;
    shareView.frame = CGRectMake(shareViewX, shareViewY, shareViewW, shareViewH);
    shareView.backgroundColor = [UIColor whiteColor];
    shareView.nightBackgroundColor = CLFNightViewColor;
    shareView.tag = 11;
    [window addSubview:shareView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = 0;
    CGFloat titleLabelW = CGRectGetWidth(shareView.frame);
    CGFloat titleLabelH = 45 * CLFScreenWScale;
    titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    titleLabel.text = @"分享到";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = CLFArticleTitleFont;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.nightTextColor = CLFNightTitleColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    [shareView addSubview:titleLabel];
    
    NSArray *shareIcons = nil;
    if ([WXApi isWXAppInstalled]) {
        shareIcons = @[@"share_icon_0.png", @"share_icon_1.png", @"share_icon_2.png"];
    } else {
        shareIcons = @[@"share_icon_0.png", @"", @""];
    }

//    NSArray *shareTitles = @[@"新浪微博", @"微信好友", @"微信朋友圈"];
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat top = 0.0;
        if (i < 3) {
            top = 10 * CLFScreenWScale;
        } else {
            top = 90 * CLFScreenWScale;
        }

        UIButton *button = [[UIButton alloc] init];
        CGFloat buttonW = (shareViewW - 2 * 10 * CLFScreenWScale) / 3.0f;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = 10 * CLFScreenWScale + (i % 3) * buttonW;
        CGFloat buttonY = CGRectGetMaxY(titleLabel.frame) + top;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button setImage:[UIImage imageNamed:shareIcons[i]] forState:UIControlStateNormal];
//        [button setTitle:shareTitles[i] forState:UIControlStateNormal];
//        button.titleLabel.font = [UIFont systemFontOfSize:11 * CLFScreenWScale];
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setNightTitleColor:CLFNightTitleColor];        

        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15 * CLFScreenWScale, 30 * CLFScreenWScale, 15 * CLFScreenWScale)];
//        [button setTitleEdgeInsets:UIEdgeInsetsMake(65 * CLFScreenWScale, -60 * CLFScreenWScale, 5 * CLFScreenWScale, 0)];
        button.tag = 20 + i;
        [button addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:button];
    }
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    CGFloat cancelBtnW = titleLabelW;
    CGFloat cancelBtnH = titleLabelH;
    CGFloat cancelBtnX = titleLabelX;
    CGFloat cancelBtnY = CGRectGetHeight(shareView.frame) - cancelBtnH;
    cancelBtn.frame = CGRectMake(cancelBtnX, cancelBtnY, cancelBtnW, cancelBtnH);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = CLFArticleTitleFont;
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setNightTitleColor:CLFNightTitleColor];
    [cancelBtn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancelBtn];
    
    shareView.transform = CGAffineTransformMakeScale(1 / 300.0f, 1 / 270.0f);
    shadowView.alpha = 0;
    [UIView animateWithDuration:0.2f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1, 1);
        shadowView.alpha = 1;
    } completion:nil];
}

+ (void)shareBtnClicked:(UIButton *)btn {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *shadowView = [window viewWithTag:10];
    UIView *shareView = [window viewWithTag:11];
    
    [shareView removeFromSuperview];
    [shadowView removeFromSuperview];
    
    int shareType = 0;
    id publishContent = _publishContent;
    id shareOptions = _shareOptions;
    id authOptions = _authOptions;
    switch (btn.tag) {
        case 20: {
            shareType = ShareTypeSinaWeibo;
            break;
        }
        case 21: {
            shareType = ShareTypeWeixiSession;
            break;
        }
        case 22: {
            shareType = ShareTypeWeixiTimeline;
            break;
        }
    }
    [ShareSDK showShareViewWithType:shareType container:nil content:publishContent statusBarTips:YES authOptions:authOptions shareOptions:shareOptions result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        if (state == SSResponseStateSuccess) {
            NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
        } else if (state == SSResponseStateFail) {
            NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
        }
    }];
}

@end
