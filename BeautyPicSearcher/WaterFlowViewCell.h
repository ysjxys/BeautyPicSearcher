//
//  WaterFlowViewCell.h
//  WaterFlowStyle
//
//  Created by siqin.ljp on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>


/* ************************************************** */
@class WFIndexPath;
@class WaterFlowView;

@interface WaterFlowViewCell : UIView

@property (nonatomic, strong) NSString      *reuseIdentifier;
@property (nonatomic, strong) WFIndexPath   *indexPath;

@property (nonatomic, strong) UIImageView   *imageView;

-(id)initWithIdentifier:(NSString *)identifier waterFlowView:(WaterFlowView *)waterFlowView wfIndexPath:(WFIndexPath *)wfIndexPath;

@end


/* ************************************************** */
@interface WFIndexPath : NSObject

+ (WFIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;

@end