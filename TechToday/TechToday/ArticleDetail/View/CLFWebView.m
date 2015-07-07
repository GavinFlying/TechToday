//
//  CLFWebView.m
//  jinri
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import "CLFWebView.h"
#import "CLFCommonHeader.h"
#import "NSString+CLF.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"

@interface CLFWebView ()

@property (weak, nonatomic) UIView    *titleView;
@property (weak, nonatomic) UILabel   *titleLabel;
@property (weak, nonatomic) UILabel   *sourceLabel;
@property (weak, nonatomic) UILabel   *dateLabel;
@property (weak, nonatomic) UILabel   *pageViewsLabel;

@property (weak, nonatomic) UIView    *buttomView;
@property (weak, nonatomic) UIButton  *sourceSiteButton;

@property (weak, nonatomic) UIView    *separatorView;

@property (assign, nonatomic) u_int32_t	titleStyle;

@end

@implementation CLFWebView

- (instancetype)init {
    if (self = [super init]) {
        self.scrollView.bounces = NO;
    }
    return self;
}


- (void)setTitleHeight:(CGFloat)titleHeight {
    _titleHeight = titleHeight;
    self.titleStyle = arc4random() % 2;
    [self.titleView removeFromSuperview];
    [self setupTitleViewSubviewsData];
    [self setupTitleViewSubviewsFrame];
    self.separatorView.hidden = self.titleStyle;
}

- (void)setButtomHeight:(CGFloat)buttomHeight {
    _buttomHeight = buttomHeight;
    [self.buttomView removeFromSuperview];
    [self setupButtomViewSubviewsData];
    [self setupButtomViewSubviewsFrame:buttomHeight];
}

- (void)setupTitleViewSubviewsData {
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = self.titleStyle ? CLFUIMainColor : [UIColor whiteColor];
    titleView.nightBackgroundColor = self.titleStyle ? CLFNightBarColor : CLFNightViewColor;
    
    [self.scrollView addSubview:titleView];
    self.titleView = titleView;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor blackColor];
    titleLabel.nightTextColor = CLFNightTextColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = CLFArticleTitleFont;
    titleLabel.numberOfLines = 0;
    NSString *titleText = self.article.title;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleText];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleText.length)];
    titleLabel.attributedText = attrString;
    [titleView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *sourceLabel = [[UILabel alloc] init];
    sourceLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor lightGrayColor];
    sourceLabel.nightTextColor = CLFNightTextColor;
    sourceLabel.backgroundColor = [UIColor clearColor];
    sourceLabel.font = CLFArticleOtherFont;
    sourceLabel.text = self.article.source;
    [titleView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor lightGrayColor];
    dateLabel.nightTextColor = CLFNightTextColor;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.font = CLFArticleOtherFont;
    dateLabel.text = self.article.date;
    [titleView addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    UILabel *pageViewsLabel = [[UILabel alloc] init];
    pageViewsLabel.textAlignment = NSTextAlignmentRight;
    pageViewsLabel.textColor = self.titleStyle ? [UIColor whiteColor] : [UIColor lightGrayColor];
    pageViewsLabel.nightTextColor = CLFNightTextColor;
    pageViewsLabel.backgroundColor = [UIColor clearColor];
    pageViewsLabel.font = CLFArticleOtherFont;
    pageViewsLabel.text = self.article.pageViews;
    [titleView addSubview:pageViewsLabel];
    self.pageViewsLabel = pageViewsLabel;
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = CLFUIMainColor;
    separatorView.nightBackgroundColor = CLFNightBarColor;
    [self.titleView addSubview:separatorView];
    self.separatorView = separatorView;
}

- (void)setupTitleViewSubviewsFrame {
    CGFloat titleViewW = CGRectGetWidth(self.scrollView.frame);
    CGFloat titleViewContentW = titleViewW - 2 * (CLFArticleCellInnerBorder + CLFArticleCellToBorderMargin);
    
    self.titleView.frame = CGRectMake(0, -self.titleHeight, titleViewW, self.titleHeight);
    
    CGSize titleLabelSize = [NSString sizeOfText:self.article.title maxSize:CGSizeMake(titleViewContentW, MAXFLOAT) font:CLFArticleTitleFont];
    CGFloat titleLabelX = CLFArticleCellToBorderMargin + CLFArticleCellInnerBorder;
    CGFloat titleLabelY = CLFArticleCellInnerBorder;
    self.titleLabel.frame = (CGRect){{titleLabelX, titleLabelY}, titleLabelSize};
    
    // sourceLabelFrame
    CGFloat sourceLabelX = titleLabelX;
    CGFloat sourceLabelY = CGRectGetMaxY(self.titleLabel.frame) + CLFArticleCellInnerBorder;
    CGSize sourceLabelSize = [NSString sizeOfText:self.sourceLabel.text maxSize:CGSizeMake(0.2 * titleViewContentW, 20) font:CLFArticleOtherFont];
    self.sourceLabel.frame = (CGRect){{sourceLabelX, sourceLabelY}, sourceLabelSize};
    
    // dateLabelFrame
    CGFloat dateLabelX = CGRectGetMaxX(self.sourceLabel.frame) + CLFArticleCellInnerBorder;
    CGFloat dateLabelY = sourceLabelY;
    CGSize dateLabelSize = [NSString sizeOfText:self.dateLabel.text maxSize:CGSizeMake(0.2 * titleViewContentW, 20) font:CLFArticleOtherFont];
    self.dateLabel.frame = (CGRect){{dateLabelX, dateLabelY}, dateLabelSize};
    
    CGSize pageViewsLabelSize = [NSString sizeOfText:self.pageViewsLabel.text maxSize:CGSizeMake(0.45 * titleViewContentW, 20) font:CLFArticleOtherFont];
    CGFloat pageViewsLabelX = titleViewW - pageViewsLabelSize.width - CLFArticleCellBorder;
    CGFloat pageViewsLabelY = dateLabelY;
    self.pageViewsLabel.frame = (CGRect){{pageViewsLabelX, pageViewsLabelY}, pageViewsLabelSize};
    
    CGFloat separatorViewX = titleLabelX;
    CGFloat separatorViewY = CGRectGetMaxY(self.pageViewsLabel.frame) + CLFArticleCellInnerBorder;
    CGFloat separatorViewW = titleViewContentW;
    CGFloat separatorViewH = 4;
    
    self.separatorView.frame = CGRectMake(separatorViewX, separatorViewY, separatorViewW, separatorViewH);
}


- (void)setupButtomViewSubviewsData {
    
    UIView *buttomView = [[UIView alloc] init];
    buttomView.backgroundColor = [UIColor whiteColor];
    buttomView.nightBackgroundColor = CLFNightViewColor;
    [self.scrollView addSubview:buttomView];
    self.buttomView = buttomView;

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
    self.sourceSiteButton = sourceSiteButton;

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
