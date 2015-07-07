//
//  CLFSettingCell.m
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFSettingCell.h"
#import "CLFCommonHeader.h"

@interface CLFSettingCell ()

@property (weak, nonatomic) UIImageView *iconImageView;
@property (weak, nonatomic) UILabel *titleLabel;

@end

@implementation CLFSettingCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"setting";
    CLFSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[CLFSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (NSString *)titleText {
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)titleText {
    self.titleLabel.frame = CGRectMake(110, 16, 100, 40);
    self.titleLabel.text = titleText;
}

- (UIImage *)iconImage {
    return self.iconImageView.image;
}

- (void)setIconImage:(UIImage *)iconImage {
    self.iconImageView.frame = CGRectMake(60, 16, 30, 30);
    self.iconImageView.image = iconImage;
}

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
    if(highlight) {
        tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    
    self.titleLabel.textColor = tintColor;
    self.iconImageView.tintColor = tintColor;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *iconImage = [[UIImageView alloc] init];
        iconImage.contentMode = UIViewContentModeScaleAspectFill;
        iconImage.clipsToBounds = YES;
        [self.contentView addSubview:iconImage];
        self.iconImageView = iconImage;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = CLFArticleTitleFont;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}



@end
