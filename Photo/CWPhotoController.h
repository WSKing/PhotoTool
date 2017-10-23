//
//  CWPhotoController.h
//  CarWash
//
//  Created by wsk on 2017/10/18.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CWPhotoLibiraryDelegate<NSObject>
- (void)didFinishedChoosedPhoto:(NSArray *)imgList;
@end


@interface CWPhotoController : UIViewController
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, weak) id <CWPhotoLibiraryDelegate> delegate;
@end
