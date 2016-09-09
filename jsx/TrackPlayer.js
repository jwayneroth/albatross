/**
 * TrackPlayer
 */
 
import React, { 
	Component 
} from 'react';

import {
	TouchableHighlight,
	Slider,
	StyleSheet,
	Text,
	View,
	NativeAppEventEmitter
} from 'react-native';

var MediaController = require('NativeModules').MediaController;

var sliderDefaults = {
	minimumValue: 0.5,
	maximumValue: 2.0,
	step: 0.2
}

var buttonDefaults = {
	underlayColor: '#f9dc91'
}

export class TrackPlayer extends Component {
	constructor(props) {
		super(props);
		
		console.log('TrackPlayer init ' + Math.random() * 1000);
		
		this.MediaController = require('NativeModules').MediaController;
		
		this.state = {
			tracks: null,
			selectedTrack: '',
			loadingTracks: true,
			rateSliderActive: false,
			rateSliderVal: 1.0,
			songPlaying : 'No Song Selected'
		};
		
		MediaController.findAlbatross().then((success) => {
			console.log('found albatross :)');
		}, (error) => {
			console.log('no albatross :(');
		});
		
	}
	
	componentDidMount() {
		var subscription = NativeAppEventEmitter.addListener('SongPlaying', (songName) => {
			this.setState({songPlaying : songName})
		});
	}
	
	componentWillUnmount() {
		subscription.remove();
	}
	
	_onRateUpdate(val) {
		
		this.setState({rateSliderVal: val});
		
		MediaController.setRateAsync(val).then((success) => {
			//console.log('setRate success', success);
		}, (error) => {
			console.error('setRate error', error);
		});
	}
	
	_onSelectButtonClick() {
		MediaController.showPicker();
	}
	
	render() {
		
		var playing = this.state.songPlaying;
		var currentRate = 'Rate: ' + this.state.rateSliderVal.toFixed(2);
		var buttonText = (this.state.songPlaying == 'No Song Selected') ? 'Pick a Song' : 'Pick a different song';
		
		return (
			<View style={styles.container}>
				<Text style={styles.playing}>{playing}</Text>
				<View style={styles.controls}>
					<View style={styles.rate}>
						<Text style={styles.info, styles.rateInfo}>{currentRate}</Text>
						<Slider 
							style={styles.slider}
							{...sliderDefaults}
							value = {this.state.rateSliderVal}
							disabled = {this.state.rateSliderActive}
							onValueChange={(val) => this._onRateUpdate(val)} />
					</View>
					<View style={styles.buttonWrapper}>
						<TouchableHighlight 
						 style={styles.button}
						 {...buttonDefaults}
						 onPress={this._onSelectButtonClick}>
							<Text style={styles.instructions}>{buttonText}</Text>
						</TouchableHighlight>
				</View>
				</View>
			</View>
		);
		
	}
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'flex-start',
		margin: 15,
	},
	playing: {
		margin: 15,
		marginBottom: 5,
	},
	controls: {
		flexDirection: 'row',
		justifyContent: 'flex-start',
		//alignSelf: 'stretch',
		alignItems: 'flex-start',
		backgroundColor: 'rgba(255,255,255,.7)',
		borderRadius: 15,
		padding: 15,
		marginTop: 5
	},
	rate: {
		flex: 1,
		flexDirection: 'column',
	},
	slider: {
		alignSelf: 'stretch',
		flex: 1,
	},
	buttonWrapper: {
		flex: 1,
		alignSelf: 'stretch',
		alignItems: 'center',
	},
	button: {
		backgroundColor: 'rgba(255,255,255,.7)',
		borderRadius: 15,
		padding: 20,
		paddingTop: 15,
		paddingBottom: 15,
	},
});