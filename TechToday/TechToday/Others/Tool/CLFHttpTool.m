//
//  CLFHttpTool.m
//  TechToday
//
//  Created by CaiGavin on 6/27/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFHttpTool.h"
#import "AFNetworking.h"

@implementation CLFHttpTool

+ (void)getWithURL:(NSString *)URL params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
