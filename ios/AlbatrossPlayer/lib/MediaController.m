//
//  MediaController.m
//  AlbatrossPlayer
//
//  Created by Jason Roth on 9/7/16.
//

#import "MediaController.h"
#import "AppDelegate.h"

@implementation MediaController

float _currentRate;

-(float) getCurrentRate {
	if (!_currentRate) {
		return 1.0;
	}
	return _currentRate;
}

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

//
// showMediaPicker
//
-(void) showMediaPicker {
	
	if(self.mediaPicker == nil) {
		
		self.mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	
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
	
	[self.bridge.eventDispatcher sendAppEventWithName:@"SongPlaying" body:[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
	
	NSError *error;
	
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
	[self.player setDelegate:self];
	self.player.numberOfLoops = -1;
	self.player.enableRate = YES;
	self.player.rate = [self getCurrentRate];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	} else {
		[self.player prepareToPlay];
		[self.player play];
	}
	
	hideMediaPicker();
	
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
RCT_EXPORT_METHOD(showPicker) {
	[self showMediaPicker];
}

//
// setRateAsync
//
RCT_EXPORT_METHOD(setRateAsync:(nonnull NSNumber*)rate 
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {
	
	if (self.player) {
		self.player.rate = [rate floatValue];
		resolve(@"set rate");
	}
	
	_currentRate = [rate floatValue];
	
}

//
// findAlbatross
//
RCT_EXPORT_METHOD(findAlbatross:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject) {
	
	UInt32 category = kAudioSessionCategory_MediaPlayback;
	OSStatus result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	
	if (!result){
		NSLog(@"ERROR SETTING AUDIO CATEGORY!\n");
	}
	
	result = AudioSessionSetActive(true);
	if (!result) {
		NSLog(@"ERROR SETTING AUDIO SESSION ACTIVE!\n");
	}
	
	MPMediaQuery *songsQuery = [[MPMediaQuery alloc] init];
	NSArray *items = [songsQuery items];
	
	for(MPMediaItem *item in items) {
			
		NSString *albumArtist =[item valueForProperty: MPMediaItemPropertyAlbumArtist];
		NSString *title = [item valueForProperty: MPMediaItemPropertyTitle];
		
		if([albumArtist isEqualToString:@"Fleetwood Mac"] && [title isEqualToString:@"Albatross"]) {
		
			NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
			
			[self.bridge.eventDispatcher sendAppEventWithName:@"SongPlaying" body:title];
			
			NSError *error;
			
			self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
			[self.player setDelegate:self];
			self.player.numberOfLoops = -1;
			self.player.enableRate = YES;
			self.player.rate = [self getCurrentRate];
			
			if (error) {
				reject(@"no_albatross", @"albatross not found", error); 
			} else {
				[self.player prepareToPlay];
				[self.player play];
				resolve(@[@{@"duration": @(self.player.duration), @"numberOfChannels": @(self.player.numberOfChannels)}]);
			}
			
			return;
			
		}
	}
		
	NSError *error;
	reject(@"no_alabatross", @"albatross not found", error); 
	
}

@end
