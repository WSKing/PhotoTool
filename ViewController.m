//
//  ViewController.m
//  PhotoTool
//
//  Created by wsk on 2017/10/23.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "ViewController.h"
#import "CWPhotoTool.h"
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSMutableArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *photoBtn = [[UIBarButtonItem alloc] initWithTitle:@"相片" style:UIBarButtonItemStylePlain target:self action:@selector(photoAction)];
    self.navigationItem.rightBarButtonItem = photoBtn;
    [self.view addSubview:self.collectionView];
}

#pragma mark --delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 4 * 10)/3, (SCREEN_WIDTH - 4 * 10)/3)];
    UIImage *image = self.dataList[indexPath.row];
    imgView.image = image;
    [cell.contentView addSubview:imgView];
    return cell;
}

#pragma mark --actions
- (void)photoAction {
    [CWPhotoTool showPhotoSheetMaxCount:3 forViewController:self completion:^(NSArray *imageArray) {
        [self.dataList addObjectsFromArray:imageArray];
        [self.collectionView reloadData];
    }];
}

#pragma mark --lazy init
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 4 * 10)/3, (SCREEN_WIDTH - 4 * 10)/3);
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
    }
    return _collectionView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
@end
