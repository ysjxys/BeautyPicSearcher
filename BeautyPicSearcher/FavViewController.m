//
//  FavViewController.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/18.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "FavViewController.h"
#import "YSJTabViewController.h"
#import "MBProgressHUD+YSJ.h"
#import "FavImgsCollectionViewCell.h"

#define distance 10
#define rightBtnWidth 50

@interface FavViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *bigScroll;
@property (nonatomic, strong) UIScrollView *smallScroll;
@property (nonatomic, strong) UIImageView *imgViewLeft;
@property (nonatomic, strong) UIImageView *imgViewCenter;
@property (nonatomic, strong) UIImageView *imgViewRight;
@property (nonatomic, assign) BOOL isTabBarHidden;
@property (nonatomic, strong) NSMutableArray *imgsArr;
@property (nonatomic, strong) NSMutableArray *imgsFilePathArr;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UICollectionView *imgCollectionView;
@property (nonatomic, assign) CGFloat collectionCellWidth;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, strong) UIButton *collectionBtn;
@property (nonatomic, strong) NSLayoutConstraint *bigScrollHeight;
@property (nonatomic, strong) NSLayoutConstraint *imgCenterHeight;
@property (nonatomic, strong) NSLayoutConstraint *imgLeftHeight;
@property (nonatomic, strong) NSLayoutConstraint *imgRightHeight;
@end

@implementation FavViewController
#pragma mark - 生命周期方法
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    YSJTabViewController *tab = (YSJTabViewController *)self.tabBarController;
    tab.orietation = UIInterfaceOrientationMaskAllButUpsideDown;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated: NO];
    [self refreshData];
    [self screenDirectionChanged:nil];
    [self.imgCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 初始化方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initView];
    [self initConstraint];
    [self initNotification];
    
}

- (void)refreshData{
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    homePath = [homePath stringByAppendingPathComponent:@"favImgs"];
    
    NSArray *fileNameArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:homePath error:nil];
    [self.imgsArr removeAllObjects];
    [self.imgsFilePathArr removeAllObjects];
    for (NSString *fileName in fileNameArr) {
        if ([fileName containsString:@".jpg"] || [fileName containsString:@".png"]) {
            NSString *filePath = [homePath stringByAppendingPathComponent:fileName];
            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
            [self.imgsArr addObject:img];
            [self.imgsFilePathArr addObject:filePath];
        }
    }
    [self setImgsWithCenterIndex:0];
}

