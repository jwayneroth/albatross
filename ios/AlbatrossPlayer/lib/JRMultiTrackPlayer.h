//
//  JRMultiTrackPlayer.h
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/7/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTBridgeModule.h"

@import AVFoundation;

@interface JRMultiTrackPlayer : NSObject<RCTBridgeModule, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate>

//@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) MPMediaPickerController *mediaPicker;
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, assign) NSInteger randID;
@property (nonatomic, assign) NSInteger playerID;
@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, assign) BOOL playing;

//-(void) showMediaPicker:(NSInteger)playerID;

@end
