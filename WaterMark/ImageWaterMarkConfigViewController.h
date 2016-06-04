//
//  ImageWaterMarkConfigViewController.h
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageWaterMarkConfig.h"

@interface ImageWaterMarkConfigViewController : NSViewController
@property(nonatomic, strong) ImageWaterMarkConfig *existedConfig;
@property(nonatomic, weak)
    id<WaterMarkConfigViewControllerDelegate> delegate;
@end
