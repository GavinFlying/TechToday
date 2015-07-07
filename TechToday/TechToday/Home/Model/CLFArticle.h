//
//  CLFArticle.h
//  jinri
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFArticle : NSObject <NSCoding>

@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *source;
@property (copy, nonatomic) NSString *img;
@property (copy, nonatomic) NSString *pageViews;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *articleID;
@property (copy, nonatomic) NSString *url;
@property (assign, nonatomic, getter=isRead) BOOL read;

+ (instancetype)articleWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
