//
//  FavImgsCollectionViewCell.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/23.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "FavImgsCollectionViewCell.h"

@interface FavImgsCollectionViewCell()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation FavImgsCollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    FavImgsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdenifier forIndexPath:indexPath];
    [cell initViews];
    return cell;
}

- (void)initViews{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imgView.backgroundColor = [UIColor blackColor];
        _imgView.clipsToBounds = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imgView];
    }
}

- (void)setImg:(UIImage *)img{
    _imgView.image = img;
}

@end
