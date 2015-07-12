//
//  CLFArticleTool.h
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFArticleTool : NSObject

+ (void)articleWithURLAppendage:(NSString *)URLAppendage params:(NSDictionary *)params success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure;

@end
