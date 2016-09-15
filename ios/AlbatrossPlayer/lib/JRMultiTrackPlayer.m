//
//  JRMultiTrackPlayer.m
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/7/16.
//

#import "JRMultiTrackPlayer.h"
#import "AppDelegate.h"

@implementation JRMultiTrackPlayer

//
// init
//
-(id)init {

	self = [super init];

	if (self) {
		_randID = arc4random_uniform(1000);
		_players = [[NSMutableArray alloc] init];
		_playerID = 0;
	}

	// query if other audio is playing
	BOOL isPlayingWithOthers = [[AVAudioSession sharedInstance] isOtherAudioPlaying];

	// test it with...
	(isPlayingWithOthers) ? NSLog(@"other audio is playing") : NSLog(@"no other audio is playing");

	// set up AudioSession
	AVAudioSession *session = [AVAudioSession sharedInstance];

	NSError *setCategoryError = nil;

	if (![session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError]) {
		NSLog(@"%@", [setCategoryError localizedDescription]);
	}

	// register for notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(interruption:)
                                               name:AVAudioSessionInterruptionNotification
                                              object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(routeChange:)
                                              name:AVAudioSessionRouteChangeNotification
                                            object:nil];

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
	NSError *error;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
	
	if (error) {
		
		NSLog(@"%@", [error localizedDescription]);
	
	} else {
		
		NSLog(@"mediaPicker player created:player ID %@ current players %d", [NSNumber numberWithInteger:self.playerID], [self.players count]);
		
		NSDictionary *evtObject = @{@"artist": [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist],
																@"title" : [mediaItem valueForProperty:MPMediaItemPropertyTitle],
															 @"player" : [NSNumber numberWithInteger:self.playerID]
		};
		
		[self.bridge.eventDispatcher sendAppEventWithName:@"SongPlaying" body:evtObject];
		
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

	//NSLog(@"timerUpdate");

	//float progress = self.audioPlayer.currentTime;
	//[self.seekbar setValue:progress];
	
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	NSDictionary *active;
	int i = 0;

	for (AVAudioPlayer *player in self.players) {
		if (player.playing == YES) {

			//NSLog(@"player x is at %f", player.currentTime);

			active = @{@"player": [NSNumber numberWithInteger:i],
			      @"currentTime": [NSNumber numberWithInteger:player.currentTime]};
			
			[arr addObject:active];
			
		}
		i++;
	}
	
	NSDictionary *evtObject = @{@"players": arr};
	
	[self.bridge.eventDispatcher sendAppEventWithName:@"PlayingUpdate" body:evtObject];
	
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

- (void)interruption:(NSNotification*)notification {

	// get the user info dictionary
	NSDictionary *interuptionDict = notification.userInfo;

	// get the AVAudioSessionInterruptionTypeKey enum from the dictionary
	NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];

	// decide what to do based on interruption type here...
	switch (interuptionType) {
			case AVAudioSessionInterruptionTypeBegan:
					NSLog(@"Audio Session Interruption case started.");
					// fork to handling method here...
					// EG:[self handleInterruptionStarted];

					[self savePlayerStates];

					break;

			case AVAudioSessionInterruptionTypeEnded:
					NSLog(@"Audio Session Interruption case ended.");
					// fork to handling method here...
					// EG:[self handleInterruptionEnded];

					[self restartPlayers];

					break;

			default:
					NSLog(@"Audio Session Interruption Notification case default.");
					break;
	}
}

- (void)routeChange:(NSNotification*)notification {

	NSDictionary *interuptionDict = notification.userInfo;

	NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];

	switch (routeChangeReason) {
			case AVAudioSessionRouteChangeReasonUnknown:
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
					break;

			case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
					// a headset was added or removed
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
					break;

			case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
					// a headset was added or removed
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
					break;

			case AVAudioSessionRouteChangeReasonCategoryChange:
					// called at start - also when other audio wants to play
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");//AVAudioSessionRouteChangeReasonCategoryChange
					break;

			case AVAudioSessionRouteChangeReasonOverride:
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
					break;

			case AVAudioSessionRouteChangeReasonWakeFromSleep:
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
					break;

			case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
					NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
					break;

			default:
					break;
	}
}

//
// savePlayerStates
//
- (void) savePlayerStates {

	NSLog(@"savePlayerStates");

	int i = 0;

	for (AVAudioPlayer *player in self.players) {
		NSLog(@"player %d is at %f", i, player.currentTime);
		NSLog(@"player %d playing? : %@", i, (player.playing) ? @"YES" : @"NO");
		i++;
	}


}
//
// restartPlayers
//
- (void) restartPlayers {

	NSLog(@"restartPlayers");

	// set up AudioSession
	AVAudioSession *session = [AVAudioSession sharedInstance];

	NSError *setCategoryError = nil;

	if (![session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError]) {
		NSLog(@"%@", [setCategoryError localizedDescription]);
	}

	for (AVAudioPlayer *player in self.players) {
		NSLog(@"player x is at %f", player.currentTime);
		if (player.playing == NO) {
			[player play];
		}
	}

}

@end
