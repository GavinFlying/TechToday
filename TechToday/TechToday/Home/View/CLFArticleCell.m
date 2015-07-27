//
//  CLFArticleCell.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticleCell.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"
#import "CLFCommonHeader.h"
#import "UIImageView+WebCache.h"
#import "NSString+CLF.h"
#import "UILabel+CLF.h"

@interface CLFArticleCell ()

@property (weak, nonatomic) UIImageView *articleImage;
@property (weak, nonatomic) UILabel     *titleLabel;
@property (weak, nonatomic) UILabel     *sourceLabel;
@property (weak, nonatomic) UILabel     *dateLabel;
@property (weak, nonatomic) UILabel     *pageViewsLabel;

@end

/**
 *  普通模式 ArticleCell
 */
@implementation CLFArticleCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"article";
    CLFArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[CLFArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

/**
 *  添加 cell 中的子控件
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *articleImage = [[UIImageView alloc] init];
        articleImage.contentMode = UIViewContentModeScaleAspectFill;
        articleImage.clipsToBounds = YES;
        [self.contentView addSubview:articleImage];
        self.articleImage = articleImage;
    }
    return self;
}

/**
 *  设置 cell 中的数据及 frame 及一些样式
 */
- (void)setArticleFrame:(CLFArticleFrame *)articleFrame {
    [super setArticleFrame:articleFrame];
    
    CLFArticle *article =  articleFrame.article;

    // 由于自己做了本地存储, SDWebImage只需要做内存缓存即可
    NSString *imageLocation = [NSString stringWithFormat:@"http://jinri.info/%@", article.img];
    [self.articleImage sd_setImageWithURL:[NSURL URLWithString:imageLocation] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageCacheMemoryOnly];

    self.articleImage.frame = articleFrame.imageViewFrame;
    self.titleLabel.frame = articleFrame.titleLabelFrame;
    self.sourceLabel.frame = articleFrame.sourceLabelFrame;
    self.dateLabel.frame = articleFrame.dateLabelFrame;
    self.pageViewsLabel.frame = articleFrame.pageViewsLabelFrame;
}

@end
