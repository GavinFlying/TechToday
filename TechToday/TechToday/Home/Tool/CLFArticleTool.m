//
//  CLFArticleTool.m
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticleTool.h"
#import "CLFHttpTool.h"
#import "CLFArticle.h"
#import "CLFArticleCacheTool.h"
#import "CLFArticleFrame.h"
#import "CLFReachability.h"

@implementation CLFArticleTool

+ (void)articleWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure {
    NetworkStatus internetStatus = [[CLFReachability sharedCLFReachability] currentReachabilityStatus];
    // 先看下缓存中有没有数据
    NSMutableArray *articlesInDatabase = [CLFArticleCacheTool artilcesWithURLAppendage:URLAppendage params:params];
    
    if ([URLAppendage containsString:@"getArticle"]) {
        URLAppendage = @"getArticle";
    }
    
    // 缓存中有数据且为下拉刷新 返回缓存中的数据
    if ([URLAppendage containsString:@"getArticle"] && articlesInDatabase.count) {
        if (success) {
            NSMutableArray *articleFrameArray = [self convertArticleToArticleFrame:articlesInDatabase];
            success(articleFrameArray);
        }
        // 缓存中存在且加载形式为上拉加载的话,调用缓存中的东西.(没网络的情况下).有网络的情况下可能会出现因为加载了缓存导致中间的部分此前未缓存的article无法显示的情况
    } else if ([URLAppendage containsString:@"getMoreArticle"] && articlesInDatabase.count && (NotReachable == internetStatus)) {
        NSLog(@"dafasdf");
        if (success) {
            NSMutableArray *articleFrameArray = [self convertArticleToArticleFrame:articlesInDatabase];
            success(articleFrameArray);
        }
    } else {
        // 在网络中取数据.由于getArticle每次固定返回最新15篇,所以加入了 searchArticle, 判断文章是否已经存在.已经存在于数据库则返回数据库中的记录
        NSString *URL = [NSString stringWithFormat:@"http://jinri.info/index.php/DaiAppApi/%@", URLAppendage];
        [CLFHttpTool getWithURL:URL params:params success:^(id responseObject) {
            NSDictionary *msg = responseObject[@"msg"];
            NSMutableArray *articlesArray = [NSMutableArray array];
            for (NSDictionary *dict in msg) {
                CLFArticle *article = [CLFArticle articleWithDict:dict];
                CLFArticle *finalArticle = [CLFArticleCacheTool searchArticle:article];
                [articlesArray addObject:finalArticle];
            }
            
            [CLFArticleCacheTool addArticles:articlesArray];
            
            NSMutableArray *articleFrameArray = [self convertArticleToArticleFrame:articlesArray];
            if (success) {
                success(articleFrameArray);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

+ (NSMutableArray *)convertArticleToArticleFrame:(NSMutableArray *)articlesArray {
    NSMutableArray *articleFrameArray = [NSMutableArray array];
    for (CLFArticle *article in articlesArray) {
        CLFArticleFrame *articleFrame = [[CLFArticleFrame alloc] init];
        articleFrame.article = article;
        [articleFrameArray addObject:articleFrame];
    }
    return articleFrameArray;
}

@end
