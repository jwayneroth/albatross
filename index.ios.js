/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { 
	Component 
} from 'react';

import {
	ScrollView,
	TouchableHighlight,
	AppRegistry,
	StyleSheet,
	Text,
	View,
	Image,
} from 'react-native';

import {TrackPlayer} from './jsx/TrackPlayer.js';
import {AlbaButton} from './jsx/AlbaButton.js';

class AlbatrossPlayer extends Component {

	constructor(props) {
		super(props);
		
		this.trackLimit = 5;
		
		this.state = {
			tracks: []
		};
	}
	
	componentWillMount() {
		this._addNewTrack();
	}
	
	_checkAddTrack() {
		
		// do we have any inactive tracks
		var i = 0,
		    idx = 0,
		    tracks = this.state.tracks;
		    
		for (i;i<tracks.length;i++) {
			if (!tracks[i].active) {
				tracks[i].active = true;
				this.setState({
					tracks: tracks
				});
				return
			}
		}
		
		// if no, check if we can add a new track
		if (tracks.length < this.trackLimit) this._addNewTrack();
		
	}
	
	_getActiveTracks() {
		
		var i = 0, 
		    cnt = 0
		    tracks = this.state.tracks;
		    
		for (i;i<tracks.length;i++) {
			if (tracks[i].active) {
				cnt++;
			}
		}
		
		return cnt;
		
	}
	
	_addNewTrack() {
		
		console.log('_addNewTrack',  this.state.tracks);
		
		var tracks = this.state.tracks;
		
		tracks.push({
			active: true
		})
		
		this.setState({
			tracks: tracks
		});
	}
	
	_onTrackHidden(idx) {
		
		console.log('_onTrackHidden', idx);
		
		var tracks = this.state.tracks;
		
		tracks[idx].active = false;
	
		this.setState({
			tracks: tracks
		});
	}
	
	render() {
		
		var active = this._getActiveTracks(),
		    btnState = !(active < this.trackLimit),
		    i = 0,
		    tracks = this.state.tracks,
		    out = new Array();
		    
		console.log('render', active);
		
		for(i;i<tracks.length;i++) {
			if (tracks[i].active) {
				out.push(<TrackPlayer index={i} 
				                         key={i}
				                         onHide={this._onTrackHidden.bind(this, i)} />);
			}
		}
		
		return (
			<View style={AlbaStyles.container}>
				<View style={AlbaStyles.bgWrapper}>
					<Image 
					 source={require('./assets/albatross-bg.jpg')}  
					 resizeMode={Image.resizeMode.cover}
					 style={AlbaStyles.bgImage} />
				</View>
				<AlbaButton 
				 text={'add track'}
				 disabled={btnState}
				 onPress={this._checkAddTrack.bind(this)} />
				<ScrollView
				 style={AlbaStyles.scrollView}>
					{out.reverse()}
				</ScrollView>
			</View>
		);
		
	}
}

AppRegistry.registerComponent('AlbatrossPlayer', () => AlbatrossPlayer);

const AlbaStyles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'flex-start',
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
	scrollView: {
		flex: 1,
		alignSelf: 'stretch',
	}
});
