//
//  CLFSettingCell.h
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLFCommonHeader.h"

@interface CLFSettingCell : UITableViewCell

@property (copy, nonatomic)   NSString *titleText;
@property (strong, nonatomic) UIImage  *iconImage;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
