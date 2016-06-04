//
//  WaterMarkConfig.h
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WaterMarkConfig
@end

@interface WaterMarkConfig : NSObject

@end

@protocol WaterMarkConfigViewControllerDelegate <NSObject>
- (void)configVC:(NSViewController *)vc
    actionButtonClicked:(BOOL)isActiveButtonClick
                   data:(WaterMarkConfig *)cofigData;
@end
