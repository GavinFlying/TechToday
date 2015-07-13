//
//  CLFWebView.h
//  TechToday
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFArticle;
@interface CLFWebView : UIWebView

// article would show in this webView
@property (strong, nonatomic) CLFArticle  *article;
// height of buttomView
@property (assign, nonatomic) CGFloat     buttomHeight;
// height of titleView
@property (assign, nonatomic) CGFloat     titleHeight;

@end
