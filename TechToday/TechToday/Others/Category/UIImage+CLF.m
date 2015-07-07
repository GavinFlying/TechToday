//
//  UIImage+CLF.m
//  TechToday
//
//  Created by CaiGavin on 7/3/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "UIImage+CLF.h"

@implementation UIImage (CLF)

+ (UIImage *)resizeImageWithName:(NSString *)name {
    return [UIImage resizeImageWithName:name left:0.5 top:0.5];
}

+ (UIImage *)resizeImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top {
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}

@end
