//
//  PicSearchViewController.m
//  BeautyPicSearcher
//
//  Created by ysj on 16/4/1.
//  Copyright © 2016年 yushengjie. All rights reserved.
//

#import "PicSearchViewController.h"
#import "AFNetworking.h"
#import "YSJAFNetWorkingHelper.h"
#import "BeautyPic.h"
#import "NSObject+YSJ.h"
#import "UIImageView+WebCache.h"
#import "WaterFlowView.h"
#import "MJRefresh.h"
#import "YSJNetHelper.h"
#import "PicDetailViewController.h"
#import "YSJNavigationController.h"
#import "YSJTabViewController.h"


@interface PicSearchViewController ()<WaterFlowViewDelegate,WaterFlowViewDataSource>
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, strong) NSMutableDictionary *param;
@property (nonatomic, assign) int imgNum;
@property (nonatomic, assign) int imgNumPerPage;
@property (nonatomic, strong) NSMutableArray *imgsArr;
@property (nonatomic, strong) WaterFlowView *waterFlowView;
@property (nonatomic, strong) UIView *choseView;
@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;
@property (nonatomic, strong) UIButton *btn3;
@end

@implementation PicSearchViewController

- (void)viewWillAppear:(BOOL)animated{
    YSJTabViewController *tab = (YSJTabViewController *)self.tabBarController;
    tab.orietation = UIInterfaceOrientationMaskPortrait;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewDidLoad {
    NSString *homeDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@",homeDir);
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initConstraint];
    [self loadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"分类" style:UIBarButtonItemStylePlain target:self action:@selector(changeKind)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清理缓存" style:UIBarButtonItemStylePlain target:self action:@selector(clearCache)];
}

- (void)clearCache{
    float beforeSize = [[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
    [[SDImageCache sharedImageCache] cleanDiskWithCompletionBlock:^{
        float afterSize = [[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        NSString *str = [NSString stringWithFormat:@"一共腾出%.2lfM的空间",beforeSize-afterSize];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"清理结果" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)changeKind{
    NSLog(@"%ld",[YSJNetHelper checkNetMode]);
    NSLog(@"%@",[YSJNetHelper checkNetData]);
    [UIView animateWithDuration:0.4 animations:^{
        self.choseView.alpha = !self.choseView.alpha;
    }];
}

- (void)initData{
    self.urlStr = @"http://image.baidu.com/channel/listjson?";
    self.imgNum = 0;
    self.imgNumPerPage = 20;
    [self.param setObject:@(self.imgNum) forKey:@"pn"];
    [self.param setObject:@(20) forKey:@"rn"];
    [self.param setObject:@"壁纸" forKey:@"tag1"];
    [self.param setObject:@"全部" forKey:@"tag2"];
}

- (void)initView{
    self.navigationItem.title = @"搜索";
    
    [self.view addSubview:self.waterFlowView];
    __typeof(self) weakself = self;
    self.waterFlowView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.imgNum = self.imgNum + _imgNumPerPage;
        [self.param setObject:@(self.imgNum) forKey:@"pn"];
//        [weakself loadData];
    }];
    
    UIView *choseView = [[UIView alloc]init];
    choseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:choseView];
    self.choseView = choseView;
    choseView.alpha = 0;
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"美女" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn1.tag = 1;
    [btn1 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choseView addSubview:btn1];
    self.btn1 = btn1;
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"美女2" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn2.tag = 2;
    [btn2 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choseView addSubview:btn2];
    self.btn2 = btn2;
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitle:@"美女3" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn3.tag = 3;
    [btn3 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choseView addSubview:btn3];
    self.btn3 = btn3;
}

- (void)initConstraint{
//    self.waterFlowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.choseView.translatesAutoresizingMaskIntoConstraints = NO;
    self.btn1.translatesAutoresizingMaskIntoConstraints = NO;
    self.btn2.translatesAutoresizingMaskIntoConstraints = NO;
    self.btn3.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *waterFlowViewLeading = [NSLayoutConstraint constraintWithItem:self.waterFlowView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *waterFlowViewTailing = [NSLayoutConstraint constraintWithItem:self.waterFlowView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *waterFlowViewTop = [NSLayoutConstraint constraintWithItem:self.waterFlowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *waterFlowViewBottom = [NSLayoutConstraint constraintWithItem:self.waterFlowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    
//    waterFlowViewLeading.active = YES;
//    waterFlowViewTailing.active = YES;
//    waterFlowViewTop.active = YES;
//    waterFlowViewBottom.active = YES;
    
    NSLayoutConstraint *choseViewTop = [NSLayoutConstraint constraintWithItem:self.choseView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:StatusBarHeight+NavigationBarHeight];
    
    NSLayoutConstraint *choseViewTailing = [NSLayoutConstraint constraintWithItem:self.choseView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-5.0f];
    
    NSLayoutConstraint *choseViewWidth = [NSLayoutConstraint constraintWithItem:self.choseView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0f constant:60.0f];
    
    NSLayoutConstraint *choseViewHeight = [NSLayoutConstraint constraintWithItem:self.choseView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:90.0f];
    
    choseViewTop.active = YES;
    choseViewTailing.active = YES;
    choseViewWidth.active = YES;
    choseViewHeight.active = YES;
    
    NSLayoutConstraint *btn1Top = [NSLayoutConstraint constraintWithItem:self.btn1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn1Tailing = [NSLayoutConstraint constraintWithItem:self.btn1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn1Leading = [NSLayoutConstraint constraintWithItem:self.btn1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn1Height = [NSLayoutConstraint constraintWithItem:self.btn1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:30.0f];
    
    btn1Top.active = YES;
    btn1Tailing.active = YES;
    btn1Leading.active = YES;
    btn1Height.active = YES;
    
    NSLayoutConstraint *btn2Top = [NSLayoutConstraint constraintWithItem:self.btn2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.btn1 attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn2Tailing = [NSLayoutConstraint constraintWithItem:self.btn2 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn2Leading = [NSLayoutConstraint constraintWithItem:self.btn2 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn2Height = [NSLayoutConstraint constraintWithItem:self.btn2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:30.0f];
    
    btn2Top.active = YES;
    btn2Tailing.active = YES;
    btn2Leading.active = YES;
    btn2Height.active = YES;
    
    NSLayoutConstraint *btn3Top = [NSLayoutConstraint constraintWithItem:self.btn3 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.btn2 attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn3Tailing = [NSLayoutConstraint constraintWithItem:self.btn3 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn3Leading = [NSLayoutConstraint constraintWithItem:self.btn3 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.choseView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *btn3Height = [NSLayoutConstraint constraintWithItem:self.btn3 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:30.0f];
    
    btn3Top.active = YES;
    btn3Tailing.active = YES;
    btn3Leading.active = YES;
    btn3Height.active = YES;
}


- (void)loadData{
    [YSJAFNetWorkingHelper getJSONWithUrl:self.urlStr parameters:self.param success:^(id response) {
        NSArray *tempArr = response[@"data"];
//        YSJLog(@"%@",tempArr);
        for (NSDictionary *dic in tempArr) {
            BeautyPic *pic = [BeautyPic picWithDic:dic];
            if ([pic.imgUrl isNotNull]) {
                CGFloat width = ScreenWidth/2-5;
                CGFloat height = pic.imgHeight*width/pic.imgWidth;
                pic.picDegreeWidth = width;
                pic.picDegreeHeight = (int)(height+0.5);
//                [self.imgsArr addObject:pic];
                if(![self.waterFlowView addObject:pic Height:pic.picDegreeHeight ColumnCount:2]){
                    YSJLog(@"添加图像对象失败");
                }
            }
        }
        self.imgsArr = [self.waterFlowView columnArray];
        [self.waterFlowView reloadData];
        [self.waterFlowView.mj_footer endRefreshing];
    } fail:^(NSString *errorMsg) {
        YSJLog(@"%@",errorMsg);
    }];
}

#pragma mark - btnClicked
- (void)btnClicked:(UIButton *)btn{
    [UIView animateWithDuration:0.3 animations:^{
        self.choseView.alpha = !self.choseView.alpha;
    }];
    UIButton *selectedBtn = [self.choseView viewWithTag:btn.tag];
    
    [self.param setObject:selectedBtn.currentTitle forKey:@"tag1"];
    self.imgNum = 0;
    [self.imgsArr removeAllObjects];
    [self.waterFlowView clearData];
    [self.waterFlowView reloadData];
    [self loadData];
}

#pragma mark - collectionView Delegate
- (NSInteger)waterFlowView:(WaterFlowView *)waterFlowView numberOfRowsInColumn:(NSInteger)column{
    if (self.imgsArr.count == 0) {
        return 0;
    }
    return [self.imgsArr[column] count];
}

- (NSInteger)numberOfColumnsInWaterFlowView:(WaterFlowView *)waterFlowView{
    return 2;
}

- (WaterFlowViewCell *)waterFlowView:(WaterFlowView *)waterFlowView cellForRowAtIndexPath:(WFIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WaterFlowViewCell";
    WaterFlowViewCell *cell = [self.waterFlowView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[WaterFlowViewCell alloc] initWithIdentifier:cellIdentifier waterFlowView:waterFlowView wfIndexPath:indexPath];
    }
    
    BeautyPic *pic = [[self.imgsArr objectAtIndex:indexPath.column] objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:pic.imgUrl];
    UIImage *placeholder = [UIImage imageNamed:@"placeholder-image"];
    [cell.imageView sd_setImageWithURL:url placeholderImage:placeholder];
    
    return cell;
}

- (CGFloat)waterFlowView:(WaterFlowView *)waterFlowView heightForRowAtIndexPath:(WFIndexPath *)indexPath{
    BeautyPic *pic = [[self.imgsArr objectAtIndex:indexPath.column] objectAtIndex:indexPath.row];
    return pic.picDegreeHeight;
}


- (void)waterFlowView:(WaterFlowView *)waterFlowView didSelectRowAtIndexPath:(WFIndexPath *)indexPath{
    PicDetailViewController *picDetailVC= [[PicDetailViewController alloc]init];
    picDetailVC.pic = [[self.imgsArr objectAtIndex:indexPath.column] objectAtIndex:indexPath.row];
//    picDetailVC.view.backgroundColor = [UIColor whiteColor];
    picDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:picDetailVC animated:YES completion:nil];
}

#pragma mark - 初始化方法

- (WaterFlowView *)waterFlowView{
    if (!_waterFlowView) {
        _waterFlowView = [[WaterFlowView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _waterFlowView.backgroundColor = [UIColor whiteColor];
        _waterFlowView.waterFlowDelegate = self;
        _waterFlowView.waterFlowDataSource = self;
    }
    return _waterFlowView;
}

- (NSMutableDictionary *)param{
    if (!_param) {
        _param = [NSMutableDictionary dictionary];
    }
    return _param;
}

- (NSMutableArray *)imgsArr{
    if (!_imgsArr) {
        _imgsArr = [NSMutableArray array];
    }
    return _imgsArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
