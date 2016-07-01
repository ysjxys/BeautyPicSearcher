//
//  PicDetailViewController.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/13.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "PicDetailViewController.h"
#import "BeautyPic.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+YSJ.h"
#import "NSDate+YSJ.h"

@interface PicDetailViewController()<UIActionSheetDelegate>
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end
@implementation PicDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initView];
}

- (void)initView{
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor blackColor];
    self.imgView = imageView;
    [self.view addSubview:imageView];
    [self initConstraint];
    
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册",@"收藏", nil];
    self.actionSheet = actionSheet;
    
    UITapGestureRecognizer *tapRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self.imgView addGestureRecognizer:tapRecognize];
    
    UILongPressGestureRecognizer *longPressRecognize = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView)];
    [self.imgView addGestureRecognizer:longPressRecognize];
}

- (void)initConstraint{
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *imgVCenterX = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgVCenterY = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgVWidth = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgVHeight = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    imgVCenterX.active = YES;
    imgVCenterY.active = YES;
    imgVWidth.active = YES;
    imgVHeight.active = YES;
}

- (void)tapView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)longPressView{
    [self.actionSheet showInView:self.view];
}

- (void)showPic{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:self.pic.imgUrl];
    NSLog(@"%@",url);
    UIImage *placeholder = [UIImage imageNamed:@"placeholder-image"];
    [self.imgView sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [hud removeFromSuperview];
    }];
}

- (BOOL)canCreateFolder:(NSString *)folderPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExisted = [fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory];
    if (isExisted && isDirectory) {
        return NO;
    }
    return YES;
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [MBProgressHUD showMBPMsg:@"保存到相册失败" onView:self.imgView delay:0.8];
        YSJLog(@"Error: %@",error);
    }else{
        [MBProgressHUD showMBPMsg:@"保存到相册成功" onView:self.imgView delay:0.8];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {//保存到相册
        UIImageWriteToSavedPhotosAlbum(self.imgView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }else if (buttonIndex == 1){//收藏
        [actionSheet setHidden:YES];
        //不存在favImgs文件夹  则创建之
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.imgView animated:YES];
        NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        homePath = [homePath stringByAppendingPathComponent:@"favImgs"];
        if ([self canCreateFolder:homePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //保存图片到文件夹
        NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pic.imgUrl]];
        NSString *fileName;
        NSString *lastComponent = [self.pic.imgUrl lastPathComponent];
        if ([lastComponent containsString:@".png"] || [lastComponent containsString:@".PNG"]) {
            fileName = [NSString stringWithFormat:@"%@%@",[[NSDate date] dateToStringWithFormatterStr:@"yyyyMMddHHmmss"],@".png"];
        }else{
            fileName = [NSString stringWithFormat:@"%@%@",[[NSDate date] dateToStringWithFormatterStr:@"yyyyMMddHHmmss"],@".jpg"];
        }
        if ([urlData writeToFile:[homePath stringByAppendingPathComponent:fileName] atomically:YES]) {
            [hud removeFromSuperview];
            [MBProgressHUD showMBPMsg:@"保存图片成功" onView:self.imgView delay:0.8];
        }else{
            [hud removeFromSuperview];
            [MBProgressHUD showMBPMsg:@"保存图片失败" onView:self.imgView delay:0.8];
        }
    }
}

#pragma mark - 属性初始化方法
- (void)setPic:(BeautyPic *)pic{
    _pic = pic;
    [self showPic];
}


@end
