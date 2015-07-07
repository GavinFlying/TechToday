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

+ (void)setupDataBase {
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"article.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_article (id INTEGER PRIMARY KEY AUTOINCREMENT, articleID TEXT NOT NULL, articleCtime TEXT NOT NULL, article BLOB NOT NULL);"];
    }];
    [_queue close];
}

+ (void)addArticle:(CLFArticle *)article {
    [self setupDataBase];
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *articleID = article.articleID;
        NSString *articleCtime = article.articleCtime;
        NSData *articleData = [NSKeyedArchiver archivedDataWithRootObject:article];
        
        int recordCount = [db intForQuery:@"SELECT COUNT(*) FROM t_article WHERE articleID = ?;", articleID];
        if (!recordCount) {
            [db executeUpdate:@"INSERT INTO t_article (articleID, articleCtime, article) VALUES (?, ?, ?);", articleID, articleCtime, articleData];
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

+ (void)deleteExpiredData {
    [self setupDataBase];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval secondsAfter1970 = [currentDate timeIntervalSince1970];
    NSTimeInterval expireTime = secondsAfter1970 - 24 * 60 * 60;
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM t_article WHERE articleCtime < ?", expireTime];
    }];
    [_queue close];
}

+ (NSArray *)artilcesWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params {
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
