//
//  CLFCacheClearTool.m
//  TechToday
//
//  Created by CaiGavin on 7/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFCacheClearTool.h"

@implementation CLFCacheClearTool

+ (CGFloat)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSInteger size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size / 1024.0 / 1024.0;
    }
    return 0;
}

+ (CGFloat)DirectorySizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    CGFloat directorySize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *containedFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in containedFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            directorySize += [self fileSizeAtPath:absolutePath];
        }
        return directorySize;
    }
    return 0.0;
}

+ (void)clearCacheAtPath:(NSString *)path completion:(completionBlock)completion {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *containedFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in containedFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    completion();
}

@end
