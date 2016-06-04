//
//  WaterMarkPreviewViewController.m
//  WaterMark
//
//  Created by George She on 16/5/21.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "WaterMarkPreviewViewController.h"

@interface WaterMarkPreviewViewController () <NSWindowDelegate>
@property(weak) IBOutlet NSView *topContainerView;
@property(weak) IBOutlet NSImageView *previewImageView;

@end

@implementation WaterMarkPreviewViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.topContainerView.wantsLayer = YES;
  self.topContainerView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
}

- (void)viewWillAppear {
  [super viewWillAppear];
  self.previewImageView.image = self.previewImage;
}

- (IBAction)onSaveClicked:(id)sender {
  NSString *fileName = [self.file lastPathComponent];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:fileName];
  [panel setMessage:NSLocalizedString(@"Choose the path to save the document",
                                      @"")];
  [panel setAllowsOtherFileTypes:YES];
  [panel setExtensionHidden:YES];
  [panel setCanCreateDirectories:YES];
  [panel beginSheetModalForWindow:self.view.window
                completionHandler:^(NSInteger result) {
                  if (result == NSFileHandlingPanelOKButton) {
                    NSString *savePath = [[panel URL] path];
                    @autoreleasepool {
                      [self exportToFile:savePath];
                    }
                  }
                }];
}

- (IBAction)onCloseClicked:(id)sender {
  [NSApp endModalSession:self.modelSession];
  self.modelSession = nil;
}

- (void)exportToFile:(NSString *)savePath {
  NSBitmapImageRep *imgRep =
      (NSBitmapImageRep *)[[self.previewImage representations] objectAtIndex:0];

  NSData *tempdata =
      [imgRep representationUsingType:NSJPEGFileType properties:@{}];
  [tempdata writeToFile:savePath atomically:YES];
}

- (void)windowWillClose:(NSNotification *)notification {
  if (self.modelSession) {
    [NSApp endModalSession:self.modelSession];
  }
  self.modelSession = nil;
}
@end
