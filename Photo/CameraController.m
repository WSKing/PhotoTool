//
//  CameraController.m
//  PhotoTool
//
//  Created by wsk on 2017/11/6.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import "PhotoCell.h"
#import <MBProgressHUD.h>
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define iPhone_X                 (SCREEN_HEIGHT == 812.0)
#define Status_H                 (iPhone_X ? 44 : 20)
#define NavBar_H                  44
#define Nav_Height                (Status_H + NavBar_H)
#define Collection_Height          (SCREEN_WIDTH - 6 * 10) / 5
@interface CameraController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *output;
@property (nonatomic, strong )AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSMutableArray *dataList;
@end

@implementation CameraController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDevice];
    UIButton *photoBtn = [[UIButton alloc] init];
    [photoBtn setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoBtn];
    [photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
        make.width.height.equalTo(@60);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.bottom.equalTo(photoBtn.mas_top).offset(-10);
        make.height.equalTo(@(Collection_Height));
        make.width.equalTo(@(self.maxCount * Collection_Height + (self.maxCount + 1) * 10));
    }];
    
    UIBarButtonItem *sureItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction)];
    self.navigationItem.rightBarButtonItem = sureItem;
}

- (void)initDevice {
    self.device = [AVCaptureDevice  defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    self.output  = [[AVCaptureStillImageOutput alloc] init];
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, Nav_Height, SCREEN_WIDTH, SCREEN_HEIGHT - Nav_Height);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
}

- (void)photoBtnDidClick {
    AVCaptureConnection *conntion = [self.output connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"拍照失败!");
        return;
    }
    [self.output captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        if (self.dataList.count < self.maxCount) {
            [self.dataList addObject:image];
            [self.collectionView reloadData];
        }else {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.detailsLabel.text = @"超出最大限制";
            HUD.mode = MBProgressHUDModeText;
            HUD.removeFromSuperViewOnHide = YES;
            [HUD showAnimated:YES];
            [HUD hideAnimated:YES afterDelay:1];
        }     
    }];
    
}

- (void)deletePhoto:(UIButton *)sender {
    NSInteger tag = sender.tag - 1020;
    [self.dataList removeObjectAtIndex:tag];
    [self.collectionView reloadData];
}

- (void)sureAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteTakePhoto:)]) {
        [self.delegate didCompleteTakePhoto:self.dataList];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark --collectionview
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCell class]) forIndexPath:indexPath];
    cell.imgVIew.image = self.dataList[indexPath.row];
    cell.selectedImgView.hidden = YES;
    
    UIButton *deleteBtn = [[UIButton alloc] init];
    [deleteBtn setImage:[UIImage imageNamed:@"AD_close"] forState:UIControlStateNormal];
    deleteBtn.tag = indexPath.row + 1020;
    [deleteBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(cell.contentView);
        make.width.height.equalTo(@20);
    }];
    return cell;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(Collection_Height, Collection_Height);
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PhotoCell class])];
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
