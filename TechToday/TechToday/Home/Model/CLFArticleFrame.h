//
//  CLFArticleFrame.h
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFArticle;
@interface CLFArticleFrame : NSObject

@property (strong, nonatomic) CLFArticle *article;

// 普通模式cell中的各个要素的 frame
@property (assign, readonly, nonatomic) CGRect imageViewFrame;
@property (assign, readonly, nonatomic) CGRect titleLabelFrame;
@property (assign, readonly, nonatomic) CGRect sourceLabelFrame;
@property (assign, readonly, nonatomic) CGRect dateLabelFrame;
@property (assign, readonly, nonatomic) CGRect pageViewsLabelFrame;

@property (assign, readonly, nonatomic) CGFloat cellHeight;

// 无图模式cell中各个要素的 frame
@property (assign, readonly, nonatomic) CGRect noImageViewTitleLabelFrame;
@property (assign, readonly, nonatomic) CGRect noImageViewSourceLabelFrame;
@property (assign, readonly, nonatomic) CGRect noImageViewDateLabelFrame;
@property (assign, readonly, nonatomic) CGRect noImageViewPageViewsLabelFrame;

@property (assign, readonly, nonatomic) CGFloat noImageViewCellHeight;

@end
