//
//  YSJAFNetWorkingHelper.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/5.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "YSJAFNetWorkingHelper.h"


@implementation YSJAFNetWorkingHelper

+ (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(CompleteHandle)success fail:(ErrorHandle)fail{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/javascript", @"text/json",@"text/plain", nil];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if (fail) {
            fail(error.localizedDescription);
        }
    }];
}

+ (void)getJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(CompleteHandle)success fail:(ErrorHandle)fail{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/javascript", @"text/json",@"text/plain", nil];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if (fail) {
            fail(error.localizedDescription);
        }
    }];
}

@end
