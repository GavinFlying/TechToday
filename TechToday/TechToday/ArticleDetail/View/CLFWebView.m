//
//  CLFWebView.m
//  TechToday
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFWebView.h"
#import "CLFCommonHeader.h"
#import "NSString+CLF.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"

@interface CLFWebView ()

// titleView : show title
@property (weak, nonatomic)   UIView    *titleView;
@property (weak, nonatomic)   UILabel   *titleLabel;
@property (weak, nonatomic)   UILabel   *sourceLabel;
@property (weak, nonatomic)   UIView    *separatorView;

// buttomView : show "显示原文"
@property (weak, nonatomic)   UIView    *buttomView;
@property (weak, nonatomic)   UIButton  *sourceSiteButton;

// titleView的样式
@property (assign, nonatomic) u_int32_t	titleStyle;

@end

@implementation CLFWebView

- (instancetype)init {
    if (self = [super init]) {
        self.scrollView.bounces = NO;
    }
    return self;
}

/**
 *  每次传入一个新的 titleHeight 及 buttomHeight 时代表以及切换到新的文章,重置 titleView 及 buttomView
 */
- (void)setTitleHeight:(CGFloat)titleHeight {
    _titleHeight = titleHeight;
    self.titleStyle = arc4random() % 2;
    [self setupTitleViewSubviewsFrame];
    self.separatorView.hidden = self.titleStyle;
}

- (void)setButtomHeight:(CGFloat)buttomHeight {
    _buttomHeight = buttomHeight;
    [self setupButtomViewSubviewsFrame:buttomHeight];
}

#pragma mark - about titleView

- (UIView *)titleView {
    if (!_titleView) {
        UIView *titleView = [[UIView alloc] init];
        [self.scrollView addSubview:titleView];
        _titleView = titleView;
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = CLFArticleTitleFont;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.nightBackgroundColor = [UIColor clearColor];
        [self.titleView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)sourceLabel {
    if (!_sourceLabel) {
        UILabel *sourceLabel = [[UILabel alloc] init];
        sourceLabel.font = CLFArticleDetailSourceFont;
        sourceLabel.backgroundColor = [UIColor clearColor];
        sourceLabel.nightBackgroundColor = [UIColor clearColor];
        [self.titleView addSubview:sourceLabel];
        _sourceLabel = sourceLabel;
    }
    return _sourceLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        UIView *separatorView = [[UIView alloc] init];
        separatorView.backgroundColor = CLFUIMainColor;
        separatorView.nightBackgroundColor = CLFNightBarColor;
        [self.titleView addSubview:separatorView];
        _separatorView = separatorView;
    }
    return _separatorView;
}

- (void)setupTitleViewSubviewsFrame {
    // titleView
    CGFloat titleViewW = CGRectGetWidth(self.scrollView.frame);
    CGFloat titleViewContentW = titleViewW - 2 * (CLFArticleCellInnerBorder + CLFArticleCellToBorderMargin);
    
    self.titleView.frame = CGRectMake(0, -self.titleHeight, titleViewW, self.titleHeight);
    self.titleView.backgroundColor = self.titleStyle ? CLFUIMainColor : [UIColor whiteColor];
    self.titleView.nightBackgroundColor = self.titleStyle ? CLFNightBarColor : CLFNightViewColor;
    
    // titleLabel
    self.titleLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor blackColor];
    self.titleLabel.nightTextColor = CLFNightTextColor;

    self.titleLabel.attributedText = [NSString NSAttributedStringFromNSString:self.article.title];
    
    CGSize titleLabelSize = [NSString sizeOfText:self.article.title maxSize:CGSizeMake(titleViewContentW, MAXFLOAT) font:CLFArticleTitleFont];
    CGFloat titleLabelX = CLFArticleCellToBorderMargin + CLFArticleCellInnerBorder;
    CGFloat titleLabelY = CLFArticleCellInnerBorder;
    self.titleLabel.frame = (CGRect){{titleLabelX, titleLabelY}, titleLabelSize};
    
    // sourceLabel
    self.sourceLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor lightGrayColor];
    self.sourceLabel.nightTextColor = CLFNightTextColor;
    self.sourceLabel.text = self.article.source;
    
    CGFloat sourceLabelX = titleLabelX;
    CGFloat sourceLabelY = CGRectGetMaxY(self.titleLabel.frame) + CLFArticleCellInnerBorder;
    CGSize sourceLabelSize = [NSString sizeOfText:self.sourceLabel.text maxSize:CGSizeMake(titleViewContentW, 30) font:CLFArticleDetailSourceFont];
    self.sourceLabel.frame = (CGRect){{sourceLabelX, sourceLabelY}, sourceLabelSize};
    
    // separatorView
    CGFloat separatorViewX = titleLabelX;
    CGFloat separatorViewY = CGRectGetMaxY(self.sourceLabel.frame) + CLFArticleCellInnerBorder;
    CGFloat separatorViewW = titleViewContentW;
    CGFloat separatorViewH = 4;
    
    self.separatorView.frame = CGRectMake(separatorViewX, separatorViewY, separatorViewW, separatorViewH);
}

#pragma mark - about buttomView

- (UIView *)buttomView {
    if (!_buttomView) {
        UIView *buttomView = [[UIView alloc] init];
        buttomView.backgroundColor = [UIColor whiteColor];
        buttomView.nightBackgroundColor = CLFNightViewColor;
        [self.scrollView addSubview:buttomView];
        _buttomView = buttomView;
    }
    return _buttomView;
}

- (UIButton *)sourceSiteButton {
    if (!_sourceSiteButton) {
        UIButton *sourceSiteButton = [[UIButton alloc] init];
        sourceSiteButton.backgroundColor = [UIColor whiteColor];
        sourceSiteButton.nightBackgroundColor = CLFNightViewColor;
        [sourceSiteButton addTarget:self action:@selector(jumpToSourceSite) forControlEvents:UIControlEventTouchUpInside];
        [sourceSiteButton setTitle:@"查看原文" forState:UIControlStateNormal];
        [sourceSiteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        sourceSiteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        CALayer *sourceSiteButtonLayer = [sourceSiteButton layer];
        [sourceSiteButtonLayer setMasksToBounds:YES];
        [sourceSiteButtonLayer setCornerRadius:5.0];
        [sourceSiteButtonLayer setBorderWidth:1.0];
        [sourceSiteButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
        
        [self.buttomView addSubview:sourceSiteButton];
        _sourceSiteButton = sourceSiteButton;
    }
    return _sourceSiteButton;
}

- (void)setupButtomViewSubviewsFrame:(CGFloat)buttomHeight {
    self.buttomView.frame = CGRectMake(0, buttomHeight, CGRectGetWidth(self.scrollView.frame), CLFArticleDetailButtomViewHeight);
    
    CGFloat sourceSiteButtonW = 70;
    CGFloat sourceSiteButtonH = 25;
    CGFloat sourceSiteButtonX = (CGRectGetWidth(self.buttomView.frame) - sourceSiteButtonW) * 0.5;
    CGFloat sourceSiteButtonY = 10;
    self.sourceSiteButton.frame = CGRectMake(sourceSiteButtonX, sourceSiteButtonY, sourceSiteButtonW, sourceSiteButtonH);
}

- (void)jumpToSourceSite {
    if (self.article.url) {
        NSURL *url = [[NSURL alloc] initWithString:self.article.url];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
