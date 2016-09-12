import React, { 
	Component 
} from 'react';

import {
	Slider,
	StyleSheet,
	Text,
	View,
	NativeAppEventEmitter
} from 'react-native';

import {AlbaButton} from './AlbaButton.js';

var MediaController = require('NativeModules').MediaController;

/**
 * TrackPlayer
 */
export class TrackPlayer extends Component {
	constructor(props) {
		super(props);
		
		console.log('TrackPlayer init ' + Math.random() * 1000);
		
		this.rateSliderDefaults = {
			minimumValue: 0.5,
			maximumValue: 2.0,
			step: 0.2
		};
		
		this.volSliderDefaults = {
			minimumValue: 0,
			maximumValue: 1.0,
			step: 0.2
		};
		
		this.panSliderDefaults = {
			minimumValue: -1.0,
			maximumValue: 1.0,
			step: 0.25
		};
		
		this.state = {
			tracks: null,
			selectedTrack: '',
			loadingTracks: true,
			rateSliderDisabled: false,
			rateSliderVal: 1.0,
			volSliderDisabled: false,
			volSliderVal: 1.0,
			panSliderDisabled: false,
			panSliderVal: 0,
			songPlaying : 'No Song Selected'
		};
		
		if (this.props.index == 0) {
			MediaController.findAlbatross(this.props.index).then((success) => {
				console.log('found albatross :)');
			}, (error) => {
				console.log('no albatross :(');
			});
		}
		
		this.styles = StyleSheet.create({
			container: {
				flex: 1,
				alignItems: 'flex-start',
				//margin: 15,
				//marginTop: 0,
				//marginBottom: 5,
			},
			playing: {
				//margin: 5,
				backgroundColor: 'transparent',
			},
			controlsRow: {
				flex: 1,
				flexDirection: 'row',
				backgroundColor: 'rgba(255,255,255,.7)',
				//borderRadius: 15,
				//padding: 15,
				//margin: 0,
				//marginTop: 5
			},
			slidersContainer: {
				flex: 2,
			},
			slider: {
			},
			butttonsContainer: {
				flex: 1,
			}
		});
	}
	
	componentDidMount() {
		var subscription = NativeAppEventEmitter.addListener('SongPlaying', (evt) => {
			console.log('SongPlaying', evt);
			if (evt.player == this.props.index) {
				this.setState({songPlaying : evt.artist + ' "' + evt.title + '"'})
			}
		});
	}
	
	componentWillUnmount() {
		subscription.remove();
	}
	
	_onRateUpdate(val) {
		
		this.setState({rateSliderVal: val});
		
		MediaController.setRateAsync(val, this.props.index).then((success) => {
			//console.log('setRate success', success);
		}, (error) => {
			console.error('setRate error', error);
		});
	}
	
	_onVolUpdate(val) {
		
		this.setState({volSliderVal: val});
		
		MediaController.setVolAsync(val, this.props.index).then((success) => {
			//console.log('setVol success', success);
		}, (error) => {
			console.error('setVol error', error);
		});
	}
	
	_onPanUpdate(val) {
		
		this.setState({panSliderVal: val});
		
		MediaController.setPanAsync(val, this.props.index).then((success) => {
			//console.log('setVol success', success);
		}, (error) => {
			console.error('setPan error', error);
		});
	}
	
	_onSelectButtonClick() {
		MediaController.showPicker(this.props.index);
	}
	
	render() {
		
		var playing = this.state.songPlaying;
		var currentRate = 'Rate: ' + this.state.rateSliderVal.toFixed(2);
		var currentVol = 'Vol: ' + this.state.volSliderVal.toFixed(2);
		var currentPan = 'Pan: ' + this.state.panSliderVal.toFixed(2);
		var buttonText = (this.state.songPlaying == 'No Song Selected') ? 'pick a song' : 'change song';
		
		return (
			<View style={this.styles.container}>
				<Text style={this.styles.playing}>{playing}</Text>
				<View style={this.styles.controlsRow}>
					<View style={this.styles.slidersContainer}>
						<Text style={this.styles.info}>{currentRate}</Text>
						<Slider 
							style={this.styles.slider}
							{...this.rateSliderDefaults}
							value = {this.state.rateSliderVal}
							disabled = {this.state.rateSliderDisabled}
							onSlidingComplete={this._onRateUpdate.bind(this)} />
						<Text style={this.styles.info}>{currentVol}</Text>
						<Slider 
							style={this.styles.slider}
							{...this.volSliderDefaults}
							value = {this.state.volSliderVal}
							disabled = {this.state.volSliderDisabled}
							onSlidingComplete={this._onVolUpdate.bind(this)} />
						<Text style={this.styles.info}>{currentPan}</Text>
						<Slider 
							style={this.styles.slider}
							{...this.panSliderDefaults}
							value = {this.state.panSliderVal}
							disabled = {this.state.panSliderDisabled}
							onSlidingComplete={this._onPanUpdate.bind(this)} />
					</View>
					<View style={this.styles.buttonsContainer}>
						<AlbaButton 
						 onPress={this._onSelectButtonClick.bind(this)}
						 text={buttonText} />
					</View>
				</View>
			</View>
		);
		
	}
}
TrackPlayer.propTypes = {
	index: React.PropTypes.number.isRequired,
};
TrackPlayer.defaultProps = {
	
};