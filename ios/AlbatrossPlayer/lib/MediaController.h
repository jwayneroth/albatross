//
//  MediaController.h
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/7/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

#import <MediaPlayer/MediaPlayer.h>

@import AVFoundation;

@interface MediaController : NSObject<RCTBridgeModule,MPMediaPickerControllerDelegate, AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) MPMediaPickerController *mediaPicker;

- (void) showMediaPicker;

@end
