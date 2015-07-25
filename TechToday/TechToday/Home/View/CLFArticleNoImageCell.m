//
//  CLFArticleNoImageCell.m
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFArticleNoImageCell.h"
#import "CLFArticleFrame.h"
#import "CLFArticle.h"
#import "CLFCommonHeader.h"
#import "UIImageView+WebCache.h"
#import "NSString+CLF.h"
#import "UILabel+CLF.h"

@interface CLFArticleNoImageCell ()

@property (weak, nonatomic) UILabel     *titleLabel;
@property (weak, nonatomic) UILabel     *sourceLabel;
@property (weak, nonatomic) UILabel     *dateLabel;
@property (weak, nonatomic) UILabel     *pageViewsLabel;

@end

/**
 *  无图模式 ArticleCell
 */
@implementation CLFArticleNoImageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"articleNoImage";
    CLFArticleNoImageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[CLFArticleNoImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CLFRemindButtonBackgroundColor;
    }
    return cell;
}

/**
 *  添加Cell中的子控件
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *sourceLabel = [[UILabel alloc] init];
        [self.contentView addSubview:sourceLabel];
        self.sourceLabel = sourceLabel;
        
        UILabel *dateLabel = [[UILabel alloc] init];
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
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.nightTextColor = CLFNightTextReadColor;
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.nightTextColor = CLFNightTextColor;
    }
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.nightBackgroundColor = [UIColor clearColor];
    self.titleLabel.font = CLFArticleTitleFont;
    self.titleLabel.numberOfLines = 0;
    
    self.sourceLabel = [UILabel labelWithAttributesFromUILabel:self.sourceLabel];
    self.dateLabel = [UILabel labelWithAttributesFromUILabel:self.dateLabel];
    self.pageViewsLabel = [UILabel labelWithAttributesFromUILabel:self.pageViewsLabel];
    
    self.titleLabel.attributedText = [NSString NSAttributedStringFromNSString:article.title];
    self.titleLabel.frame = articleFrame.noImageViewTitleLabelFrame;
    self.sourceLabel.text = article.source;
    self.sourceLabel.frame = articleFrame.noImageViewSourceLabelFrame;
    
    self.dateLabel.text = article.date;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.frame = articleFrame.noImageViewDateLabelFrame;
    
    self.pageViewsLabel.text = article.pageViews;
    self.pageViewsLabel.frame = articleFrame.noImageViewPageViewsLabelFrame;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = CLFArticleCellToBorderMargin;
    frame.origin.y += CLFArticleCellToBorderMargin;
    frame.size.width -= 2 * CLFArticleCellToBorderMargin;
    frame.size.height -= CLFArticleCellToBorderMargin;
    [super setFrame:frame];
}

@end
