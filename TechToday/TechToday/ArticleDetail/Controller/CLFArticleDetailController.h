//
//  CLFArticleDetailController.h
//  TechToday
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFArticleDetailDelegate <NSObject>

@optional
- (void)articleDetailSwitchToNextArticleFromCurrentArticle;
@end

@class CLFArticleFrame;
@interface CLFArticleDetailController : UIViewController

@property (strong, nonatomic) CLFArticleFrame              *articleFrame;
@property (weak, nonatomic)   id<CLFArticleDetailDelegate> delegate;

@end
