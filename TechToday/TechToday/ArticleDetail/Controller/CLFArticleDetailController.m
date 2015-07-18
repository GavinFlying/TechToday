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
#import "CLFShareView.h"

@interface CLFArticleDetailController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ISSShareViewDelegate>
// 显示文章的webView
@property (weak, nonatomic)   CLFWebView  *articleDetail;
// 点击更多选项出现的tableView
@property (weak, nonatomic)   UITableView *moreOptionList;
// 点击更多选项中的字体调整后出现的tableView
@property (weak, nonatomic)   UITableView *fontList;
// 文章字体大小
@property (assign, nonatomic) NSInteger   fontSize;

@end

@implementation CLFArticleDetailController

- (instancetype)init {
    if (self = [super init]) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTapRecognizer.delegate = self;
        [self.articleDetail addGestureRecognizer:singleTapRecognizer];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:@"articleFontSize"]) {
            self.fontSize = [defaults integerForKey:@"articleFontSize"];
        } else {
            self.fontSize = 13;
        }
    }
    return self;
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

#pragma mark - about articleDetail WebView

/**
 *  根据传入的 articleFrame 来设置 webView 的内容
 */
- (void)setArticleFrame:(CLFArticleFrame *)articleFrame {
    _articleFrame = articleFrame;
    self.articleDetail.scrollView.hidden = YES;
    [self setupWebView];
}

- (CLFWebView *)articleDetail {
    if (!_articleDetail) {
        CLFWebView *articleDetail = [[CLFWebView alloc] init];
        articleDetail = articleDetail;
        articleDetail.frame = self.view.frame;
        articleDetail.backgroundColor = [UIColor clearColor];
        articleDetail.nightBackgroundColor = CLFNightViewColor;
        articleDetail.opaque = NO;
        articleDetail.scalesPageToFit = YES;
        articleDetail.delegate = self;
        articleDetail.scrollView.delegate = self;
        [self.view addSubview:articleDetail];
//        articleDetail.translatesAutoresizingMaskIntoConstraints = NO;
//        articleDetail.layoutMargins = UIEdgeInsetsMake(0, -16, 0, -16);
//        articleDetail.preservesSuperviewLayoutMargins = NO;
//        NSArray *detailConts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[detail]-|" options:0 metrics:nil views:@{@"detail" : articleDetail}];
//        NSArray *detailConts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[detail]-|" options:0 metrics:nil views:@{@"detail" : articleDetail}];
//
//        [self.view addConstraints:detailConts1];
//        [self.view addConstraints:detailConts2];
        _articleDetail = articleDetail;
    }
    return _articleDetail;
}

- (void)setupWebView {
    // 传入要显示的文章模型,设置webView内容显示高度/标题
    self.articleDetail.scrollView.contentInset = UIEdgeInsetsMake(self.articleFrame.noImageViewCellHeight + 20, 0, -self.articleFrame.noImageViewCellHeight - 64, 0);
    self.articleDetail.article = self.articleFrame.article;
    self.articleDetail.titleHeight = self.articleFrame.noImageViewCellHeight;
    
    // 这篇文章设置为已读, 同时更新数据库中文章的状态
    CLFArticle *article = self.articleFrame.article;
    article.read = YES;
    [CLFArticleCacheTool addArticle:article];
    
    // 根据文章ID来显示文章正文
    [self showArticleDetail:article.articleID];
}

- (void)showArticleDetail:(NSString *)str {
    NSString *urlStr = [NSString stringWithFormat:@"http://jinri.info/index.php/DaiAppApi/showArticle/%@", str];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *HTMLSource = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    // 如果是无图模式且已经有页面数据,则获取 html 源码,通过正则表达式去除所有图片的标签,再通过 webView 显示; 否则通过 URLRequest 正常加载
    if (([CLFAppDelegate globalDelegate].isNoImageModeOn) && HTMLSource) {
        NSRegularExpression *regexToImage = [NSRegularExpression regularExpressionWithPattern:@"<\\s*img [^\\>]*src\\s*=\\s*([\"|\'])(.*?)[\"|\'][^']*?>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *pureHTMLSource = [regexToImage stringByReplacingMatchesInString:HTMLSource options:NSMatchingReportCompletion range:NSMakeRange(0, HTMLSource.length) withTemplate:@""];
        [self.articleDetail loadHTMLString:pureHTMLSource baseURL:nil];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.articleDetail loadRequest:request];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showMessage:@"加载中..." toView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 设置普通模式及夜间模式的正文颜色
    NSString *fontColor = nil;
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        fontColor = @"#828282";
    } else {
        fontColor = @"#000000";
    }
    
    // 为html添加css样式,修改字体大小/字体等
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
                                                     @"var tagHead =document.documentElement.firstChild;"
                                                     "var tagStyle = document.createElement(\"style\");"
                                                     "tagStyle.setAttribute(\"type\", \"text/css\");"
                                                     "tagStyle.appendChild(document.createTextNode(\"BODY{padding: 10pt 15pt}\"));"
                                                     "tagStyle.appendChild(document.createTextNode(\"BODY{text-align: justify}\"));"
                                                     "tagStyle.appendChild(document.createTextNode(\"BODY{background-color: transparent}\"));"
                                                     "tagStyle.appendChild(document.createTextNode(\"BODY{font-family: SourceHanSansCN-Light; font-size: %ldpt; color: %@}\"));"
                                                     "var tagHeadAdd = tagHead.appendChild(tagStyle);", (long)self.fontSize, fontColor]];
    
    // 据说能减轻 webView 的内存泄露 =,=
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 文章加载之后, 获得文章的高度,再次传入 webView 来设置 buttonView 的位置
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

