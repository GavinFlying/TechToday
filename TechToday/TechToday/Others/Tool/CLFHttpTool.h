//
//  CLFHttpTool.h
//  jinri
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFHttpTool : NSObject

+ (void)getWithURL:(NSString *)URL params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end
