//
//  MBProgressHUD+YSJ.m
//  YSJFileManager
//
//  Created by ysj on 16/3/29.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "MBProgressHUD+YSJ.h"

@implementation MBProgressHUD (YSJ)

+ (void)showMBPMsg:(NSString *)msg onView:(UIView *)view delay:(CGFloat)time{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:time];
}

@end
