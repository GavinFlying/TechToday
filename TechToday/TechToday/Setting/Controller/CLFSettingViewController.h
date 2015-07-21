//
//  CLFSettingViewController.h
//  TechToday
//
//  Created by CaiGavin on 7/5/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol CLFSettingViewControllerDelegate <NSObject>

@optional
- (void)reloadViewData;
- (void)resetBarBackgroundImage;
- (void)noImageModeChanged;

@end

@interface CLFSettingViewController : UITableViewController 

@property (weak, nonatomic) id<CLFSettingViewControllerDelegate> delegate;

@end
