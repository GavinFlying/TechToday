//
//  CLFArticleCell.h
//  TechToday
//
//  Created by CaiGavin on 6/24/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLFArticleNoImageCell.h"

@class CLFArticleFrame;
@interface CLFArticleCell : CLFArticleNoImageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
