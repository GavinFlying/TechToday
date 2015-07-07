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
#import "CLFReachability.h"

@interface CLFArticleNoImageCell ()

@property (weak, nonatomic) UILabel     *titleLabel;
@property (weak, nonatomic) UILabel     *sourceLabel;
@property (weak, nonatomic) UILabel     *dateLabel;
@property (weak, nonatomic) UILabel     *pageViewsLabel;

@end

@implementation CLFArticleNoImageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"articleNoImage";
    CLFArticleNoImageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[CLFArticleNoImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        cell.layer.shadowColor = [[UIColor blackColor] CGColor];
//        cell.layer.shadowOffset = CGSizeMake(1, 1);
//        cell.layer.shadowOpacity = 0.2;
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
//        titleLabel.textColor = [UIColor blackColor];
//        titleLabel.nightTextColor = CLFNightTextColor;
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
    
    NSString *titleText = article.title;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleText];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, titleText.length)];
    self.titleLabel.attributedText = attrString;
    self.titleLabel.frame = articleFrame.noImageViewTitleLabelFrame;
    
    self.sourceLabel.text = article.source;
    self.sourceLabel.frame = articleFrame.noImageViewSourceLabelFrame;
    
    self.dateLabel.text = article.date;
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
