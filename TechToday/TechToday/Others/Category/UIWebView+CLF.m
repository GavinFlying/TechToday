//
//  UIWebView+CLF.m
//  TechToday
//
//  Created by CaiGavin on 7/23/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "UIWebView+CLF.h"
#import "DKNightVersion.h"
#import "CLFCommonHeader.h"

@implementation UIWebView (CLF)

- (UIImage *)fullWebpageScreenshot {
    CGRect initialFrame = self.frame;
    // scrollView 的 Offset 和 Size 也要设置，否则在点击分享按钮后， 底部会多出来一块
    CGPoint initialContentOffset = self.scrollView.contentOffset;
    CGSize initialContentSize = self.scrollView.contentSize;
    
    CGFloat width = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] floatValue];
    CGFloat height = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    CGSize fullpageSize = CGSizeMake(width, height + 275);
    
    self.frame = CGRectMake(0, 0, fullpageSize.width, fullpageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(fullpageSize, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];

    // 填充原来状态栏的位置的颜色
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        CGContextSetRGBFillColor(context, 20 / 255.0, 20 / 255.0, 20 / 255.0, 1);
        CGContextSetRGBStrokeColor(context, 20 / 255.0, 20 / 255.0, 20 / 255.0, 1);
    } else {
        CGContextSetRGBFillColor(context, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
        CGContextSetRGBStrokeColor(context, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
    }
    CGContextFillRect(context, CGRectMake(0, 0, fullpageSize.width, 21));
    
    // 为底部说明开辟空间
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        CGContextSetRGBFillColor(context, 25 / 255.0, 25 / 255.0, 25 / 255.0, 1);
        CGContextSetRGBStrokeColor(context, 25 / 255.0, 25 / 255.0, 25 / 255.0, 1);
    } else {
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    }
    CGContextFillRect(context, CGRectMake(0, fullpageSize.height - 120, fullpageSize.width, 120));
    
    // 底部说明
    NSString *descriptionText1 = @"更多精彩请访问 http://jinri.info";
    NSString *descriptionText2 = @"或前往 App Store 下载 TechToday";
    
    UIFont *font = [UIFont systemFontOfSize:13];
    UIColor *descriptionColor = nil;
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        descriptionColor = CLFNightTextColor;
    } else {
        descriptionColor = [UIColor blackColor];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font, NSForegroundColorAttributeName : descriptionColor};
    [descriptionText1 drawInRect:CGRectMake(0, fullpageSize.height - 70, fullpageSize.width, 20) withAttributes:attrs];
    [descriptionText2 drawInRect:CGRectMake(0, fullpageSize.height - 50, fullpageSize.width, 20) withAttributes:attrs];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.frame = initialFrame;
    self.scrollView.contentOffset = initialContentOffset;
    self.scrollView.contentSize = initialContentSize;
    return screenshot;
}

@end
