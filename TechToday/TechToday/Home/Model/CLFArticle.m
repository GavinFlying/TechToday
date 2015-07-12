//
//  CLFArticle.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticle.h"
#import "NSCalendar+CLF.h"

#define kDateKey         @"dateKey"
#define kSourceKey       @"sourceKey"
#define kImgKey          @"imgKey"
#define kPageViewsKey    @"pageViewsKey"
#define kTitleKey        @"titleKey"
#define kArticleKey      @"articleKey"
#define kURLKey          @"URLKey"
#define kArticleCtimeKey @"ArticleCtimeKey"
#define kReadKey         @"readKey"

@implementation CLFArticle

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.date = dict[@"date"];
        self.source = dict[@"author_id"];
        self.img = dict[@"img"];
        self.pageViews = [NSString stringWithFormat:@"阅读: %@", dict[@"page_views"]];
        self.title = dict[@"title"];
        self.articleID = dict[@"id"];
        self.url = dict[@"url"];
        self.articleCtime = [dict[@"ctime"] integerValue];
        self.read = NO;
    }
    return self;
}

+ (instancetype)articleWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

/**
 *  结合时间戳和date, 显示文章发布时间与当前时间的时间差
 */
- (NSString *)date {
    NSDate *creatTimeInterval = [NSDate dateWithTimeIntervalSince1970:_articleCtime];
 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar isDateInToday:creatTimeInterval]) {
        NSDateComponents *interval = [calendar deltaWithNow:creatTimeInterval];
        if (interval.hour >= 1) {
            return [NSString stringWithFormat:@"%ld小时前", (long)interval.hour];
        } else if (interval.minute >= 1) {
            return [NSString stringWithFormat:@"%ld分钟前", (long)interval.minute];
        } else {
            return @"刚刚";
        }

    } else {
        return _date;
    }
}

#pragma mark - encode && decode
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_date forKey:kDateKey];
    [aCoder encodeObject:_source forKey:kSourceKey];
    [aCoder encodeObject:_img forKey:kImgKey];
    [aCoder encodeObject:_pageViews forKey:kPageViewsKey];
    [aCoder encodeObject:_title forKey:kTitleKey];
    [aCoder encodeObject:_articleID forKey:kArticleKey];
    [aCoder encodeObject:_url forKey:kURLKey];
    [aCoder encodeInteger:_articleCtime forKey:kArticleCtimeKey];
    [aCoder encodeInt:_read forKey:kReadKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:kDateKey];
        _source = [aDecoder decodeObjectForKey:kSourceKey];
        _img = [aDecoder decodeObjectForKey:kImgKey];
        _pageViews = [aDecoder decodeObjectForKey:kPageViewsKey];
        _title = [aDecoder decodeObjectForKey:kTitleKey];
        _articleID = [aDecoder decodeObjectForKey:kArticleKey];
        _url = [aDecoder decodeObjectForKey:kURLKey];
        _articleCtime = [aDecoder decodeIntegerForKey:kArticleCtimeKey];
        _read = [aDecoder decodeIntForKey:kReadKey];
    }
    return self;
}

@end
