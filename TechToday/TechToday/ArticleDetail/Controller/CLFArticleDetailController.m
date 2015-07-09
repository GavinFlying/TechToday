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

@interface CLFArticleDetailController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) CLFWebView *articleDetail;
@property (weak, nonatomic) UITableView *moreOptionList;
@property (weak, nonatomic) UITableView *fontList;
@property (assign, nonatomic) NSInteger fontSize;

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
        self.articleDetail.scrollView.delegate = self;
        [self.view addSubview:self.articleDetail];
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTapRecognizer.delegate = self;
        [self.articleDetail addGestureRecognizer:singleTapRecognizer];
#warning 要用存档的数据替换
        self.fontSize = 13;
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapRecognizer {
    if (!self.fontList.hidden) {
        self.fontList.hidden = YES;
    }
    if (!self.moreOptionList.hidden) {
        self.moreOptionList.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.fontList.hidden) {
        self.fontList.hidden = YES;
    }
    if (!self.moreOptionList.hidden) {
        self.moreOptionList.hidden = YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UITableView *)moreOptionList {
    if (!_moreOptionList) {
        UITableView *moreOptionList = [[UITableView alloc] init];
        [self.view addSubview:moreOptionList];
        
        moreOptionList.backgroundColor = [UIColor whiteColor];
        moreOptionList.nightBackgroundColor = CLFNightViewColor;
        
        moreOptionList.separatorStyle = UITableViewCellSeparatorStyleNone;

        CGFloat moreOptionW = CLFScreenW * 0.30;
        CGFloat moreOptionH = CLFScreenH * 0.10;
        CGFloat moreOptionX = CLFScreenW - moreOptionW - 5;
        CGFloat moreOptionY = CLFScreenH - moreOptionH - CGRectGetHeight(self.navigationController.toolbar.frame) - 5;
        moreOptionList.frame = CGRectMake(moreOptionX, moreOptionY, moreOptionW, moreOptionH);
        
        moreOptionList.layer.shadowColor = [[UIColor blackColor] CGColor];
        moreOptionList.layer.shadowOffset = CGSizeMake(1, 2);
        moreOptionList.layer.shadowOpacity = 0.6;
        moreOptionList.clipsToBounds = NO;
        
        moreOptionList.hidden = YES;
        moreOptionList.delegate = self;
        moreOptionList.dataSource = self;
        moreOptionList.tag = 1;
        
        _moreOptionList = moreOptionList;
    }
    return _moreOptionList;
}

- (UITableView *)fontList {
    if (!_fontList) {
        UITableView *fontList = [[UITableView alloc] init];
        [self.view addSubview:fontList];
        
        fontList.backgroundColor = [UIColor whiteColor];
        fontList.nightBackgroundColor= CLFNightViewColor;
        
        fontList.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        CGFloat fontListW = CLFScreenW * 0.60;
        CGFloat fontListH = CLFScreenH * 0.30;
        CGFloat fontListX = (CLFScreenW - fontListW) * 0.5;
        CGFloat fontListY = (CLFScreenH - fontListH - CGRectGetHeight(self.navigationController.toolbar.frame)) * 0.5;
        fontList.frame = CGRectMake(fontListX, fontListY, fontListW, fontListH);
        
        fontList.layer.shadowColor = [[UIColor blackColor] CGColor];
        fontList.layer.shadowOffset = CGSizeMake(1, 2);
        fontList.layer.shadowOpacity = 0.6;
        fontList.clipsToBounds = NO;
        
        fontList.hidden = YES;
        fontList.delegate = self;
        fontList.dataSource = self;
        fontList.tag = 2;
        
        _fontList = fontList;
    }
    return _fontList;
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
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
     @"var tagHead =document.documentElement.firstChild;"
     "var tagStyle = document.createElement(\"style\");"
     "tagStyle.setAttribute(\"type\", \"text/css\");"
     "tagStyle.appendChild(document.createTextNode(\"BODY{padding: 10pt 15pt}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{text-align: justify}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{background-color: transparent}\"));"
     "tagStyle.appendChild(document.createTextNode(\"BODY{font-family:SourceHanSansCN-Light; font-size : %ldpt}\"));"
//     "tagStyle.appendChild(document.createTextNode(\"BODY{font-size : 14pt}\"));"
     "var tagHeadAdd = tagHead.appendChild(tagStyle);", (long)self.fontSize]];
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
    
