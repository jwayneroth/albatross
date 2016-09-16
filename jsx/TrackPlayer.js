import React, {
	Component
} from 'react';

import {
	Slider,
	StyleSheet,
	Text,
	View,
	Dimensions,
	NativeAppEventEmitter
} from 'react-native';

import {AlbaButton} from './AlbaButton.js';

var JRMultiTrackPlayer = require('NativeModules').JRMultiTrackPlayer;

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

		this.timeSliderDefaults = {
			minimumValue: 0,
			maximumValue: 100,
			step: 1
		};

		this.state = {
			rateSliderDisabled: true,
			rateSliderVal: 1.0,
			volSliderDisabled: true,
			panSliderDisabled: true,
			timeSliderDisabled: true,
			volSliderVal: 1.0,
			timeSliderVal: 0,
			panSliderVal: 0,
			timeSliderMax: this.timeSliderDefaults.maximumValue,
			songPlaying: false,
			songInfo: {
				title: '',
				artist: '',
				duration: '',
			}
		};

		/*if (this.props.index == 0) {
			JRMultiTrackPlayer.findAlbatross(this.props.index).then((success) => {
				console.log('found albatross :)');
			}, (error) => {
				console.log('no albatross :(');
			});
		}*/
	}

	componentWillMount() {

		this.playerSubscription = NativeAppEventEmitter.addListener('SongPlaying', (evt) => {

			if (evt.player == this.props.index) {

				console.log('SongPlaying', evt);
				
				var dm = parseInt(evt.duration / 60);
				var ds = parseInt(evt.duration % 60);
				if (ds < 10) ds  = '0' + ds;
				
				this.setState({
					songPlaying: true,
					songInfo: {
						title: evt.title,
						artist: evt.artist,
						duration: dm + ':' + ds,
					},
					rateSliderDisabled: false,
					volSliderDisabled: false,
					panSliderDisabled: false,
					timeSliderMax: evt.duration,
				});

				this.playingSubscription = NativeAppEventEmitter.addListener('PlayingUpdate', (evt) => {

					//console.log('PlayingUpdate', evt);

					var i = 0,
					    update;
					
					for(i; i<evt.players.length; i++) {
						
						update  = evt.players[i];
						
						if (update.player == this.props.index) {
							
							//if (this.props.index == 0) console.log(update);
							
							this.setState({
								timeSliderVal: update.currentTime
							});
						
						}
					}
				});
			}
		});
	}

	componentWillUnmount() {

		JRMultiTrackPlayer.stopPlayerByID(this.props.index).then((success) => {
			console.log('stopPlayerByID success', success);
		}, (error) => {
			console.error('stopPlayerByID error', error);
		});

		if (this.playerSubscription) this.playerSubscription.remove();
		if (this.playingSubscription) this.playingSubscription.remove();

	}

	_onRateUpdate(val) {

		this.setState({rateSliderVal: val});

		JRMultiTrackPlayer.setRateAsync(val, this.props.index).then((success) => {
			//console.log('setRate success', success);
		}, (error) => {
			console.error('setRate error', error);
		});
	}

	_onVolUpdate(val) {

		this.setState({volSliderVal: val});

		JRMultiTrackPlayer.setVolAsync(val, this.props.index).then((success) => {
			//console.log('setVol success', success);
		}, (error) => {
			console.error('setVol error', error);
		});
	}

	_onPanUpdate(val) {

		this.setState({panSliderVal: val});

		JRMultiTrackPlayer.setPanAsync(val, this.props.index).then((success) => {
			//console.log('setVol success', success);
		}, (error) => {
			console.error('setPan error', error);
		});
	}

	_onSelectButtonClick() {
		JRMultiTrackPlayer.showPicker(this.props.index);
	}

	render() {

		var {height, width} = Dimensions.get('window');
		var playing = this.state.songPlaying;
		var playingText = (!this.state.songPlaying) ? '' :
		                                               this.state.songInfo.artist +
		                                               ' "' + this.state.songInfo.title + '"';
		var buttonText = (!this.state.songPlaying) ? 'pick a song' : 'change song';
		var currentRate = 'Rate: ' + this.state.rateSliderVal.toFixed(2);
		var currentVol = 'Vol: ' + this.state.volSliderVal.toFixed(2);
		var currentPan = 'Pan: ' + this.state.panSliderVal.toFixed(2);
		var currentTimeText = '';
		if (this.state.timeSliderVal) {
			var cm = parseInt(this.state.timeSliderVal / 60);
			var cs = parseInt(this.state.timeSliderVal % 60, 10);
			if (cs < 10) cs = '0' + cs;
			currentTimeText = cm + ':' + cs + ' / ' + this.state.songInfo.duration;
		}
		return (
			<View style={JRTrackPlayerStyles.container}>
				<Text style={JRTrackPlayerStyles.playing}>{playingText}</Text>
				<Text style={JRTrackPlayerStyles.info}>{currentTimeText}</Text>
				<Slider
					style={JRTrackPlayerStyles.slider, JRTrackPlayerStyles.timeSlider}
					{...Object.assign(this.timeSliderDefaults, {maximumValue: this.state.timeSliderMax})}
					value = {this.state.timeSliderVal}
					disabled = {this.state.timeSliderDisabled}/>
				<View style={JRTrackPlayerStyles.controlsRow}>
					<View style={JRTrackPlayerStyles.slidersContainer}>
						<Text style={JRTrackPlayerStyles.info}>{currentRate}</Text>
						<Slider
							style={JRTrackPlayerStyles.slider}
							{...this.rateSliderDefaults}
							value = {this.state.rateSliderVal}
							disabled = {this.state.rateSliderDisabled}
							onSlidingComplete={this._onRateUpdate.bind(this)} />
						<Text style={JRTrackPlayerStyles.info}>{currentVol}</Text>
						<Slider
							style={JRTrackPlayerStyles.slider}
							{...this.volSliderDefaults}
							value = {this.state.volSliderVal}
							disabled = {this.state.volSliderDisabled}
							onSlidingComplete={this._onVolUpdate.bind(this)} />
						<Text style={JRTrackPlayerStyles.info}>{currentPan}</Text>
						<Slider
							style={JRTrackPlayerStyles.slider}
							{...this.panSliderDefaults}
							value = {this.state.panSliderVal}
							disabled = {this.state.panSliderDisabled}
							onSlidingComplete={this._onPanUpdate.bind(this)} />
					</View>
					<View style={JRTrackPlayerStyles.buttonsContainer}>
						<AlbaButton
						 onPress={this.props.onHide}
						 text={'- remove track'} />
						<AlbaButton
						 onPress={this._onSelectButtonClick.bind(this, this.props.index)}
						 text={buttonText} />
					</View>
				</View>
			</View>
		);

	}
}
TrackPlayer.propTypes = {
	index: React.PropTypes.number.isRequired,
	onHide: React.PropTypes.func.isRequired,
};
TrackPlayer.defaultProps = {

};

let { height, width } = Dimensions.get('window');
const ww = (width < height) ? width: height;

const JRTrackPlayerStyles = StyleSheet.create({
	container: {
		flex: 1,
		alignItems: 'flex-start',
		//margin: 15,
		//marginTop: 0,
		//marginBottom: 5,
		backgroundColor: 'rgba(255,255,255,.7)',
		borderBottomWidth: 1,
		borderBottomColor: 'rgba(0,0,0,.3)',
		padding: 12,
		paddingTop: 5,
		position: 'relative',
	},
	playing: {
		//margin: 5,
		backgroundColor: 'transparent',
	},
	controlsRow: {
		flex: 1,
		flexDirection: 'row',
		//borderRadius: 15,
		//padding: 15,
		//margin: 0,
		//marginTop: 5
	},
	slidersContainer: {
		width: .65 * ww,
	},
	slider: {
		height: 18,
	},
	timeSlider: {
		//width: ww,
		alignSelf: 'stretch',
	},
	butttonsContainer: {
		width: .35 * ww,
	}
});