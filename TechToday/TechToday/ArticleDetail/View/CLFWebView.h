//
//  CLFWebView.h
//  jinri
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFArticle;
@interface CLFWebView : UIWebView

@property (strong, nonatomic) CLFArticle  *article;
@property (assign, nonatomic) CGFloat     buttomHeight;
@property (assign, nonatomic) CGFloat     titleHeight;

@end
