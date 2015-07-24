//
//  FIR.h
//  FIRSDK
//
//  Created by Travis on 14-9-28.
//  Copyright (c) 2014年 Fly It Remotely International Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FIRConstants.h"


@interface FIR:NSObject

/* 开始捕获崩溃
 @param crashKey 在 BugHD.com 获得的应用 generalKey
 */
+(void) handleCrashWithKey:(NSString*)crashKey;

/* 设置自定义参数
 @param value NSString型value
 @param key   NSString型key
 
 @Discussion 自定义参数,每次crash发送
 */
+(void)setCustomizeValue:(NSString *)value forKey:(NSString *)key;

/* 根据key删除参数
 @param key   NSString型key
 */
+(void)removeCustomizeValueForKey:(NSString *)key;

/* 清空自定义参数
 */
+(void)removeCustomizeValue;


/** 检查AppStore版本
 @param callback 回调
 
 回调时的2个参数: `NSDictionary *result` 和 `NSError *error`:
 result:
 "updateURL":更新地址
 "version":版本号
 "changelog":更新日志
 */
+(void)checkForUpdateInAppStore:(FIResultBlock)callback;

/** 检查FIR.im版本
 @param token FIR.im 上的用户Token,Token为空则根据appid搜索公测App信息
 @param callback 回调
 @warning 不要用于线上版本
 
 回调时的2个参数: `NSDictionary *result` 和 `NSError *error`:
 result:
 "updateURL":更新地址
 "version":版本号
 "changelog":更新日志
 "build":build版本号,
 */
+(void)checkForUpdateInFIR:(FIResultBlock)callback token:(NSString *)token;

@end

