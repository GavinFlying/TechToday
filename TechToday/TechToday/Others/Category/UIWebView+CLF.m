//
//  UIWebView+CLF.m
//  TechToday
//
//  Created by CaiGavin on 7/23/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "UIWebView+CLF.h"

@implementation UIWebView (CLF)

- (UIImage *)fullWebpageScreenshot3 {
    UIImage* viewImage = nil;
    
    CGSize screenshotSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 275);
    UIGraphicsBeginImageContextWithOptions(screenshotSize, NO, 0.0f);
    {
        CGPoint savedContentOffset = self.scrollView.contentOffset;
        CGRect savedFrame = self.scrollView.frame;
        CGRect initialFrame = self.frame;
        
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        //        self.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height + 120);
        self.scrollView.layer.bounds = CGRectMake(0, -155, self.scrollView.contentSize.width, self.scrollView.contentSize.height + 275);
        //        self.scrollView.layer.frame = CGRectMake(0, -155, self.scrollView.contentSize.width, self.scrollView.contentSize.height + 275);
        NSLog(@"shot layerFrame %@", NSStringFromCGRect(self.scrollView.layer.frame));
        [self.scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        self.scrollView.contentOffset = savedContentOffset;
        self.scrollView.frame = savedFrame;
        self.frame = initialFrame;
    }
    UIGraphicsEndImageContext();
    
//    return titleShot;
        return viewImage;
}



- (UIImage *)fullWebpageScreenshot2 {
    
    // contentShot
    UIImage *contentShot = nil;
    CGSize screenshotSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    UIGraphicsBeginImageContextWithOptions(screenshotSize, NO, 0.0f);
    CGPoint savedContentOffset = self.scrollView.contentOffset;
    CGRect savedFrame = self.scrollView.frame;
    
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    CGContextRef contentContext = UIGraphicsGetCurrentContext();
    
    [self.scrollView.layer renderInContext:contentContext];
    contentShot = UIGraphicsGetImageFromCurrentImageContext();
    
    self.scrollView.contentOffset = savedContentOffset;
    self.scrollView.frame = savedFrame;
    UIGraphicsEndImageContext();
    
    // titleShot
    CGSize titleViewSize = CGSizeMake(CGRectGetWidth(self.frame), 155);
    UIGraphicsBeginImageContextWithOptions(titleViewSize, NO, 0.0f);
    
    CGContextRef titleContext = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:titleContext];
    
    CGContextSetRGBFillColor(titleContext, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
    CGContextSetRGBStrokeColor(titleContext, 0 / 255.0, 151 / 255.0, 255 / 255.0, 1);
    CGContextFillRect(titleContext, CGRectMake(0, 0, titleViewSize.width, 21));

    UIImage *titleShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // adsImage
    CGSize adsSize = CGSizeMake(CGRectGetWidth(self.frame), 90);
    UIGraphicsBeginImageContextWithOptions(adsSize, NO, 0.0f);
    
    CGContextRef adsContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(adsContext, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(adsContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(adsContext, CGRectMake(0, 0, adsSize.width, adsSize.height));
    
    CGContextSetRGBStrokeColor(adsContext, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(adsContext, 0.0, 0.0, 0.0, 1.0);
    NSString *descriptionText1 = @"更多精彩请访问 http://jinri.info";
    NSString *descriptionText2 = @"或前往 App Store 下载 TechToday";

    UIFont *font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    [descriptionText1 drawInRect:CGRectMake(0, adsSize.height - 40, adsSize.width, 20) withAttributes:attrs];
    [descriptionText2 drawInRect:CGRectMake(0, adsSize.height - 20, adsSize.width, 20) withAttributes:attrs];
    
    UIImage *adsShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImage *mergedImage = [self mergeImage1:titleShot withImage2:contentShot];
    return [self mergeImage1:adsShot withImage2:mergedImage];
//    return mergedImage;
//    return adsShot;
}

- (UIImage *)mergeImage1:(UIImage *)image1 withImage2:(UIImage *)image2 {
    CGSize imageSize= CGSizeMake(image1.size.width, image1.size.height + image2.size.height);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0f);
//    UIGraphicsBeginImageContext(imageSize);
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, image1.size.height, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (UIImage *)fullWebpageScreenshot {
    CGRect initialFrame = self.frame;
    CGPoint initialOffset = self.scrollView.contentOffset;
    CGSize initialSize = self.scrollView.contentSize;
    CGRect initialScrollViewFrame = self.scrollView.frame;
    
    CGFloat width = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] floatValue];
    CGFloat height = [[self stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    CGSize fullpageSize = CGSizeMake(width, height + 245);
    
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
    CGContextFillRect(context, CGRectMake(0, fullpageSize.height - 90, fullpageSize.width, 90));
    
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
