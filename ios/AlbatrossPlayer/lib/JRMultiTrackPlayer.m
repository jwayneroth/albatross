//
//  JRMultiTrackPlayer.m
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/7/16.
//

#import "JRMultiTrackPlayer.h"
#import "AppDelegate.h"

@implementation JRMultiTrackPlayer

-(id)init {
	self = [super init];
	if (self) {
		_randID = arc4random_uniform(1000);
		_players = [[NSMutableArray alloc] init];
		_playerID = 0;
	}
	
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	NSError *setCategoryError = nil;
	
	if (![session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError]) {
		NSLog(@"%@", [setCategoryError localizedDescription]);
	}
	
	return self;
}

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;
@synthesize randID = _randID;
@synthesize players = _players;
@synthesize playerID = _playerID;

//
// showMediaPicker
//
-(void) showMediaPicker:(NSInteger)playerID  {
	
	self.playerID = playerID;
	
	if(self.mediaPicker == nil) {
		
		self.mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];//MPMediaTypeMusic];
	
		[self.mediaPicker setDelegate:self];
		[self.mediaPicker setAllowsPickingMultipleItems:NO];
		[self.mediaPicker setShowsCloudItems:NO];
		self.mediaPicker.prompt = @"Select song";
	}
	
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[delegate.rootViewController presentViewController:self.mediaPicker animated:YES completion:nil];
	
}

//
// mediaPicker
//
-(void) mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	
	MPMediaItem *mediaItem = mediaItemCollection.items[0];
	
	NSURL *assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
	
	NSDictionary *evtObject = @{@"artist": [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist],
                              @"title" : [mediaItem valueForProperty:MPMediaItemPropertyTitle],
                             @"player" : [NSNumber numberWithInteger:self.playerID]
	};
	
	[self.bridge.eventDispatcher sendAppEventWithName:@"SongPlaying" body:evtObject];
	                                                    
	NSError *error;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
	float rate;
	float volume;
	float pan;
	
	if ([self.players count] > self.playerID) {
		AVAudioPlayer *oldPlayer = [self.players objectAtIndex:self.playerID];
		rate = oldPlayer.rate;
		volume = oldPlayer.volume;
		pan = oldPlayer.pan;
		[self.players replaceObjectAtIndex:self.playerID withObject:player];
	} else {
		rate = 1.0;                                                                                                                  
		volume = 1.0;
		pan = 0;
		[self.players addObject:player];
	}
	
	[player setDelegate:self];
	player.numberOfLoops = -1;
	player.enableRate = YES;
	player.rate = rate;
	player.volume = volume;
	player.pan = pan;
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	} else {
		[player prepareToPlay];
		[player play];
		if (!self.timer) {
			self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 
			                                              target:self 
			                                            selector:@selector(timerUpdate) 
			                                            userInfo:nil 
			                                             repeats:YES];
		}
	}
	
	hideMediaPicker();
	
}

//
// timerUpdate
//
- (void)timerUpdate {
	
	NSLog(@"timerUpdate");
	
	//float progress = self.audioPlayer.currentTime;
	//[self.seekbar setValue:progress];
	
	for (AVAudioPlayer *player in self.players) {
		if (player.playing == YES) {
			NSLog(@"player x is at %f", player.currentTime);
		}
	}
}

//
// mediaPickerDidCancel
//
-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	hideMediaPicker();
}

