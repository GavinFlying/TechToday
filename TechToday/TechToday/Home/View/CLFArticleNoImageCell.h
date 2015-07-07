//
//  CLFArticleNoImageCell.h
//  jinri
//
//  Created by CaiGavin on 7/6/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFArticleFrame;
@interface CLFArticleNoImageCell : UITableViewCell

@property (strong, nonatomic) CLFArticleFrame *articleFrame;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
