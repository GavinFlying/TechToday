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
#import "CLFArticleDetailController.h"
#import "CLFNavigationController.h"
#import "MJRefresh.h"
#import "CLFArticleTool.h"
#import "MBProgressHUD+MJ.h"
#import "CLFCommonHeader.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "CLFAppDelegate.h"
#import "CLFLoginController.h"
#import "CLFSettingViewController.h"
#import "UIImage+CLF.h"
#import "CLFArticleNoImageCell.h"

@interface CLFHomeViewController () <CLFArticleDetailDelegate, CLFSettingViewControllerDelegate>

@property (strong, nonatomic, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (strong, nonatomic) NSMutableArray *articleFrames;

@property (weak, nonatomic) UIButton *theNewArticleRemindButton;

@property (weak, nonatomic) UIView *navigationBarView;

@property (assign, nonatomic) NSInteger firstDetailPage;

@property (weak, nonatomic) CLFArticleDetailController *articleDetailController;

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
//    [self loadNewData];
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    return [[CLFAppDelegate globalDelegate] drawerAnimator];
}

- (void)configureAnimator {
    self.drawerAnimator.animationDuration = 0.7;
    self.drawerAnimator.animationDelay = 0;
    self.drawerAnimator.initialSpringVelocity = 9;
    self.drawerAnimator.springDamping = 0.8;
}

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

/**
 *  设置导航栏样式.背景/Title/leftBarButton后期用图片替换
 */
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
    
    UIButton *remindButton = [[UIButton alloc] init];
    [self.navigationController.view insertSubview:remindButton belowSubview:self.navigationController.navigationBar];
    remindButton.userInteractionEnabled = NO;
    remindButton.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:255 / 255.0 alpha:1.0];
    remindButton.nightBackgroundColor = CLFNightTextColor;
    remindButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [remindButton setTitleColor:CLFUIMainColor forState:UIControlStateNormal];
    remindButton.nightTitleColor = CLFNightBarColor;
    remindButton.hidden = YES;
    CGFloat remindButtonH = 30;
    CGFloat remindButtonY = 64 - remindButtonH;
    CGFloat remindButtonX = 0;
    CGFloat remindButtonW = CGRectGetWidth(self.view.frame);
    remindButton.frame = CGRectMake(remindButtonX, remindButtonY, remindButtonW, remindButtonH);
    self.theNewArticleRemindButton = remindButton;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:226 / 255.0 green:226 / 255.0 blue:236 / 255.0 alpha:1.0];
    self.tableView.nightBackgroundColor = CLFNightViewColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CLFArticleCellToBorderMargin, 0);
}

- (void)showSettingView {
    [[CLFAppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

/**
 *  加载更多数据(下拉刷新)
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
//    URLAppendage = @"getArticle";
    
    [CLFArticleTool articleWithURLAppendage:URLAppendage params:params success:^(NSArray *articlesArray) {
        // 可封装进去
        NSMutableArray *articleFrameArray = [NSMutableArray array];
        for (CLFArticle *article in articlesArray) {
            CLFArticleFrame *articleFrame = [[CLFArticleFrame alloc] init];
            articleFrame.article = article;
            [articleFrameArray addObject:articleFrame];
        }
        
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
        NSLog(@"%@", error);
        [self.tableView.header endRefreshing];

    }];
}

- (void)loadMoreData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    CLFArticleFrame *articleFrame = [self.articleFrames lastObject];
    NSString *URLAppendage = [NSString stringWithFormat:@"getMoreArticle/%@", articleFrame.article.articleID];
    
    [CLFArticleTool articleWithURLAppendage:URLAppendage params:params success:^(NSArray *articlesArray) {
        NSMutableArray *articleFrameArray = [NSMutableArray array];
        for (CLFArticle *article in articlesArray) {
            CLFArticleFrame *articleFrame = [[CLFArticleFrame alloc] init];
            articleFrame.article = article;
            [articleFrameArray addObject:articleFrame];
        }
    
        [self.articleFrames addObjectsFromArray:articleFrameArray];
        
        [self.tableView reloadData];
        
        [self.tableView.footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self.tableView.footer endRefreshing];
    }];
}

- (void)showNewArticleCount:(long)count {
    
    self.theNewArticleRemindButton.hidden = NO;
    if (count) {
        [self.theNewArticleRemindButton setTitle:[NSString stringWithFormat:@"更新了%ld篇文章", count] forState:UIControlStateNormal];
    } else {
        [self.theNewArticleRemindButton setTitle:@"没有新的文章" forState:UIControlStateNormal];
    }

    [UIView animateWithDuration:0.5 animations:^{
        self.theNewArticleRemindButton.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.theNewArticleRemindButton.frame));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.theNewArticleRemindButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.theNewArticleRemindButton.hidden = YES;
        }];
    }];    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articleFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([CLFAppDelegate globalDelegate].isNoImageModeOn) {
        CLFArticleNoImageCell *cell = (CLFArticleNoImageCell *)[CLFArticleNoImageCell cellWithTableView:tableView];
        CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
        cell.articleFrame = articleFrame;
        cell.backgroundColor = [UIColor whiteColor];
        cell.nightBackgroundColor = CLFNightViewColor;
        if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        return cell;
    } else {
        CLFArticleCell *cell = (CLFArticleCell *)[CLFArticleCell cellWithTableView:tableView];
        CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
        cell.articleFrame = articleFrame;
        cell.backgroundColor = [UIColor whiteColor];
        cell.nightBackgroundColor = CLFNightViewColor;
        if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
    if ([CLFAppDelegate globalDelegate].isNoImageModeOn) {
        return articleFrame.noImageViewCellHeight;
    }
    return articleFrame.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.firstDetailPage = indexPath.row;
    self.theNewArticleRemindButton.hidden = YES;
    CLFArticleFrame *articleFrame = self.articleFrames[indexPath.row];
    CLFArticleDetailController *articleDetailController = [[CLFArticleDetailController alloc] init];
    articleDetailController.articleFrame = articleFrame;
    articleDetailController.delegate = self;
    self.articleDetailController = articleDetailController;
    [self.navigationController pushViewController:articleDetailController animated:YES];
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