- (void)setImgsWithCenterIndex:(NSInteger)index{
    if (self.imgsArr.count <= 0) {
        return;
    }
    if (index > self.imgsArr.count-1) {
        index = 0;
    }
    self.imgViewCenter.image = self.imgsArr[index];
    self.imgViewLeft.image = index==0?self.imgsArr[self.imgsArr.count-1]:self.imgsArr[index-1];
    self.imgViewRight.image = index==(self.imgsArr.count-1)?self.imgsArr[0]:self.imgsArr[index+1];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDirectionChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)initView{
    self.navigationItem.title = @"收藏";
    self.navigationController.navigationBar.hidden = YES;
    self.isTabBarHidden = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnView)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",@"分享", nil];
    self.actionSheet = action;
    
    UIScrollView *bigScroll = [[UIScrollView alloc]init];
    self.bigScroll = bigScroll;
    bigScroll.pagingEnabled = YES;
    bigScroll.delegate = self;
    [self.view addSubview:bigScroll];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressOnBigScroll)];
    [bigScroll addGestureRecognizer:longPress];
    
    UIImageView *imgViewLeft = [[UIImageView alloc]init];
    self.imgViewLeft = imgViewLeft;
    imgViewLeft.contentMode = UIViewContentModeScaleAspectFit;
    [self.bigScroll addSubview:imgViewLeft];
    
    UIImageView *imgViewCenter = [[UIImageView alloc]init];
    self.imgViewCenter = imgViewCenter;
    imgViewCenter.contentMode = UIViewContentModeScaleAspectFit;
    [self.bigScroll addSubview:imgViewCenter];
    
    UIImageView *imgViewRight = [[UIImageView alloc]init];
    self.imgViewRight = imgViewRight;
    imgViewRight.contentMode = UIViewContentModeScaleAspectFit;
    [self.bigScroll addSubview:imgViewRight];
    
    self.collectionCellWidth = [self collectionViewCellWidth];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *imgCollectionView = [[UICollectionView alloc]initWithFrame:bigScroll.frame collectionViewLayout:layout];
    [imgCollectionView registerClass:[FavImgsCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdenifier];
    imgCollectionView.delegate = self;
    imgCollectionView.dataSource = self;
    [self.view addSubview:imgCollectionView];
    self.imgCollectionView = imgCollectionView;
    
    UIButton *collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectionBtn.backgroundColor = [UIColor whiteColor];
    [collectionBtn setImage:[UIImage imageNamed:@"table-mode"] forState:UIControlStateNormal];
    [collectionBtn setImage:[UIImage imageNamed:@"grid-mode"] forState:UIControlStateSelected];
    [collectionBtn addTarget:self action:@selector(collectionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.collectionBtn = collectionBtn;
    [self.view addSubview:collectionBtn];
    
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fullScreenBtn.backgroundColor = [UIColor whiteColor];
    [fullScreenBtn setImage:[UIImage imageNamed:@"fullscreen_1"] forState:UIControlStateNormal];
    [fullScreenBtn setImage:[UIImage imageNamed:@"fullscreen_2"] forState:UIControlStateSelected];
    [fullScreenBtn addTarget:self action:@selector(fullScreenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.fullScreenBtn = fullScreenBtn;
    [self.view addSubview:fullScreenBtn];
    
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    imgViewLeft.backgroundColor = [UIColor blackColor];
    imgViewCenter.backgroundColor = [UIColor blackColor];
    imgViewRight.backgroundColor = [UIColor blackColor];
    bigScroll.backgroundColor = [UIColor blackColor];
    imgCollectionView.backgroundColor = [UIColor blackColor];
    
//    self.navigationController.view.backgroundColor = [UIColor greenColor];
//    imgViewLeft.backgroundColor = [UIColor yellowColor];
//    imgViewCenter.backgroundColor = [UIColor darkGrayColor];
//    imgViewRight.backgroundColor = [UIColor redColor];
//    bigScroll.backgroundColor = [UIColor purpleColor];
//    imgCollectionView.backgroundColor = [UIColor blueColor];
}

- (CGFloat)collectionViewCellWidth{
    CGFloat allWidth = ScreenWidth<ScreenHeight?ScreenWidth:ScreenHeight;
    return (allWidth - 5*distance)/4;
}

- (void)initConstraint{
    self.bigScroll.translatesAutoresizingMaskIntoConstraints = NO;
    self.imgViewLeft.translatesAutoresizingMaskIntoConstraints = NO;
    self.imgViewCenter.translatesAutoresizingMaskIntoConstraints = NO;
    self.imgViewRight.translatesAutoresizingMaskIntoConstraints = NO;
    self.imgCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.fullScreenBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat height;
    CGFloat width;
    if (ScreenHeight > ScreenWidth) {
        height = ScreenHeight;
        width = ScreenWidth;
    }else{
        height = ScreenWidth;
        width = ScreenHeight;
    }

    NSLayoutConstraint *bigScrollLeading = [NSLayoutConstraint constraintWithItem:self.bigScroll attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *bigScrollTailing = [NSLayoutConstraint constraintWithItem:self.bigScroll attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *bigScrollTop = [NSLayoutConstraint constraintWithItem:self.bigScroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    self.bigScrollHeight = [NSLayoutConstraint constraintWithItem:self.bigScroll attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:height];
    
    bigScrollLeading.active = YES;
    bigScrollTailing.active = YES;
    bigScrollTop.active = YES;
    self.bigScrollHeight.active = YES;

    NSLayoutConstraint *imgLeftTop = [NSLayoutConstraint constraintWithItem:self.imgViewLeft attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    self.imgLeftHeight = [NSLayoutConstraint constraintWithItem:self.imgViewLeft attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:height];

    NSLayoutConstraint *imgLeftLeading = [NSLayoutConstraint constraintWithItem:self.imgViewLeft attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bigScroll attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];

    NSLayoutConstraint *imgLeftWidth = [NSLayoutConstraint constraintWithItem:self.imgViewLeft attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];

    imgLeftTop.active = YES;
    imgLeftLeading.active = YES;
    imgLeftWidth.active = YES;
    self.imgLeftHeight.active = YES;
    
    NSLayoutConstraint *imgCenterTop = [NSLayoutConstraint constraintWithItem:self.imgViewCenter attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    self.imgCenterHeight = [NSLayoutConstraint constraintWithItem:self.imgViewCenter attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:height-100];
    
    NSLayoutConstraint *imgCenterLeading = [NSLayoutConstraint constraintWithItem:self.imgViewCenter attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imgViewLeft attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgCenterWidth = [NSLayoutConstraint constraintWithItem:self.imgViewCenter attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    imgCenterTop.active = YES;
    self.imgCenterHeight.active = YES;
    imgCenterLeading.active = YES;
    imgCenterWidth.active = YES;
    
    NSLayoutConstraint *imgRightTop = [NSLayoutConstraint constraintWithItem:self.imgViewRight attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    self.imgRightHeight = [NSLayoutConstraint constraintWithItem:self.imgViewRight attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:height];
    
    NSLayoutConstraint *imgRightTailing = [NSLayoutConstraint constraintWithItem:self.imgViewRight attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bigScroll attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgRightLeading = [NSLayoutConstraint constraintWithItem:self.imgViewRight attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imgViewCenter attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *imgRightWidth = [NSLayoutConstraint constraintWithItem:self.imgViewRight attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    imgRightTop.active = YES;
    imgRightTailing.active = YES;
    imgRightWidth.active = YES;
    imgRightLeading.active = YES;
    self.imgRightHeight.active = YES;
    
    NSLayoutConstraint *collcetionLeading = [NSLayoutConstraint constraintWithItem:self.imgCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collcetionTailing = [NSLayoutConstraint constraintWithItem:self.imgCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collcetionTop = [NSLayoutConstraint constraintWithItem:self.imgCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collcetionHeight = [NSLayoutConstraint constraintWithItem:self.imgCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:height];
    
    collcetionLeading.active = YES;
    collcetionTailing.active = YES;
    collcetionTop.active = YES;
    collcetionHeight.active = YES;
    
    NSLayoutConstraint *collectionBtnCenterY = [NSLayoutConstraint constraintWithItem:self.collectionBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-30.0f];
    
    NSLayoutConstraint *collectionBtnTailing = [NSLayoutConstraint constraintWithItem:self.collectionBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collectionBtnWidth = [NSLayoutConstraint constraintWithItem:self.collectionBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0f constant:rightBtnWidth];
    
    NSLayoutConstraint *collectionBtnHeight = [NSLayoutConstraint constraintWithItem:self.collectionBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:40.0f];
    
    collectionBtnCenterY.active = YES;
    collectionBtnTailing.active = YES;
    collectionBtnWidth.active = YES;
    collectionBtnHeight.active = YES;
    
    NSLayoutConstraint *fullScreenBtnTop = [NSLayoutConstraint constraintWithItem:self.fullScreenBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionBtn attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10.0f];
    
    NSLayoutConstraint *fullScreenBtnTailing = [NSLayoutConstraint constraintWithItem:self.fullScreenBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *fullScreenBtnWidth = [NSLayoutConstraint constraintWithItem:self.fullScreenBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0f constant:rightBtnWidth];
    
    NSLayoutConstraint *fullScreenBtnHeight = [NSLayoutConstraint constraintWithItem:self.fullScreenBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:40.0f];
    
    fullScreenBtnTop.active = YES;
    fullScreenBtnTailing.active = YES;
    fullScreenBtnWidth.active = YES;
    fullScreenBtnHeight.active = YES;
}

#pragma mark - collectionView delegate & datasource &flowlayoutdelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imgsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FavImgsCollectionViewCell *cell = [FavImgsCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell setImg:self.imgsArr[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self setImgsWithCenterIndex:indexPath.row];
    self.imgCollectionView.hidden = YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.collectionCellWidth, self.collectionCellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(distance, distance, distance, distance);
}

//section之间垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return distance;
}

//scrtion之间水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return distance;
}


#pragma  mark - btnClicked
- (void)collectionBtnClicked{
    self.imgCollectionView.hidden = !self.imgCollectionView.hidden;
    self.collectionBtn.selected = !self.collectionBtn.selected;
}

- (void)fullScreenBtnClicked{
    self.fullScreenBtn.selected = !self.fullScreenBtn.selected;
    BOOL isHidden = [UIApplication sharedApplication].isStatusBarHidden;
    [UIView animateWithDuration:0.4 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:!isHidden withAnimation:UIStatusBarAnimationFade];
        self.tabBarController.tabBar.alpha = self.isTabBarHidden;
        if (self.imgCollectionView.hidden) {
            if (isHidden) {
                self.collectionBtn.alpha = 1;
                self.fullScreenBtn.alpha = 1;
            }else{
                self.collectionBtn.alpha = 0;
                self.fullScreenBtn.alpha = 0;
            }
        }
    } completion:^(BOOL finished) {
        self.isTabBarHidden = !self.isTabBarHidden;
    }];
}

#pragma mark - UIGesterure selector
- (void)longPressOnBigScroll{
    [self.actionSheet showInView:self.view];
}

- (void)tapOnView{
    [self fullScreenBtnClicked];
}

#pragma mark - UIGesterure delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.imgCollectionView]) {
        return NO;
    }
    return YES;
}

#pragma mark - actionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;//cancelBtn
    }else if (buttonIndex == 1){
        return;//shareBtn
    }else if (buttonIndex == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FBIWarning" message:@"删了可就没了呦~" delegate:self cancelButtonTitle:@"我不删了" otherButtonTitles:@"我偏要删", nil];
        [alert show];
    }
}

#pragma mark - alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }else if(buttonIndex == 1){
        UIImage *img = self.imgViewCenter.image;
        NSUInteger index = [self.imgsArr indexOfObject:img];
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:[self.imgsFilePathArr objectAtIndex:index] error:&error];
        if (result) {
            [MBProgressHUD showMBPMsg:@"于是被删了" onView:self.view delay:2];
            [self refreshData];
            [self.imgCollectionView reloadData];
        }else{
            YSJLog(@"%@",error);
        }
    }
}

#pragma mark - scroll Delegate
- (void)screenDirectionChanged:(NSNotification *)notification{
    
    self.bigScroll.contentSize = CGSizeMake(ScreenWidth*3, 0);
    self.bigScroll.contentOffset = CGPointMake(ScreenWidth, 0);
    self.bigScrollHeight.constant = ScreenHeight;
    self.imgCenterHeight.constant = ScreenHeight;
    self.imgLeftHeight.constant = ScreenHeight;
    self.imgRightHeight.constant = ScreenHeight;
    
//    UIDevice *device = [UIDevice currentDevice];
//    switch (device.orientation) {
//        case UIDeviceOrientationPortrait://home botton on the buttom
//            [self changeConstraintPriorityHomeBtnOnBottom:YES];
//            break;
//        case UIDeviceOrientationLandscapeLeft://home button on the right
//        case UIDeviceOrientationLandscapeRight://home button on the left
//            [self changeConstraintPriorityHomeBtnOnBottom:NO];
//            break;
//        default:
//            break;
//    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == 0) {
        UIImage *showImg = self.imgViewLeft.image;
        NSUInteger showIndex = [self.imgsArr indexOfObject:showImg];
        self.imgViewCenter.image = showImg;
        if (showIndex+1 < self.imgsArr.count) {
            self.imgViewRight.image = self.imgsArr[showIndex+1];
        }else{
            self.imgViewRight.image = self.imgsArr[0];
        }
        scrollView.contentOffset = CGPointMake(ScreenWidth, 0);
        if (showIndex == 0) {
            self.imgViewLeft.image = self.imgsArr[self.imgsArr.count-1];
        }else{
            self.imgViewLeft.image = self.imgsArr[showIndex-1];
        }
    }
    if (scrollView.contentOffset.x == ScreenWidth*2) {
        UIImage *showImg = self.imgViewRight.image;
        NSUInteger showIndex = [self.imgsArr indexOfObject:showImg];
        self.imgViewCenter.image = showImg;
        if (showIndex == 0) {
            self.imgViewLeft.image = self.imgsArr[self.imgsArr.count-1];
        }else{
            self.imgViewLeft.image = self.imgsArr[showIndex-1];
        }
        scrollView.contentOffset = CGPointMake(ScreenWidth, 0);
        if (showIndex+1 < self.imgsArr.count) {
            self.imgViewRight.image = self.imgsArr[showIndex+1];
        }else{
            self.imgViewRight.image = self.imgsArr[0];
        }
    }
    scrollView.scrollEnabled = YES;
}

#pragma mark - 初始化方法
- (NSMutableArray *)imgsArr{
    if (!_imgsArr) {
        _imgsArr = [NSMutableArray array];
    }
    return _imgsArr;
}

- (NSMutableArray *)imgsFilePathArr{
    if (!_imgsFilePathArr) {
        _imgsFilePathArr = [NSMutableArray array];
    }
    return _imgsFilePathArr;
}

@end
