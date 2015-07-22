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
    paragraphStyle.lineHeightMultiple = 1.3;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

+ (NSAttributedString *)NSAttributedStringFromNSString:(NSString *)string {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
    return attrString;
}

@end
