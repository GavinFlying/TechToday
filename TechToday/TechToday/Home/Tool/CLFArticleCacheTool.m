//
//  CLFArticleCacheTool.m
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticleCacheTool.h"
#import "FMDB.h"
#import "CLFArticle.h"
#import <sqlite3.h>

@implementation CLFArticleCacheTool

static FMDatabaseQueue *_queue;

/**
 *  设置数据库,表内存储文章编号,文章发布时间戳及文章具体数据
 */
+ (void)setupDataBase {
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"article.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_article (id INTEGER PRIMARY KEY AUTOINCREMENT, articleID TEXT NOT NULL, articleCtime INTEGER, article BLOB NOT NULL);"];
    }];
    [_queue close];
}

/**
 *  在表中加入文章.如果文章不存在,则加入新纪录,否则更新文章数据(主要为了更新文章 read 与否的状态)
 */
+ (void)addArticle:(CLFArticle *)article {
    [self setupDataBase];
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *articleID = article.articleID;
        NSInteger articleCtime = article.articleCtime;
        NSData *articleData = [NSKeyedArchiver archivedDataWithRootObject:article];
        int recordCount = [db intForQuery:@"SELECT COUNT(*) FROM t_article WHERE articleID = ?;", articleID];
        if (!recordCount) {
            [db executeUpdate:@"INSERT INTO t_article (articleID, articleCtime, article) VALUES (?, ?, ?);", articleID, [NSNumber numberWithInteger:articleCtime], articleData];
        } else {
            [db executeUpdate:@"UPDATE t_article SET article = ? WHERE articleID = ?", articleData, articleID];
        }
    }];
    [_queue close];
}

+ (void)addArticles:(NSArray *)articlesArray {
    for (CLFArticle *article in articlesArray) {
        [self addArticle:article];
    }
}

/**
 *  搜索文章是否已经存在于表中.若存在,返回表中的文章
 */
+ (CLFArticle *)searchArticle:(CLFArticle *)article {
    [self setupDataBase];
    __block CLFArticle *aimArticle = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_article WHERE articleID = ?", article.articleID];
        
        while (resultSet.next) {
            NSData *articleData = [resultSet dataForColumn:@"article"];
            CLFArticle *articleInDatabase = [NSKeyedUnarchiver unarchiveObjectWithData:articleData];
            aimArticle = articleInDatabase;
        }
    }];
    [_queue close];
    if (aimArticle) {
        return aimArticle;
    }
    return article;
}

/**
 *  删除数据库中时间戳距离当前超过24小时的文章
 */
+ (void)deleteExpiredData {
    [self setupDataBase];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval secondsAfter1970 = [currentDate timeIntervalSince1970];
    NSTimeInterval expireTime = secondsAfter1970 - 24 * 60 * 60;
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM t_article WHERE articleCtime < ?", [NSNumber numberWithDouble:expireTime]];
    }];
    [_queue close];
}

/**
 *  根据是 上拉加载 还是 下拉刷新 来从数据库中加载 articles
 */
+ (NSMutableArray *)artilcesWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params {
    [self setupDataBase];

    NSString *URLCacheParam = nil;
    if ([URLAppendage isEqualToString:@"getArticle"]) {
        URLCacheParam = @"0";
    } else {
        URLCacheParam = [[URLAppendage componentsSeparatedByString:@"/"] lastObject];
    }
    __block NSMutableArray *articleArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        articleArray = [NSMutableArray array];
        
        FMResultSet *resultSet = nil;
        if ([URLAppendage containsString:@"getArticle"]) {
            // 这一句用于避免第一次加载去网络上拿数据 及 在没有网络的情况下加载数据
            resultSet = [db executeQuery:@"SELECT * FROM t_article WHERE articleID > ? ORDER BY articleID DESC LIMIT 0, 15;", URLCacheParam];
        } else if ([URLAppendage containsString:@"getMoreArticle"]) {
            resultSet = [db executeQuery:@"SELECT * FROM t_article WHERE articleID < ? ORDER BY articleID DESC LIMIT 0, 15;", URLCacheParam];
        }
        while (resultSet.next) {
            NSData *articleData = [resultSet dataForColumn:@"article"];
            CLFArticle *article = [NSKeyedUnarchiver unarchiveObjectWithData:articleData];
            [articleArray addObject:article];
        }
    }];
    [_queue close];
    
    return articleArray;
}

@end
