//
//  JRLibraryPlayer.h
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/12/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RCTBridgeModule.h"

@interface JRLibraryPlayer : NSObject<RCTBridgeModule, AVAudioPlayerDelegate>

@end
