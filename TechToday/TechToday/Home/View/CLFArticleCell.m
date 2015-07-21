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
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CLFRemindButtonBackgroundColor;
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
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = CLFArticleTitleFont;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *sourceLabel = [[UILabel alloc] init];
        sourceLabel.font = CLFArticleOtherFont;
        [self.contentView addSubview:sourceLabel];
        self.sourceLabel = sourceLabel;
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = CLFArticleOtherFont;
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        UILabel *pageViewsLabel = [[UILabel alloc] init];
        pageViewsLabel.textAlignment = NSTextAlignmentRight;
        pageViewsLabel.font = CLFArticleOtherFont;
        [self.contentView addSubview:pageViewsLabel];
        self.pageViewsLabel = pageViewsLabel;
    }
    return self;
}

/**
 *  设置 cell 中的数据及 frame 及一些样式
 */
- (void)setArticleFrame:(CLFArticleFrame *)articleFrame {
    _articleFrame = articleFrame;
    
    CLFArticle *article =  articleFrame.article;
    
    if (article.isRead) {
        self.titleLabel.textColor = CLFNightTitleColor;
        self.titleLabel.nightTextColor = CLFNightTextReadColor;
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.nightTextColor = CLFNightTextColor;
    }
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.nightBackgroundColor = [UIColor clearColor];
    self.titleLabel.font = CLFArticleTitleFont;
    self.titleLabel.numberOfLines = 0;
    
    self.sourceLabel.textColor = [UIColor lightGrayColor];
    self.sourceLabel.nightTextColor = CLFNightTextColor;
    self.sourceLabel.backgroundColor = [UIColor clearColor];
    self.sourceLabel.nightBackgroundColor = [UIColor clearColor];
    self.sourceLabel.font = CLFArticleOtherFont;
    
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.nightTextColor = CLFNightTextColor;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.nightBackgroundColor = [UIColor clearColor];
    self.dateLabel.font = CLFArticleOtherFont;
    
    self.pageViewsLabel.textColor = [UIColor lightGrayColor];
    self.pageViewsLabel.nightTextColor = CLFNightTextColor;
    self.pageViewsLabel.backgroundColor = [UIColor clearColor];
    self.pageViewsLabel.nightBackgroundColor = [UIColor clearColor];

    // 由于自己做了本地存储, SDWebImage只需要做内存缓存即可
    NSString *imageLocation = [NSString stringWithFormat:@"http://jinri.info/%@", article.img];
    [self.articleImage sd_setImageWithURL:[NSURL URLWithString:imageLocation] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:SDWebImageCacheMemoryOnly];

    self.articleImage.frame = articleFrame.imageViewFrame;
    
    NSString *titleText = article.title;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleText];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleText.length)];
    self.titleLabel.attributedText = attrString;
    self.titleLabel.frame = articleFrame.titleLabelFrame;
    
    self.sourceLabel.text = article.source;
    self.sourceLabel.frame = articleFrame.sourceLabelFrame;
    
    self.dateLabel.text = article.date;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.frame = articleFrame.dateLabelFrame;
    
    self.pageViewsLabel.text = article.pageViews;
    self.pageViewsLabel.frame = articleFrame.pageViewsLabelFrame;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = CLFArticleCellToBorderMargin;
    frame.origin.y += CLFArticleCellToBorderMargin;
    frame.size.width -= 2 * CLFArticleCellToBorderMargin;
    frame.size.height -= CLFArticleCellToBorderMargin;
    [super setFrame:frame];
}

@end
