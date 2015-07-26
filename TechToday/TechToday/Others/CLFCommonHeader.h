//
//  CLFCommonHeader.h
//  TechToday
//
//  Created by CaiGavin on 6/25/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#ifndef TechToday_CLFCommonHeader_h
#define TechToday_CLFCommonHeader_h

#import "DKNightVersion.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"

#define CLFArticleCellBorder             (16)
#define CLFArticleCellInnerBorder        (7)

#define CLFRemindButtonBackgroundColor   [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:255 / 255.0 alpha:1.0]
#define CLFHomeViewBackgroundColor       [UIColor colorWithRed:226 / 255.0 green:226 / 255.0 blue:236 / 255.0 alpha:1.0]

#define CLFArticleTitleViewHeight        (135)
#define CLFArticleDetailButtomViewHeight (120)

#define CLFArticleTitleFont              [UIFont fontWithName:@"SourceHanSansCN-Normal" size:21]
#define CLFArticleOtherFont              [UIFont fontWithName:@"SourceHanSansCN-Light" size:13]
#define CLFArticleDetailSourceFont       [UIFont fontWithName:@"SourceHanSansCN-Light" size:15]

#define CLFUIMainColor                   [UIColor colorWithRed:0 / 255.0 green:151 / 255.0 blue:255 / 255.0 alpha:100]

#define CLFArticleCellToBorderMargin     (7)

#define CLFNightBarColor                 [UIColor colorWithRed:20 / 255.0 green:20 / 255.0 blue:20 / 255.0 alpha:100]
#define CLFNightCellColor                [UIColor colorWithRed:30 / 255.0 green:30 / 255.0 blue:30 / 255.0 alpha:100]
#define CLFNightViewColor                [UIColor colorWithRed:25 / 255.0 green:25 / 255.0 blue:25 / 255.0 alpha:100]

#define CLFNightTextColor                [UIColor colorWithRed:65 / 255.0 green:65 / 255.0 blue:65 / 255.0 alpha:100]
#define CLFNightTextReadColor            [UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:100]
#define CLFNightTitleColor               [UIColor colorWithRed:80 / 255.0 green:80 / 255.0 blue:80 / 255.0 alpha:100]

#define CLFSettingCellHeight             (60)

#define CLFScreenW                       [UIScreen mainScreen].bounds.size.width
#define CLFScreenH                       [UIScreen mainScreen].bounds.size.height
#define CLFScreenWScale                  ([UIScreen mainScreen].bounds.size.width / (375.0f))

#endif
