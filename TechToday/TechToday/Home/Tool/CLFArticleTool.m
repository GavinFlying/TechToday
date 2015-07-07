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

@implementation CLFArticleTool

+ (void)articleWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    
    NSArray *articlesInDatabase = [CLFArticleCacheTool artilcesWithURLAppendage:URLAppendage params:params];
    
    if ([URLAppendage containsString:@"getArticle"]) {
        URLAppendage = @"getArticle";
    }
#warning 下拉刷新/缓存/有网络/没网络 TODO
    NSLog(@"%ld", articlesInDatabase.count);
    if ([URLAppendage containsString:@"getArticle"] && articlesInDatabase.count) { // 可加个判断给上拉加载用.缓存中存在且加载形式为上拉加载的话,调用缓存中的东西.(没网络的情况下).有网络的情况下可能会出现因为加载了缓存导致中间的部分此前未缓存的article无法显示的情况
        if (success) {
            success(articlesInDatabase);
        }
    } else {
        NSString *URL = [NSString stringWithFormat:@"http://TechToday.info/index.php/DaiAppApi/%@", URLAppendage];
        
        [CLFHttpTool getWithURL:URL params:params success:^(id responseObject) {
            NSDictionary *msg = responseObject[@"msg"];
            NSMutableArray *articlesArray = [NSMutableArray array];
            for (NSDictionary *dict in msg) {
                CLFArticle *article = [CLFArticle articleWithDict:dict];
                // 可以加一个在数据库中搜索这篇文章是否已经存在的句子,如果存在,则返回数据库中的那个article,可以解决刷新后,原来变灰色的又变成黑色的bug.上拉下拉似乎都能用?
                CLFArticle *finalArticle = [CLFArticleCacheTool searchArticle:article];
                [articlesArray addObject:finalArticle];
            }
            
            [CLFArticleCacheTool addArticles:articlesArray];
            
            if (success) {
                success(articlesArray);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}


@end
