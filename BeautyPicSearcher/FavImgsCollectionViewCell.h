//
//  FavImgsCollectionViewCell.h
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/23.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CollectionViewCellIdenifier @"CollectionViewCellIdenifier"
@interface FavImgsCollectionViewCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)setImg:(UIImage *)img;
@end
