//
//  ImageWaterMarkConfig.h
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "WaterMarkConfig.h"

@interface ImageWaterMarkConfig : WaterMarkConfig
@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, assign) CGSize imageSize;
@property(nonatomic, assign) BOOL isKeepAspectRation;
@end