//    UIButton *commentButton = [[UIButton alloc] init];
//    commentButton.contentMode = UIViewContentModeScaleAspectFit;
//    commentButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.5);
//    [commentButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    UIButton *shareButton = [[UIButton alloc] init];
    shareButton.contentMode = UIViewContentModeScaleAspectFit;
    shareButton.frame = CGRectMake(0, 0, toolbarH * 0.4, toolbarH * 0.6);
    [shareButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    UIButton *moreButton = [[UIButton alloc] init];
    moreButton.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.5);
    [moreButton addTarget:self action:@selector(showMoreOptions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrowNight"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrowNight"] forState:UIControlStateNormal];
//        [commentButton setImage:[UIImage imageNamed:@"ToolbarCommentNight"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShareNight"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"ToolbarCommentNight"] forState:UIControlStateNormal];
    } else {
        self.navigationController.toolbar.barStyle = UIBarStyleDefault;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrow"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrow"] forState:UIControlStateNormal];
//        [commentButton setImage:[UIImage imageNamed:@"ToolbarComment"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShare"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"ToolbarComment"] forState:UIControlStateNormal];
    }
    
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [self setToolbarItems:@[flexItem, backItem, flexItem, nextItem, flexItem, commentItem, flexItem, shareItem, flexItem]];
    [self setToolbarItems:@[flexItem, backItem, flexItem, nextItem, flexItem, shareItem, flexItem, moreItem, flexItem]];
}

- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchToNextArticle {
    if ([self.delegate respondsToSelector:@selector(articleDetailSwitchToNextArticleFromCurrentArticle)]) {
        [self.delegate articleDetailSwitchToNextArticleFromCurrentArticle];
    }
}

- (void)showMoreOptions {
    self.moreOptionList.hidden = !self.moreOptionList.hidden;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (1 == tableView.tag) {
        return CLFMoreOptionListNumberOfSections;
    }
    return CLFFontListNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (1 == tableView.tag) {
        return CLFMoreOptionListNumberOfRowsInSection;
    }
    return CLFFontListNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (1 == tableView.tag) {
        static NSString *ID = @"moreOptions";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"字号调整";
                break;
            }
            case 1: {
                cell.textLabel.text = @"回到顶部";
                break;
            }
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.nightTextColor = CLFNightTextColor;
        return cell;
    } else {
        static NSString *ID = @"font";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"最小";
                break;
            }
            case 1: {
                cell.textLabel.text = @"略小";
                break;
            }
            case 2: {
                cell.textLabel.text = @"一般";
                break;
            }
            case 3: {
                cell.textLabel.text = @"略大";
                break;
            }
            case 4: {
                cell.textLabel.text = @"最大";
                break;
            }
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.nightTextColor = CLFNightTextColor;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (1 == tableView.tag) {
        return CGRectGetHeight(self.moreOptionList.frame) / CLFMoreOptionListNumberOfRowsInSection;
    }
    return CGRectGetHeight(self.fontList.frame) / CLFFontListNumberOfRowsInSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (1 == tableView.tag) {
        switch (indexPath.row) {
            case 0: {
                [self showFontList];
                break;
            }
            case 1: {
                [self scrollToTop];
                break;
            }
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                self.fontSize = 11;
                break;
            }
            case 1: {
                self.fontSize = 12;
                break;
            }
            case 2: {
                self.fontSize = 13;
                break;
            }
            case 3: {
                self.fontSize = 14;
                break;
            }
            case 4: {
                self.fontSize = 15;
                break;
            }
        }
        self.articleFrame = self.articleFrame;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    tableView.hidden = YES;
}

- (void)showFontList {
    self.fontList.hidden = NO;
}

- (void)scrollToTop {
    [self.articleDetail.scrollView setContentOffset:CGPointMake(0, - self.articleFrame.noImageViewCellHeight - 20) animated:NO];
}


@end
