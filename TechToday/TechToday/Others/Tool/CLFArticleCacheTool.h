//
//  CLFArticleCacheTool.h
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completionBlock) ();

@class CLFArticle;
@interface CLFArticleCacheTool : NSObject

+ (void)addArticle:(CLFArticle *)article;
+ (void)addArticles:(NSArray *)articlesArray;
+ (NSMutableArray *)artilcesWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params;
+ (CLFArticle *)searchArticle:(CLFArticle *)article;
+ (void)deleteExpiredData;

+ (CGFloat)fileSizeAtPath:(NSString *)path;
+ (CGFloat)directorySizeAtPath:(NSString *)path;
+ (void)clearCacheAtPath:(NSString *)path completion:(completionBlock)completion;

@end
