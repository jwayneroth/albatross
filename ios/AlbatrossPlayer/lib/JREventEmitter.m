//
//  JREventEmitter.m
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/12/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "JREventEmitter.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

NSString *const kSightedBeacon = @"GSEventEmitter/sightedBeacon";

@implementation JREventEmitter

RCT_EXPORT_MODULE();

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
  return @{@"SIGHTED_BEACON": kSightedBeacon};
}

- (NSArray<NSString *> *)supportedEvents {
  return @[kSightedBeacon];
}

- (void)startObserving {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleBeaconSightingNotification:)
                                               name:@"kBeaconSightingNotification"
                                             object:nil];
}

- (void)stopObserving {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)application:(UIApplication *)application beaconSighted:(NSString *)beaconID {
  NSDictionary<NSString *, id> *payload = @{@"payload": beaconID};
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"kBeaconSightingNotification"
                                                      object:self
                                                    userInfo:payload];
  return YES;
}

- (void)handleBeaconSightingNotification:(NSNotification *)notification {
  [self sendEventWithName:kSightedBeacon body:notification.userInfo];
}

@end
