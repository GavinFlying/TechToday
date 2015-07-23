//
//  CLFHomeViewController.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFHomeViewController.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"
#import "CLFArticleCell.h"
#import "CLFArticleNoImageCell.h"
#import "CLFArticleDetailController.h"
#import "CLFNavigationController.h"
#import "MJRefresh.h"
#import "CLFArticleTool.h"
#import "MBProgressHUD+MJ.h"
#import "CLFCommonHeader.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "CLFAppDelegate.h"
#import "CLFSettingViewController.h"


@interface CLFHomeViewController () <CLFArticleDetailDelegate, CLFSettingViewControllerDelegate>

// 切换到 settingViewController 时动画用
@property (strong, nonatomic, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;
// 文章及其frame
@property (strong, nonatomic)           NSMutableArray                 *articleFrames;
// 新文章数提示栏
@property (weak, nonatomic)             UIButton                       *theNewArticleRemindButton;
// 从哪篇文章进入详情页的 用于详情页内部切换文章功能的实现
@property (assign, nonatomic)           NSInteger                      firstDetailPage;
// 文章详情页控制器
@property (weak, nonatomic)             CLFArticleDetailController     *articleDetailController;

@end

@implementation CLFHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAnimator];
    [self setupRefreshView];
    [self setupNavigationBar];
    CLFSettingViewController *setting = (CLFSettingViewController *)[CLFAppDelegate globalDelegate].drawerViewController.leftViewController;
    setting.delegate = self;
    [CLFAppDelegate globalDelegate].noImageModeOn = NO;
}

#pragma mark - UI : theNewArticleRemindButton && NavigationBar

/**
 *  theNewArticleRemindButton : 在用户下拉刷新时,提醒用户一共更新了多少篇新文章
 */
- (UIButton *)theNewArticleRemindButton {
    if (!_theNewArticleRemindButton) {
        UIButton *remindButton = [[UIButton alloc] init];
        [self.navigationController.view insertSubview:remindButton belowSubview:self.navigationController.navigationBar];
        remindButton.userInteractionEnabled = NO;
        remindButton.titleLabel.font = [UIFont systemFontOfSize:14];
        remindButton.hidden = YES;
        
        CGFloat remindButtonH = 30;
        CGFloat remindButtonY = 64 - remindButtonH;
        CGFloat remindButtonX = 0;
        CGFloat remindButtonW = CGRectGetWidth(self.view.frame);
        remindButton.frame = CGRectMake(remindButtonX, remindButtonY, remindButtonW, remindButtonH);

        _theNewArticleRemindButton = remindButton;
    }
    return _theNewArticleRemindButton;
}

- (void)showNewArticleCount:(long)count {
    // set color in here to fix a bug of DKNightVersion: launch the app in Night Mode && noImage Mode, then turn to normal mode, the remindButton would get something wrong.
    self.theNewArticleRemindButton.hidden = NO;
    self.theNewArticleRemindButton.backgroundColor = CLFRemindButtonBackgroundColor;
    self.theNewArticleRemindButton.nightBackgroundColor = CLFNightTextColor;
    [self.theNewArticleRemindButton setTitleColor:CLFUIMainColor forState:UIControlStateNormal];
    self.theNewArticleRemindButton.nightTitleColor = CLFNightBarColor;
    
    if (count) {
        [self.theNewArticleRemindButton setTitle:[NSString stringWithFormat:@"更新了%ld篇文章", count] forState:UIControlStateNormal];
    } else {
        [self.theNewArticleRemindButton setTitle:@"没有新的文章" forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.theNewArticleRemindButton.transform = CGAffineTransformMakeTranslation(0, 30);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.theNewArticleRemindButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.theNewArticleRemindButton.hidden = YES;
        }];
    }];
}

- (void)setupNavigationBar {
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"SettingButton"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 24, 20);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.frame = CGRectMake(0, 0, 24, 20);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIImageView *titleView = [[UIImageView alloc] init];
    UIImage *titleImage = [UIImage imageNamed:@"navigationbarTitleImage"];
    titleView.image = titleImage;
    titleView.frame = CGRectMake(0, 0, 80, 20);
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleView;
    
    self.tableView.backgroundColor = CLFHomeViewBackgroundColor;
    self.tableView.nightBackgroundColor = CLFNightViewColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CLFArticleCellToBorderMargin, 0);
}

#pragma mark - refresh data in homeViewController

- (void)setupRefreshView {
    __weak typeof(self) weakSelf = self;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    [self.tableView.header beginRefreshing];
    
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}

/**
 *  当前 api 规则是: 
 *  下拉刷新 getArticle 返回最新15篇文章
 *  上拉加载 getMoreArticle/articleID 返回 articleID 及之前的15篇文章
 */

