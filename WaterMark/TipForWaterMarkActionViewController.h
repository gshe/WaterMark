//
//  TipForWaterMarkActionViewController.h
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, TipAction) { TipAction_Edit, TipAction_Delete, TipAction_Cancel };

@protocol TipForWaterMarkActionViewControllerDelegate;

@interface TipForWaterMarkActionViewController : NSViewController
@property(nonatomic, weak) id originSender;
@property(nonatomic, weak)
    id<TipForWaterMarkActionViewControllerDelegate> delegate;
@end

@protocol TipForWaterMarkActionViewControllerDelegate <NSObject>
- (void)actionVC:(TipForWaterMarkActionViewController *)vc
        selected:(TipAction)action;
@end
