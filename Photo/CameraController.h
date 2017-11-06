//
//  CameraController.h
//  PhotoTool
//
//  Created by wsk on 2017/11/6.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TakePhotoCompleteDelegate<NSObject>
- (void)didCompleteTakePhoto:(NSArray *)imageList;
@end

@interface CameraController : UIViewController
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, weak) id <TakePhotoCompleteDelegate> delegate;
@end
