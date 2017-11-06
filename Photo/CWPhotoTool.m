//
//  CWPhotoTool.m
//  CarWash
//
//  Created by wsk on 2017/10/18.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "CWPhotoTool.h"
#import <UIKit/UIKit.h>
#import <MMSheetView.h>
#import "CWPhotoController.h"
#import "CameraController.h"
@interface CWPhotoTool()<CWPhotoLibiraryDelegate, TakePhotoCompleteDelegate>
@property (nonatomic, copy) CWPhotoMutiPickerCompletion completion;//完成时调用
@end
@implementation CWPhotoTool

static CWPhotoTool *_instance;
//单例
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


+ (void)showPhotoSheetMaxCount:(NSInteger)maxCount forViewController:(UIViewController *)viewController completion:(CWPhotoMutiPickerCompletion)completeBlock {
    [CWPhotoTool sharedInstance].completion = completeBlock;
    //sheet点击事件
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            //相机
            /*
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [viewController presentViewController:[CWPhotoTool sharedInstance].picker animated:YES completion:nil];
            }else
                return ;*/
            CameraController *cameraCtrl = [[CameraController alloc] init];
            cameraCtrl.maxCount = maxCount;
            cameraCtrl.delegate = [CWPhotoTool sharedInstance];
            [viewController.navigationController pushViewController:cameraCtrl animated:YES];

        }else {
            //相册
            CWPhotoController *photoCtrl = [[CWPhotoController alloc] init];
            photoCtrl.maxCount = maxCount;
            photoCtrl.delegate = [CWPhotoTool sharedInstance];
           
            [viewController.navigationController pushViewController:photoCtrl animated:YES];
        }
    };
    NSArray *items = @[MMItemMake(@"相机", MMItemTypeHighlight, block),
                       MMItemMake(@"相册", MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"选择相片" items:items];
    [sheetView show];
}

#pragma mark --photoController delegate
- (void)didFinishedChoosedPhoto:(NSArray *)imgList {
    if (self.completion) {
        self.completion(imgList);
    }
}

#pragma mark --Camera delegate
- (void)didCompleteTakePhoto:(NSArray *)imageList {
    if (self.completion) {
        self.completion(imageList);
    }
}

@end
