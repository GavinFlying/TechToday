//
//  CLFCacheClearTool.h
//  TechToday
//
//  Created by CaiGavin on 7/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completionBlock) ();

@interface CLFCacheClearTool : NSObject

+ (CGFloat)fileSizeAtPath:(NSString *)path;
+ (CGFloat)DirectorySizeAtPath:(NSString *)path;
+ (void)clearCacheAtPath:(NSString *)path completion:(completionBlock)completion;

@end