// 清除缓存
//- (void)cleanCacheWithRequest:(NSURLRequest *)request {
//    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//        if ([[cookie domain] isEqualToString:[request.URL absoluteString]]) {
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//        }
//    }
//}

#pragma mark - set up toolbarItems

- (void)setupToolBarItem {
    CGFloat toolbarH = CGRectGetHeight(self.navigationController.toolbar.frame);
    
    // back to homeViewController
    UIButton *backButton = [[UIButton alloc] init];
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, toolbarH * 0.4, toolbarH * 0.6);
    [backButton addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // show next article
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.contentMode = UIViewContentModeScaleAspectFit;
    nextButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.4);
    [nextButton addTarget:self action:@selector(switchToNextArticle) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    // TODO : show comments and submit comment
    //    UIButton *commentButton = [[UIButton alloc] init];
    //    commentButton.contentMode = UIViewContentModeScaleAspectFit;
    //    commentButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.5);
    //    [commentButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    // share article to Weibo/Weixin etc
    UIButton *shareButton = [[UIButton alloc] init];
    shareButton.contentMode = UIViewContentModeScaleAspectFit;
    shareButton.frame = CGRectMake(0, 0, toolbarH * 0.4, toolbarH * 0.6);
    [shareButton addTarget:self action:@selector(showShareView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    // show more options
    UIButton *moreButton = [[UIButton alloc] init];
    moreButton.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.frame = CGRectMake(0, 0, toolbarH * 0.6, toolbarH * 0.5);
    [moreButton addTarget:self action:@selector(showMoreOptions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    // change the button icon according to currentThemeVersion : night or normal
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrowNight"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrowNight"] forState:UIControlStateNormal];
        //        [commentButton setImage:[UIImage imageNamed:@"ToolbarCommentNight"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShareNight"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"ToolbarMoreOptionsNight"] forState:UIControlStateNormal];
    } else {
        self.navigationController.toolbar.barStyle = UIBarStyleDefault;
        [backButton setImage:[UIImage imageNamed:@"ToolbarBackArrow"] forState:UIControlStateNormal];
        [nextButton setImage:[UIImage imageNamed:@"ToolbarNextArrow"] forState:UIControlStateNormal];
        //        [commentButton setImage:[UIImage imageNamed:@"ToolbarComment"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"ToolbarShare"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"ToolbarMoreOptions"] forState:UIControlStateNormal];
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

- (void)showShareView {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"TechToday" ofType:@"png"];
    CLFArticle *article = self.articleFrame.article;
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"推荐jinri.info上的一篇文章:\n%@ http://jinri.info/index.php/DaiArticle/index/%@", article.title, article.articleID]
                                       defaultContent:nil
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"TechToday"
                                                  url:[NSString stringWithFormat:@"http://jinri.info/index.php/DaiArticle/index/%@", article.articleID]
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"Share"
                                                              oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                               qqButtonHidden:YES
                                                        wxSessionButtonHidden:YES
                                                       wxTimelineButtonHidden:YES
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:self
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];

    [CLFShareView shareWithContent:publishContent shareOptions:shareOptions authOptions:authOptions];
}

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType {
    UIView *editView = [viewController.view.subviews lastObject];
    UITextView *editTextView = [editView.subviews lastObject];
    editView.backgroundColor = [UIColor whiteColor];
    editTextView.backgroundColor = [UIColor whiteColor];
    editView.nightBackgroundColor = CLFNightViewColor;
    editTextView.nightBackgroundColor = CLFNightViewColor;
    viewController.view.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.7];
    viewController.view.nightBackgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.7];    
}

//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
//    NSLog(@"%@", actionSheet.subviews);
//}

#pragma mark - show more options && change font size

- (UITableView *)moreOptionList {
    if (!_moreOptionList) {
        UITableView *moreOptionList = [[UITableView alloc] init];
        [self.view addSubview:moreOptionList];
        
        moreOptionList.backgroundColor = [UIColor whiteColor];
        moreOptionList.nightBackgroundColor = CLFNightViewColor;
        
        moreOptionList.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        CGFloat moreOptionW = 100;
        CGFloat moreOptionH = 60;
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

- (void)showFontList {
    self.fontList.hidden = NO;
}

- (void)scrollToTop {
    [self.articleDetail.scrollView setContentOffset:CGPointMake(0, - self.articleFrame.noImageViewCellHeight - 20) animated:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/**
 *  单击屏幕隐藏 fontList 和 moreOptionList
 */
- (void)singleTap:(UITapGestureRecognizer *)singleTapRecognizer {
    if (!self.fontList.hidden) {
        self.fontList.hidden = YES;
    }
    if (!self.moreOptionList.hidden) {
        self.moreOptionList.hidden = YES;
    }
}

/**
 *  开始滚动隐藏 fontList 和 moreOpitonList
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.fontList.hidden) {
        self.fontList.hidden = YES;
    }
    if (!self.moreOptionList.hidden) {
        self.moreOptionList.hidden = YES;
    }
}

#pragma mark - delegate methods && dataSource methods of fontList && moreOptionList

/**
 *  set up the tableView according to tableView's tag
 */

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
                self.fontSize = 9;
                break;
            }
            case 1: {
                self.fontSize = 11;
                break;
            }
            case 2: {
                self.fontSize = 13;
                break;
            }
            case 3: {
                self.fontSize = 15;
                break;
            }
            case 4: {
                self.fontSize = 17;
                break;
            }
        }
        self.articleFrame = self.articleFrame; // 重新传入 articleFrame 达到刷新的目的
        
        // 将选择的字号归档
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:self.fontSize forKey:@"articleFontSize"];
        [defaults synchronize];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    tableView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
