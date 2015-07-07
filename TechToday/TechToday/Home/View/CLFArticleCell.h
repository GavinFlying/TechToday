//
//  CLFArticleCell.h
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFArticleFrame;
@interface CLFArticleCell : UITableViewCell

@property (strong, nonatomic) CLFArticleFrame *articleFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