//
// hideMediaPicker
//
void hideMediaPicker() {
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

//
// showPicker
//
RCT_EXPORT_METHOD(showPicker:(NSInteger)playerID) {
	[self showMediaPicker:playerID];
}

//
// setRateAsync
//
RCT_EXPORT_METHOD(setRateAsync:(nonnull NSNumber*)rate 
                     forPlayer:(NSInteger)playerID
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer *player;
	
	if ([self.players count] > playerID) {
		player = [self.players objectAtIndex:playerID];
	}
	
	if (player) {
		player.rate = [rate floatValue];
		NSLog(@"setRate %f for player %@", [rate floatValue], [NSNumber numberWithInteger:playerID]);
		resolve(@"set rate");
	}
}

//
// setVolAsync
//
RCT_EXPORT_METHOD(setVolAsync:(nonnull NSNumber*)volume 
                     forPlayer:(NSInteger)playerID
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer *player;
	
	if ([self.players count] > playerID) {
		player = [self.players objectAtIndex:playerID];
	}
	
	if (player) {
		player.volume = [volume floatValue];
		resolve(@"set vol");
	}
}

//
// setPanAsync
//
RCT_EXPORT_METHOD(setPanAsync:(nonnull NSNumber*)pan 
                     forPlayer:(NSInteger)playerID
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer *player;
	
	if ([self.players count] > playerID) {
		player = [self.players objectAtIndex:playerID];
	}
	
	if (player) {
		player.pan = [pan floatValue];
		resolve(@"set pan");
	}
}

//
// stopPlayerByID
//
RCT_EXPORT_METHOD(stopPlayerByID:(NSInteger)playerID
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	AVAudioPlayer *player;
	
	if ([self.players count] > playerID) {
		player = [self.players objectAtIndex:playerID];
	}
	
	if (player) {
		
		[player stop];
		player.currentTime = 0;
		player.rate = 1.0;                                                                                                                  
		player.volume = 1.0;
		player.pan = 0;
		//[self.players removeObjectAtIndex:playerID];
		resolve(@"stopped player");
		
		// if no players playing, kill our timer
		BOOL playing = NO;
		for (AVAudioPlayer *player in self.players) {
			if (player.playing == YES) {
				playing = YES;
			}
		}
		if (!playing) {
			[self.timer invalidate];
			self.timer = nil;
		}
	}
}

//
// findAlbatross
//
RCT_EXPORT_METHOD(findAlbatross:(NSInteger)playerID
                       resolver:(RCTPromiseResolveBlock)resolve
                       rejecter:(RCTPromiseRejectBlock)reject) {
	
	NSLog(@"findAlbatross::%zd", self.randID);
	
	MPMediaQuery *songsQuery = [[MPMediaQuery alloc] init];
	NSArray *items = [songsQuery items];
	
	for(MPMediaItem *item in items) {
			
		NSString *albumArtist =[item valueForProperty: MPMediaItemPropertyAlbumArtist];
		NSString *title = [item valueForProperty: MPMediaItemPropertyTitle];
		
		if([albumArtist isEqualToString:@"Fleetwood Mac"] && [title isEqualToString:@"Albatross"]) {
		
			NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
			
			NSDictionary *evtObject = @{@"artist": albumArtist,
                                  @"title" : title,
                                 @"player" : [NSNumber numberWithInteger:playerID]
			};
	
	[self.bridge.eventDispatcher sendAppEventWithName:@"SongPlaying" body:evtObject];
			
			NSError *error;
			AVAudioPlayer *player;
			
			player = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
			float rate;
			
			if ([self.players count] > self.playerID) {
				AVAudioPlayer *oldPlayer = [self.players objectAtIndex:self.playerID];
				rate = oldPlayer.rate;
				[self.players replaceObjectAtIndex:self.playerID withObject:player];
			} else {
				rate = 1.0;
				[self.players addObject:player];
			}
			
			[player setDelegate:self];
			player.numberOfLoops = -1;
			player.enableRate = YES;
			player.rate = rate;
			
			if (error) {
				reject(@"no_albatross", @"albatross not found", error); 
			} else {
				[player prepareToPlay];
				[player play];
				resolve(@[@{@"duration": @(player.duration), @"numberOfChannels": @(player.numberOfChannels)}]);
			}
			
			return;
			
		}
	}
		
	NSError *error;
	reject(@"no_alabatross", @"albatross not found", error); 
	
}

@end
