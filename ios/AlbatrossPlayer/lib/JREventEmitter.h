//
//  JREventEmitter.h
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/12/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "RCTEventEmitter.h"

@interface JREventEmitter : RCTEventEmitter

+ (BOOL)application:(UIApplication *)application beaconSighted:(NSString *)beaconID;

@end