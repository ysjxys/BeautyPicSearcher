//
//  BeautyPic.h
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/6.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeautyPic : NSObject

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;
@property (nonatomic, assign) CGFloat picDegreeWidth;
@property (nonatomic, assign) CGFloat picDegreeHeight;

+ (instancetype)picWithDic:(NSDictionary *)dic;
- (instancetype)initWithDic:(NSDictionary *)dic;
@end
