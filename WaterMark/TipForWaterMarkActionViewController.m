//
//  TipForWaterMarkActionViewController.m
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "TipForWaterMarkActionViewController.h"

@interface TipForWaterMarkActionViewController ()

@end

@implementation TipForWaterMarkActionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
}

- (IBAction)onEditPressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(actionVC:selected:)]) {
    [self.delegate actionVC:self selected:TipAction_Edit];
  }
}

- (IBAction)onDeletePressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(actionVC:selected:)]) {
    [self.delegate actionVC:self selected:TipAction_Delete];
  }
}
- (IBAction)onCancelPressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(actionVC:selected:)]) {
    [self.delegate actionVC:self selected:TipAction_Cancel];
  }
}

@end
