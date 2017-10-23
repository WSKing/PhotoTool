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
@interface CWPhotoTool()<CWPhotoLibiraryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy) CWPhotoMutiPickerCompletion completion;//完成时调用
@property (nonatomic, strong) UIImagePickerController *picker;
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
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [viewController presentViewController:[CWPhotoTool sharedInstance].picker animated:YES completion:nil];
            }else
                return ;

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

#pragma mark --imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image;
        image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        if (self.completion) {
            self.completion(@[image]);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (self.completion) {
        self.completion(nil);
    }
}

- (UIImagePickerController *)picker {
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _picker.allowsEditing = YES;
    }
    return _picker;
}
@end
