//
//  BeautyPic.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/6.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "BeautyPic.h"

@implementation BeautyPic

+ (instancetype)picWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.desc = dic[@"desc"];
        self.imgUrl = dic[@"image_url"];
        self.imgWidth = [dic[@"image_width"] floatValue];
        self.imgHeight = [dic[@"image_height"] floatValue];
    }
    return self;
}
@end
