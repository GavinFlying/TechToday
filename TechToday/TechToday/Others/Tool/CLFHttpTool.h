//
//  CLFHttpTool.h
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFHttpTool : NSObject

+ (void)getWithURL:(NSString *)URL params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end
