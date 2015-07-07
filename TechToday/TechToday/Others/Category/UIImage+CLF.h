//
//  UIImage+CLF.h
//  jinri
//
//  Created by CaiGavin on 7/3/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CLF)

+ (UIImage *)resizeImageWithName:(NSString *)name;
+ (UIImage *)resizeImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

@end
