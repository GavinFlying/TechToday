//
//  UIImage+CLF.h
//  TechToday
//
//  Created by CaiGavin on 7/3/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CLF)

+ (UIImage *)resizeImageWithName:(NSString *)name;
+ (UIImage *)resizeImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

@end
