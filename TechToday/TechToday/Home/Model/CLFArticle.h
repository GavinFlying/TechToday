//
//  CLFArticle.h
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFArticle : NSObject <NSCoding>

// 文章发布的时间 HH:mm:ss
@property (copy, nonatomic) NSString *date;
// 文章来源网站 编号
@property (copy, nonatomic) NSString *source;
// 文章题图地址
@property (copy, nonatomic) NSString *img;
// 文章阅读人数
@property (copy, nonatomic) NSString *pageViews;
// 文章标题
@property (copy, nonatomic) NSString *title;
// 文章编号
@property (copy, nonatomic) NSString *articleID;
// 文章来源网址
@property (copy, nonatomic) NSString *url;
// 文章时间戳
@property (assign, nonatomic) NSInteger articleCtime;
// 文章是否已经被用户读过
@property (assign, nonatomic, getter=isRead) BOOL read;

+ (instancetype)articleWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
