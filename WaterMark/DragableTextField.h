//
//  DragableTextField.h
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void (^DragableTextFieldDoubleClicked)(NSTextField *textField);

@interface DragableTextField : NSTextField
@property(nonatomic, copy) DragableTextFieldDoubleClicked doubleClickBlock;
@end
