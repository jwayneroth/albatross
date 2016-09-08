/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { 
	Component 
} from 'react';

import {
	ListView,
	TouchableHighlight,
	//PickerIOS,
	Slider,
	AppRegistry,
	StyleSheet,
	Text,
	View,
	Image,
	NativeAppEventEmitter
} from 'react-native';

//var PickerItemIOS = PickerIOS.Item;
var LibraryPlayer = require('NativeModules').LibraryPlayer;
var MediaController = require('NativeModules').MediaController;

var sliderDefaults = {
	minimumValue: 0.5,
	maximumValue: 2.0,
	step: 0.2
}

var buttonDefaults = {
	underlayColor: '#f9dc91'
}

class AlbatrossPlayer extends Component {

	constructor(props) {
		super(props);
		
		//console.log('constructor::', this);
		
		this.state = {
			tracks: null,
			selectedTrack: '',
			loadingTracks: true,
			rateSliderActive: false,
			rateSliderVal: 1.0,
			songPlaying : 'No Song Selected'
		};
		
		//this._getTracks();
		
		MediaController.findAlbatross().then((success) => {
			console.log('found albatross :)');
		}, (error) => {
			console.log('no albatross :(');
		});
		
	};
	
	componentDidMount() {
		// Add Event Listener for SongPlaying event from MediaController
		NativeAppEventEmitter.addListener('SongPlaying', (songName) => this.setState({songPlaying : songName}))
	}

	/*async _getTracks() {
		try {
			tracks = await LibraryPlayer.getTracksAsync();
			var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
			this.setState({
				tracks: ds.cloneWithRows(tracks),
				loadingTracks: false,
			});
		} catch(e) {
			console.error(e);
		}
	};*/
	
	_getTracks() {
		
		var home = this;
		
		LibraryPlayer.getTracksAsync().then(function(tracks) {
			console.log('getTracksAsync success'); //, tracks);
			
			var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
			
			home.setState({
				tracks: ds.cloneWithRows(tracks),
				loadingTracks: false,
			});
			
		}, function(response) {
			console.log('getTracksAsync failure', response);
		});
	}
	
	_onPressButton(rowData: string, sectionID: number, rowID: number) {
		
		this.setState({selectedTrack: rowData.artist + ' / ' + rowData.title});
		
		LibraryPlayer.initQueueAsync(rowData.id).then((success) => {
			
			console.log('initQueue success', success);
			
			LibraryPlayer.playAsync().then((success) => {
				console.log('play success');
			}, (error) => {
				console.error('play error');
			});
			
		}, (error) => {
			console.error('initQueue error', error);
		});
	};
	
	_renderRow(rowData: string, sectionID: number, rowID: number) {
		//console.log(rowData.title);
		return (
			<TouchableHighlight onPress={() => {
				this._onPressButton(rowData, sectionID, rowID);
			}}>
				<View style={styles.row}>
					<Text style={styles.artist}>{rowData.artist}</Text>
					<Text>{rowData.title}</Text>
				</View>
			</TouchableHighlight>
		);
	};
	
	_onRateUpdate(val) {
		
		this.setState({rateSliderVal: val});
		
		MediaController.setRateAsync(val).then((success) => {
			
			//console.log('setRate success', success);
			
		}, (error) => {
			console.error('setRate error', error);
		});
	};
	
	_onSelectButtonClick() {
		
		MediaController.showPicker();
		
	}
	
	render() {
	
		//console.log('//////////TestProject::render///////////');
		//console.log(this.state);
		
		var selectedNote = this.state.songPlaying;
		var currentRate = 'Rate: ' + this.state.rateSliderVal.toFixed(2);
		var buttonText = (this.state.songPlaying == 'No Song Selected') ? 'Pick a Song' : 'Pick a different song';
		
		return (
			<View style={styles.container}>
				<View style={styles.bgWrapper}>
					<Image 
					 source={require('./assets/albatross-bg.jpg')}  
					 resizeMode={Image.resizeMode.cover}
					 style={styles.bgImage} />
				</View>
				<Text style={styles.info}>{selectedNote}</Text>
				<View style={styles.rateWrapper}>
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
		);
		
		/*let pic = {uri: 'https://upload.wikimedia.org/wikipedia/commons/d/de/Bananavarieties.jpg'};
		
		if (this.state.loadingTracks) {
			return (
				<View style={styles.container}>
					<Text style={styles.instructions}>Loading</Text>
					<Image source={pic} style={styles.bananas}/>
				</View>
			);
		}
		
		var selectedNote = this.state.selectedTrack;
		var currentRate = 'Rate: ' + this.state.rateSliderVal;
		return (
			<View style={styles.container}>
				<Text style={styles.instructions}>{selectedNote}</Text>
				<Text style={styles.instructions}>{currentRate}</Text>
				<Slider 
					style={styles.slider, styles.picker }
					{...sliderDefaults}
					value = {this.state.rateSliderVal}
					disabled = {this.state.rateSliderActive}
					onSlidingComplete={(val) => this._onRateUpdate(val)} />
				<ListView 
					style={styles.picker}
					dataSource={this.state.tracks}
					renderRow={this._renderRow.bind(this)}
				/>
			</View>
		);*/
	};
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
		backgroundColor: '#f7f2e2',
	},
	bgWrapper: {
		position: 'absolute',
		top: 0, bottom: 0, left: 0, right: 0,
		flex: 1,
	},
	bgImage: {
		flex: 1,
		resizeMode: Image.resizeMode.cover,
		width: null,
		height: null
	},
	info: {
		margin: 15,
	},
	rateWrapper: {
		backgroundColor: 'rgba(255,255,255,.7)',
		borderRadius: 15,
		margin: 15,
		padding: 15,
		alignSelf: 'stretch',
		alignItems: 'center',
		marginTop: 120
	},
	rateInfo: {
	},
	slider: {
		alignSelf: 'stretch',
		//height: 10,
		//margin: 15,
		//marginTop: 0,
	},
	buttonWrapper: {
		marginTop: 150,
		alignSelf: 'stretch',
		alignItems: 'center',
	},
	button: {
		backgroundColor: 'rgba(255,255,255,.7)',
		borderRadius: 15,
		padding: 30,
		paddingTop: 15,
		paddingBottom: 15,
	},
	/*row: {
		flexDirection: 'column',
		justifyContent: 'center',
		padding: 10,
		backgroundColor: 'rgba(255,255,255,.3)',
	},
	artist: {
		fontWeight: '600',
	},
	welcome: {
		fontSize: 20,
		textAlign: 'center',
		margin: 10,
	},*/
	picker: {
		alignSelf: 'stretch',
	},
});

AppRegistry.registerComponent('AlbatrossPlayer', () => AlbatrossPlayer);
