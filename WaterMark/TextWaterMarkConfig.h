//
//  TextWaterMarkConfig.h
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterMarkConfig.h"

@interface TextWaterMarkConfig : WaterMarkConfig
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSFont *font;
@property(nonatomic, strong) NSColor *color;
@end
