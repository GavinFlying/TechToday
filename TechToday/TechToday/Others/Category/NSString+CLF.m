//
//  NSString+CLF.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "NSString+CLF.h"


@implementation NSString (CLF)

+ (CGSize)sizeOfText:(NSString *)text maxSize:(CGSize)maxSize font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 111;
    paragraphStyle.lineHeightMultiple = 1.3;
//    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
