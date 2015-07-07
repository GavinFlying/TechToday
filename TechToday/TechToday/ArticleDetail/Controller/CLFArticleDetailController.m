//
//  CLFArticleDetailController.m
//  TechToday
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticleDetailController.h"
#import "CLFCommonHeader.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"
#import "CLFWebView.h"
#import "MBProgressHUD+MJ.h"
#import "CLFAppDelegate.h"
#import "CLFArticleCacheTool.h"

@interface CLFArticleDetailController () <UIWebViewDelegate>

@property (weak, nonatomic) CLFWebView *articleDetail;

@end

@implementation CLFArticleDetailController

- (instancetype)init {
    if (self = [super init]) {
        CLFWebView *articleDetail = [[CLFWebView alloc] init];
        self.articleDetail = articleDetail;
        self.articleDetail.frame = self.view.frame;
        self.articleDetail.backgroundColor = [UIColor clearColor];
        self.articleDetail.nightBackgroundColor = CLFNightViewColor;
        self.articleDetail.opaque = NO;
        self.articleDetail.scalesPageToFit = YES;
        self.articleDetail.delegate = self;
        [self.view addSubview:self.articleDetail];
    }
    return self;
}

- (void)setArticleFrame:(CLFArticleFrame *)articleFrame {
    _articleFrame = articleFrame;
    self.articleDetail.scrollView.hidden = YES;
    [self setupWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self setupToolBarItem];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupWebView {
    self.articleDetail.scrollView.contentInset = UIEdgeInsetsMake(self.articleFrame.noImageViewCellHeight + 20, 0, -self.articleFrame.noImageViewCellHeight - 64, 0);
    self.articleDetail.article = self.articleFrame.article;
    self.articleDetail.titleHeight = self.articleFrame.noImageViewCellHeight;
    
    CLFArticle *article = self.articleFrame.article;
    article.read = YES;
    [CLFArticleCacheTool addArticle:article];
    [self showArticleDetail:article.articleID];
}

- (void)showArticleDetail:(NSString *)str {
    NSString *urlStr = [NSString stringWithFormat:@"http://jinri.info/index.php/DaiAppApi/showArticle/%@", str];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.0f];
    
    if (([CLFAppDelegate globalDelegate].isNoImageModeOn)) {
        NSString *HTMLSource = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//        NSRegularExpression *regexToImage = [NSRegularExpression regularExpressionWithPattern:@"(http|https)://(www.)?[\\w-_.]+.[a-zA-Z]+/((([\\w-_/]+)/)?[\\w-_.]+.(png|gif|jpg))" options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *regexToImage = [NSRegularExpression regularExpressionWithPattern:@"<\\s*img [^\\>]*src\\s*=\\s*([\"|\'])(.*?)[\"|\'][^']*?>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *pureHTMLSource = [regexToImage stringByReplacingMatchesInString:HTMLSource options:NSMatchingReportCompletion range:NSMakeRange(0, HTMLSource.length) withTemplate:@""];
        
        [self.articleDetail loadHTMLString:pureHTMLSource baseURL:nil];
    } else {
        [self.articleDetail loadRequest:request];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:
     @"var tagHead =document.documentElement.firstChild;"
     "var tagStyle = document.createElement(\"style\");"
     "tagStyle.setAttribute(\"type\", \"text/css\");"
     "tagStyle.appendChild(document.createTextNode(\"BODY{padding: 10pt 15pt}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{text-align: justify}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{background-color: transparent}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{font-family:SourceHanSansCN-Light; font-size : 14pt}\"));"
     "var tagHeadAdd = tagHead.appendChild(tagStyle);"];
//         "tagStyle.appendChild(document.createTextNode(\"BODY{font-weight: bold; color: #666666}\"));"
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.articleDetail.scrollView.contentInset = UIEdgeInsetsMake(self.articleFrame.noImageViewCellHeight + 20, 0, CLFArticleDetailButtomViewHeight, 0);
    self.articleDetail.buttomHeight = self.articleDetail.scrollView.contentSize.height;
    self.articleDetail.scrollView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view];
    if (-999 != error.code) {    // error.code = -999 是操作未能完成导致的error.
        [MBProgressHUD showError:@"网络错误" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

- (void)cleanCacheWithRequest:(NSURLRequest *)request {
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie domain] isEqualToString:[request.URL absoluteString]]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupToolBarItem {
    CGFloat toolbarH = CGRectGetHeight(self.navigationController.toolbar.frame);
    
    UIButton *backButton = [[UIButton alloc] init];
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, toolbarH * 0.4, toolbarH * 0.6);
    [backButton addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.contentMode = UIViewContentModeScaleAspectFit;
    nextButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.4);
    [nextButton addTarget:self action:@selector(switchToNextArticle) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    UIButton *commentButton = [[UIButton alloc] init];
    commentButton.contentMode = UIViewContentModeScaleAspectFit;
    commentButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.5);
    [commentButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIButton *shareButton = [[UIButton alloc] init];
    shareButton.contentMode = UIViewContentModeScaleAspectFit;
    shareButton.frame = CGRectMake(0, 0, toolbarH * 0.4, toolbarH * 0.6);
    [shareButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrowNight"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrowNight"] forState:UIControlStateNormal];
        [commentButton setImage:[UIImage imageNamed:@"ToolbarCommentNight"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShareNight"] forState:UIControlStateNormal];
    } else {
        self.navigationController.toolbar.barStyle = UIBarStyleDefault;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrow"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrow"] forState:UIControlStateNormal];
        [commentButton setImage:[UIImage imageNamed:@"ToolbarComment"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShare"] forState:UIControlStateNormal];
    }
    
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[flexItem, backItem, flexItem, nextItem, flexItem, commentItem, flexItem, shareItem, flexItem]];
}

- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchToNextArticle {
    if ([self.delegate respondsToSelector:@selector(articleDetailSwitchToNextArticleFromCurrentArticle)]) {
        [self.delegate articleDetailSwitchToNextArticleFromCurrentArticle];
    }
}

@end
