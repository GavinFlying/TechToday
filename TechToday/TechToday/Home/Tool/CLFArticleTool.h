//
//  CLFArticleTool.h
//  jinri
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFArticleTool : NSObject

+ (void)articleWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
