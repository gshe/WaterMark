//
//  ThumbnailCollectionViewItem.m
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "ThumbnailCollectionViewItem.h"

@interface ThumbnailCollectionViewItem ()

@end

@implementation ThumbnailCollectionViewItem

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
  self.view.layer.borderWidth = 0.0;
  self.view.layer.backgroundColor = [NSColor blackColor].CGColor;
}

- (void)setHightLight:(Boolean)isSelected {
  self.view.layer.borderWidth = 5.0;
  [self.view setNeedsDisplay:YES];
}

@end
