//
//  CLFArticleCacheTool.h
//  jinri
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLFArticle;
@interface CLFArticleCacheTool : NSObject

+ (void)addArticle:(CLFArticle *)article;
+ (void)addArticles:(NSArray *)articlesArray;
+ (NSArray *)artilcesWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params;
+ (CLFArticle *)searchArticle:(CLFArticle *)article;

@end
