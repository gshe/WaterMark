//
//  ViewController.m
//  WaterMark
//
//  Created by George She on 16/5/14.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "ViewController.h"
#import "DragDropView.h"
#import "PictureListViewController.h"
#import "EditWaterMarkViewController.h"

@interface ViewController ()
@property(weak) IBOutlet NSView *containerView;
@property(weak) IBOutlet DragDropView *dragAndDropView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self makeUI];
}

- (void)makeUI {
  self.containerView.wantsLayer = YES;
  self.containerView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;

  PTWeakSelf;
  _dragAndDropView.dragBlock = ^(NSArray *files) {
    PTStrongSelf;
    [self gotoEditWaterMarkViewController:files[0]];
  };
}

- (void)gotoEditWaterMarkViewController:(NSString *)file {
  EditWaterMarkViewController *vc = [[EditWaterMarkViewController alloc]
      initWithNibName:@"EditWaterMarkViewController"
               bundle:nil];
  vc.file = file;
  self.view.window.contentViewController = vc;
}

- (void)gotoMultiEditWaterMarkViewController:(NSArray *)files {
  NSStoryboard *story =
      [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

  PictureListViewController *myView =
      [story instantiateControllerWithIdentifier:@"picture"];
  myView.files = files;
  self.view.window.contentViewController = myView;
}

- (IBAction)onClickBrowseFile:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setMessage:@"Choose the path to save the document"];
  [panel setAllowsOtherFileTypes:YES];
  [panel setExtensionHidden:YES];
  [panel setCanCreateDirectories:NO];
  [panel beginSheetModalForWindow:self.view.window
                completionHandler:^(NSInteger result) {
                  if (result == NSFileHandlingPanelOKButton) {
                    NSString *path = [[panel URL] path];
                    [self gotoEditWaterMarkViewController:path];
                  }
                }];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
}

@end
