//
//  CWPhotoController.m
//  CarWash
//
//  Created by wsk on 2017/10/18.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "CWPhotoController.h"
#import <Photos/Photos.h>
#import "PhotoCell.h"
#import <MBProgressHUD.h>
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
@interface CWPhotoController ()<UICollectionViewDelegate, UICollectionViewDataSource,PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *imgsList;
@property (nonatomic, strong) NSMutableArray<UIImage *> *selectedImgList;


@end

@implementation CWPhotoController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"选择相片";
    UIBarButtonItem *sureItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction)];
    self.navigationItem.rightBarButtonItem = sureItem;
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    [library registerChangeObserver:self];
    [self requestLocalPhoto];
    [self.view addSubview:self.collectionView];
}
//相册权限发生改变(如果是第一次进应用之前没有同意相册权限,第一次进来后同意是会是空的界面,下面方法解决)
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self requestLocalPhoto];
}

- (void)requestLocalPhoto {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
    }  else {
        //这里就是用权限
        [self getAllAssetInPhotoAblumWithAscending:YES];
    }
}

#pragma mark --delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgsList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCell class]) forIndexPath:indexPath];
    cell.imgVIew.image = self.imgsList[indexPath.row];
    cell.selectedImgView.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell =(PhotoCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedImgView.hidden = !cell.selectedImgView.hidden;
    if (!cell.selectedImgView.hidden) {
        if (self.selectedImgList.count < self.maxCount) {
            [self.selectedImgList addObject:cell.imgVIew.image];
        }else {
            cell.selectedImgView.hidden = YES;
            NSLog(@"最多%ld张",self.maxCount);
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.detailsLabel.text = @"超出最大限制";
            HUD.mode = MBProgressHUDModeText;
            HUD.removeFromSuperViewOnHide = YES;
            [HUD showAnimated:YES];
            [HUD hideAnimated:YES afterDelay:1];
           
        }
    }else {
        [self.selectedImgList removeObject:cell.imgVIew.image];
    }
}

#pragma mark --func
- (void)sureAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishedChoosedPhoto:)]) {
        [self.delegate didFinishedChoosedPhoto:self.selectedImgList];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//读取所有图片
- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    CGSize size = CGSizeMake((SCREEN_WIDTH - 4 * 5)/3, (SCREEN_WIDTH - 4 * 5)/3);
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //解析图片
        PHAsset *asset = (PHAsset *)obj;
        NSLog(@"照片名%@", [asset valueForKey:@"filename"]);
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        //仅显示缩略图，不控制质量显示
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        option.networkAccessAllowed = YES;
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        __weak typeof(self)weakSelf = self;
        [[PHCachingImageManager defaultManager] requestImageForAsset:obj targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.imgsList addObject:image];
            if (strongSelf.imgsList.count == result.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.collectionView reloadData];
                });
            }
        }];
    }];
}


#pragma mark --lazy init
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 4 * 5)/3, (SCREEN_WIDTH - 4 * 5)/3);
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 0, 5);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
         [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PhotoCell class])];
    }
    return _collectionView;
}

- (NSMutableArray<UIImage *> *)selectedImgList {
    if (!_selectedImgList) {
        _selectedImgList = [NSMutableArray array];
    }
    return _selectedImgList;
}

- (NSMutableArray<UIImage *> *)imgsList {
    if (!_imgsList) {
        _imgsList = [NSMutableArray array];
    }
    return _imgsList;
}


@end
