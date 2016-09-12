//
//  JRLibraryPlayer.m
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/12/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "JRLibraryPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation JRLibraryPlayer

AVAudioPlayer* _player;
float _currentRate;

-(AVAudioPlayer*) getPlayer {
	return _player;
}

-(void) setPlayer:(nonnull AVAudioPlayer*)player {
	_player = player;
}

-(float) getCurrentRate {
	if (!_currentRate) {
		return 1.0;
	}
	return _currentRate;
}

RCT_EXPORT_MODULE();

//
// getTracks
//
RCT_EXPORT_METHOD(getTracksAsync:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject) {

	//NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

	MPMediaQuery *songsQuery = [MPMediaQuery artistsQuery];
	NSMutableArray *mutableSongsToSerialize = [NSMutableArray array];
	
	if ([songsQuery.items count] > 0) {
	
		for (MPMediaItem *song in songsQuery.items) {

			//NSString *albumTitle =[song valueForProperty: MPMediaItemPropertyAlbumTitle];
			//NSString *albumArtist =[song valueForProperty: MPMediaItemPropertyAlbumArtist];
			//NSString *duration =[song valueForProperty: MPMediaItemPropertyPlaybackDuration];
			//NSString *genre =[song valueForProperty: MPMediaItemPropertyGenre];
			//NSString *playCount =[song valueForProperty: MPMediaItemPropertyPlayCount];
		
			NSString *albumArtist =[song valueForProperty: MPMediaItemPropertyAlbumArtist];
			NSString *itemId = [[song valueForProperty: MPMediaItemPropertyPersistentID] stringValue];
			NSURL *url = [song valueForProperty: MPMediaItemPropertyAssetURL];
			NSString *title = [song valueForProperty: MPMediaItemPropertyTitle];
		
			if (itemId != nil && title != nil && url != nil) {
			
				if (albumArtist == nil)
					albumArtist = @"";
			
				NSString *path = [NSString stringWithFormat:@"%@",[url absoluteString]];
			
				NSDictionary *songDictionary = @{@"id": itemId, @"title": title, @"artist": albumArtist, @"path": path};
			
				[mutableSongsToSerialize addObject:songDictionary];
		
			} 
		}
	
		resolve(mutableSongsToSerialize);
	
	} else {
		NSError *error;
    reject(@"no_tracks", @"There were no tracks", error);
	}
}

//
// initQueue
//
//RCT_EXPORT_METHOD(initQueue:(nonnull NSString*)persistentID withCallback:(RCTResponseSenderBlock)callback) {
RCT_EXPORT_METHOD(initQueueAsync:(nonnull NSString*)persistentID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
	
	MPMediaQuery *songsQuery = [[MPMediaQuery alloc] init];
	NSArray *items = [songsQuery items];
	BOOL found = NO;
	MPMediaItem *song;
	
	for(MPMediaItem *item in items) {
			NSString *itemId = [[item valueForProperty: MPMediaItemPropertyPersistentID] stringValue];
			if([persistentID isEqualToString:itemId]) {
				found = YES;
				song = item;
				//break;
			}
	}
	
	if (found) {
		
		NSURL *url = [song valueForProperty:MPMediaItemPropertyAssetURL];
		NSError* error;
		AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		
		if (player) {
			
			[self setPlayer:player];
			player.delegate = self;
			player.numberOfLoops = -1;
			player.enableRate = YES;
			player.rate = [self getCurrentRate];
			[player prepareToPlay];
			//[[self playerPool] setObject:player forKey:key];
			//callback(@[[NSNull null], @{@"duration": @(player.duration),
			//                            @"numberOfChannels": @(player.numberOfChannels)}]);
			resolve(@[@{@"duration": @(player.duration), @"numberOfChannels": @(player.numberOfChannels)}]);
		
		} else {
			
			NSError *error;
			reject(@"no_player", @"failed to create player", error);
		
		}
		
	} else {
	
		NSError *error;
		reject(@"no_player", @"item not found", error); 
	
	}
}

//
// play
//
RCT_EXPORT_METHOD(playAsync:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer* player = [self getPlayer];
	
	if (player) {
		[player play];
		resolve(@"playing");
	} else {
		NSError *error;
		reject(@"no player",@"no player",error);
	}
}

//
// pause
//
RCT_EXPORT_METHOD(pauseAsync:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer* player = [self getPlayer];
	
	if (player) {
		[player pause];
		resolve(@"paused");
	} else {
		NSError *error;
		reject(@"no player",@"no player",error);
	}
}

//
// setRate
//
RCT_EXPORT_METHOD(setRateAsync:(nonnull NSNumber*)rate 
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer* player = [self getPlayer];
	
	if (player) {
		player.rate = [rate floatValue];
		resolve(@"set rate");
	} else {
		NSError *error;
		reject(@"no player",@"no player",error);
	}
	
	_currentRate = [rate floatValue];
	
}

@end
