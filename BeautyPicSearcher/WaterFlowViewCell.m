//
//  WaterFlowViewCell.m
//  WaterFlowStyle
//
//  Created by siqin.ljp on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import "WaterFlowViewCell.h"
#import "WaterFlowView.h"

@interface WaterFlowViewCell()
@property (nonatomic, strong) WaterFlowView *waterFlowView;
@end

@implementation WaterFlowViewCell

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize indexPath = _indexPath;

@synthesize imageView = _imageView;

-(id)initWithIdentifier:(NSString *)identifier waterFlowView:(WaterFlowView *)waterFlowView wfIndexPath:(WFIndexPath *)wfIndexPath{
    self = [super init];
    if (self) {
        self.reuseIdentifier = identifier;
        self.clipsToBounds = YES;
        self.waterFlowView = waterFlowView;
        self.indexPath = wfIndexPath;
        
        UITapGestureRecognizer *tapGecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedCell)];
        [self addGestureRecognizer:tapGecognize];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)selectedCell{
    if ([self.waterFlowView.waterFlowDelegate respondsToSelector:@selector(waterFlowView:didSelectRowAtIndexPath:)]) {
        [self.waterFlowView.waterFlowDelegate waterFlowView:self.waterFlowView didSelectRowAtIndexPath:self.indexPath];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    if (!self.imageView.superview) {
        CGRect rect = self.frame;
        rect.origin.x = rect.origin.y = 0.0f;
        self.imageView.frame = rect;
        [self addSubview:self.imageView];
    }
}

@end


/* ************************************************** */
@implementation WFIndexPath

@synthesize column = _column;
@synthesize row = _row;

+ (WFIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column
{
    WFIndexPath *indexPath = [[WFIndexPath alloc] init];
    
    indexPath.column = column;
    indexPath.row = row;
    
    return indexPath;
}

@end
