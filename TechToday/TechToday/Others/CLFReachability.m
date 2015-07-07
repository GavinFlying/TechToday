//
//  CLFReachability.m
//  TechToday
//
//  Created by CaiGavin on 6/28/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFReachability.h"

@implementation CLFReachability

+ (id)allocWithZone:(struct _NSZone *)zone {
    static CLFReachability *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)sharedCLFReachability {
    return [[self alloc] init];
}

@end
