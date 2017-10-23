//
//  CWPhotoTool.h
//  CarWash
//
//  Created by wsk on 2017/10/18.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^CWPhotoMutiPickerCompletion)(NSArray *imageArray);

@interface CWPhotoTool : NSObject

/**
 选择图片

 @param maxCount 最大数量
 @param completeBlock 完成回调
 */
+ (void)showPhotoSheetMaxCount:(NSInteger)maxCount forViewController:(UIViewController *)viewController completion:(CWPhotoMutiPickerCompletion)completeBlock;
@end
