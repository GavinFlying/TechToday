//
//  UILabel+CLF.m
//  TechToday
//
//  Created by CaiGavin on 7/23/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "UILabel+CLF.h"
#import "DKNightVersion.h"
#import "CLFCommonHeader.h"

@implementation UILabel (CLF)

+ (UILabel *)labelWithAttributesFromUILabel:(UILabel *)label {
    label.textColor = [UIColor lightGrayColor];
    label.nightTextColor = CLFNightTextColor;
    label.backgroundColor = [UIColor clearColor];
    label.nightBackgroundColor = [UIColor clearColor];
    label.font = CLFArticleOtherFont;
    return label;
}


@end