- (void)loadNewData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *URLAppendage = nil;
    if (self.articleFrames.count) { // ....不加这个判断每次都会去缓存加载.
        CLFArticleFrame *articleFrame = self.articleFrames[0];
        URLAppendage = [NSString stringWithFormat:@"getArticle/%@", articleFrame.article.articleID];
    } else {
        URLAppendage = @"getArticle";
    }
    
    [CLFArticleTool articleWithURLAppendage:URLAppendage params:params success:^(NSMutableArray *articleFrameArray) {
        if (self.articleFrames.count) {
            CLFArticleFrame *latestArticleFrame = articleFrameArray[0];
            CLFArticle *latestArticle = latestArticleFrame.article;
            NSString *latestArticleID = latestArticle.articleID;
            
            CLFArticleFrame *currentLatestArticleFrame = self.articleFrames[0];
            CLFArticle *currentLatestArticle = currentLatestArticleFrame.article;
            NSString *currentLatestArticleID = currentLatestArticle.articleID;
            
            NSInteger newArticleCount = ([latestArticleID integerValue] - [currentLatestArticleID integerValue]);
            
            [self showNewArticleCount:newArticleCount];
        }
        
        self.articleFrames = articleFrameArray;

        [self.tableView reloadData];
            
        [self.tableView.header endRefreshing];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接异常" toView:self.navigationController.view];
        [self.tableView.header endRefreshing];

    }];
}

- (void)loadMoreData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    CLFArticleFrame *articleFrame = [self.articleFrames lastObject];
    NSString *URLAppendage = [NSString stringWithFormat:@"getMoreArticle/%@", articleFrame.article.articleID];
    
    [CLFArticleTool articleWithURLAppendage:URLAppendage params:params success:^(NSMutableArray *articleFrameArray) {
        if (!articleFrameArray.count) {
            [MBProgressHUD showError:@"没有更多文章了"];
        }
        [self.articleFrames addObjectsFromArray:articleFrameArray];
        
        [self.tableView reloadData];
        
        [self.tableView.footer endRefreshing];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接异常" toView:self.navigationController.view];
        [self.tableView.footer endRefreshing];
    }];
}

#pragma mark - about the articleDetailPage

/**
 *  用于转入文章详情页.当文章详情页内通过点击向下按钮直接访问下面的文章时,
 *  实现代理方法(articleDetailSwitchToNextArticleFromCurrentArticle)
 *  传入新的articleFrame以达到切换到下一篇文章的目的.
 */
- (NSMutableArray *)articleFrames {
    if (!_articleFrames) {
        _articleFrames = [NSMutableArray array];
    }
    return _articleFrames;
}

- (CLFArticleDetailController *)articleDetailController {
    if (!_articleDetailController) {
        CLFArticleDetailController *articelDetailController = [[CLFArticleDetailController alloc] init];
        _articleDetailController = articelDetailController;
    }
    return _articleDetailController;
}

- (void)articleDetailSwitchToNextArticleFromCurrentArticle {
    self.firstDetailPage += 1;
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:self.firstDetailPage inSection:0];
    
    if (self.articleFrames.count - 1 == self.firstDetailPage) {
        dispatch_queue_t queue = dispatch_queue_create("loadThread", DISPATCH_QUEUE_CONCURRENT);
        dispatch_sync(queue, ^{
            [self loadMoreData];
        });
        dispatch_sync(queue, ^{
            CLFArticleFrame *articleFrame = self.articleFrames[nextIndexPath.row];
            self.articleDetailController.articleFrame = articleFrame;
        });
    } else if (self.articleFrames.count == self.firstDetailPage) {
        [MBProgressHUD showError:@"已经看完所有文章"];
        self.firstDetailPage -= 1;
    } else {
        CLFArticleFrame *articleFrame = self.articleFrames[nextIndexPath.row];
        self.articleDetailController.articleFrame = articleFrame;
    }
}

#pragma mark - tableView dataSource methods && delegate methods

/**
 *  根据当前是普通模式还是无图模式,显示不同的cell
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articleFrames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
    if ([CLFAppDelegate globalDelegate].isNoImageModeOn) {
        return articleFrame.noImageViewCellHeight;
    }
    return articleFrame.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFArticleNoImageCell *cell = nil;
    if ([CLFAppDelegate globalDelegate].isNoImageModeOn) {
        cell = [CLFArticleNoImageCell cellWithTableView:tableView];
    } else {
        cell = [CLFArticleCell cellWithTableView:tableView];
    }
    CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
    cell.articleFrame = articleFrame;
    cell.backgroundColor = [UIColor whiteColor];
    cell.nightBackgroundColor = CLFNightCellColor;
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.firstDetailPage = indexPath.row;
    self.theNewArticleRemindButton.hidden = YES;
    CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
    CLFArticleDetailController *articleDetailController = [[CLFArticleDetailController alloc] init];
    articleDetailController.articleFrame = articleFrame;
    articleDetailController.delegate = self;
    self.articleDetailController = articleDetailController;
    NSLog(@"didSelect");
    [self.navigationController pushViewController:articleDetailController animated:YES];
}

#pragma mark - about settingViewController

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    return [[CLFAppDelegate globalDelegate] drawerAnimator];
}

- (void)configureAnimator {
    self.drawerAnimator.animationDuration = 0.7;
    self.drawerAnimator.animationDelay = 0;
    self.drawerAnimator.initialSpringVelocity = 9;
    self.drawerAnimator.springDamping = 0.8;
}

- (void)showSettingView {
    [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark others
- (void)reloadViewData {
    [self.tableView reloadData];
}

- (void)noImageModeChanged {
    [CLFAppDelegate globalDelegate].noImageModeOn = ![CLFAppDelegate globalDelegate].noImageModeOn;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
