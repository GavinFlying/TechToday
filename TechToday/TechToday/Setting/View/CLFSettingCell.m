//
//  CLFSettingCell.m
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFSettingCell.h"

@interface CLFSettingCell ()

@property (weak, nonatomic) UIImageView *iconImageView;
@property (weak, nonatomic) UILabel     *titleLabel;

@end

@implementation CLFSettingCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"setting";
    CLFSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[CLFSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.nightBackgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *iconImage = [[UIImageView alloc] init];
        iconImage.contentMode = UIViewContentModeScaleAspectFill;
        iconImage.clipsToBounds = YES;
        iconImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:iconImage];
        self.iconImageView = iconImage;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.nightBackgroundColor = [UIColor clearColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.nightTextColor = [UIColor whiteColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = CLFArticleTitleFont;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

/**
 *  setup titleText of cell
 */
- (NSString *)titleText {
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)titleText {
    CGFloat titleW = 100;
    CGFloat titleH = 25;
    CGFloat titleX = CGRectGetMaxX(self.iconImageView.frame) + CLFArticleCellBorder;
    CGFloat titleY = self.iconImageView.frame.origin.y;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    self.titleLabel.text = titleText;
}

/**
 *  setup iconImage of cell
 */
- (UIImage *)iconImage {
    return self.iconImageView.image;
}

- (void)setIconImage:(UIImage *)iconImage {
    CGFloat iconW = 30;
    CGFloat iconH = 25;
    CGFloat iconX = 50;
    CGFloat iconY = (CLFSettingCellHeight - iconH) * 0.5;
    self.iconImageView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    self.iconImageView.image = iconImage;
}

/**
 *  设置cell被点击后的效果
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self highlightCell:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self highlightCell:highlighted];
}

- (void)highlightCell:(BOOL)highlight {
    UIColor *tintColor = [UIColor whiteColor];
    if (highlight) {
        tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    
    self.titleLabel.textColor = tintColor;
}

@end
