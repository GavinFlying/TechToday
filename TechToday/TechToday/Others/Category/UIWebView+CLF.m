//
//  UIWebView+CLF.m
//  TechToday
//
//  Created by CaiGavin on 7/23/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "UIWebView+CLF.h"

@implementation UIWebView (CLF)

- (UIImage *)fullWebpageScreenshot {
    CGRect initialFrame = self.frame;
    CGPoint initialOffset = self.scrollView.contentOffset;
    CGSize initialSize = self.scrollView.contentSize;
    CGRect initialScrollViewFrame = self.scrollView.frame;
    
    CGFloat width = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] floatValue];
    CGFloat height = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    CGSize fullpageSize = CGSizeMake(width, height + 215);
    
    self.frame = CGRectMake(0, 0, fullpageSize.width, fullpageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(fullpageSize, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];

    // 填充原来状态栏的位置的颜色
    CGContextSetRGBFillColor(context, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
    CGContextSetRGBStrokeColor(context, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, fullpageSize.width, 21));
    
    // 为底部说明开辟空间
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, fullpageSize.height - 60, fullpageSize.width, 60));
    
    // 底部说明
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    NSString *descriptionText1 = @"更多精彩请访问 http://jinri.info";
    NSString *descriptionText2 = @"或前往 App Store 下载 TechToday";
    
    UIFont *font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    [descriptionText1 drawInRect:CGRectMake(0, fullpageSize.height - 40, fullpageSize.width, 20) withAttributes:attrs];
    [descriptionText2 drawInRect:CGRectMake(0, fullpageSize.height - 20, fullpageSize.width, 20) withAttributes:attrs];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.frame = initialFrame;
    self.scrollView.contentOffset = initialOffset;
    self.scrollView.contentSize = initialSize;
    self.scrollView.frame = initialScrollViewFrame;
    return screenshot;
}

@end
