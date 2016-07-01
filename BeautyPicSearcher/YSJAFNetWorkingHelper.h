//
//  YSJAFNetWorkingHelper.h
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/5.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef void(^CompleteHandle)(id response);
typedef void(^ErrorHandle)(NSString *errorMsg);

@interface YSJAFNetWorkingHelper : NSObject

+ (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(CompleteHandle)success fail:(ErrorHandle)fail;

+ (void)getJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(CompleteHandle)success fail:(ErrorHandle)fail;
@end
