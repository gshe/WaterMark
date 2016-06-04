//
//  ImageWaterMarkConfigViewController.m
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "ImageWaterMarkConfigViewController.h"
#import "ImageWaterMarkConfig.h"

@interface ImageWaterMarkConfigViewController ()
@property(weak) IBOutlet NSTextField *imageFilePath;
@property(weak) IBOutlet NSTextField *imageWidth;
@property(weak) IBOutlet NSTextField *imageHeight;
@property(weak) IBOutlet NSView *bottomContainerView;
@property(weak) IBOutlet NSImageView *sampleImageView;
@property(weak) IBOutlet NSButton *keepAspectRation;

@end

@implementation ImageWaterMarkConfigViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.bottomContainerView.wantsLayer = YES;
  self.bottomContainerView.layer.backgroundColor =
      [NSColor darkGrayColor].CGColor;
}

- (void)viewWillAppear {
  if (self.existedConfig) {
    _imageFilePath.stringValue = self.existedConfig.imageUrl;
    _imageWidth.intValue = self.existedConfig.imageSize.width;
    _imageHeight.intValue = self.existedConfig.imageSize.height;
    self.sampleImageView.image =
        [[NSImage alloc] initWithContentsOfFile:self.existedConfig.imageUrl];
    self.keepAspectRation.state = self.existedConfig.isKeepAspectRation;
  } else {
    _imageWidth.intValue = 64;
    _imageHeight.intValue = 64;
    self.keepAspectRation.state = NSOnState;
  }
  [super viewWillAppear];
}

- (IBAction)onPressBrowser:(id)sender {
  NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
  openPanel.canChooseFiles = YES;
  openPanel.canChooseDirectories = NO;
  openPanel.canCreateDirectories = NO;
  [openPanel beginSheetModalForWindow:self.view.window
                    completionHandler:^(NSInteger result) {
                      NSString *path = [[openPanel URL] path];
                      _imageFilePath.stringValue = path;
                      self.sampleImageView.image =
                          [[NSImage alloc] initWithContentsOfFile:path];
                    }];
}

- (IBAction)onPressOk:(id)sender {
  if (_imageFilePath.stringValue == nil) {
    [self showAlert:@"Need Image"];
    return;
  }

  if (_imageWidth.intValue <= 0) {
    [self showAlert:@"Invaid Image Width"];
    return;
  }

  if (_imageHeight.intValue <= 0) {
    [self showAlert:@"Invaid Image Height"];
    return;
  }

  ImageWaterMarkConfig *data;
  if (self.existedConfig) {
    data = self.existedConfig;
  } else {
    data = [[ImageWaterMarkConfig alloc] init];
  }
  if (NSOnState == self.keepAspectRation.state) {
    data.isKeepAspectRation = YES;
  } else {
    data.isKeepAspectRation = NO;
  }
  data.imageUrl = _imageFilePath.stringValue;
  data.imageSize = CGSizeMake(_imageWidth.intValue, _imageHeight.intValue);
  if ([self.delegate
          respondsToSelector:@selector(configVC:actionButtonClicked:data:)]) {
    [self.delegate configVC:self actionButtonClicked:YES data:data];
  }
}

- (IBAction)onPressCancel:(id)sender {
  if ([self.delegate
          respondsToSelector:@selector(configVC:actionButtonClicked:data:)]) {
    [self.delegate configVC:self actionButtonClicked:NO data:nil];
  }
}

- (void)showAlert:(NSString *)title {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert setMessageText:title];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

@end
