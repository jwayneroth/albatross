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
			trackCount: 1,
		};
		
		this.styles = StyleSheet.create({
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
	}
	
	_addTrack() {
		console.log('addTrack ' + this.state.trackCount);
		this.setState({
			trackCount: this.state.trackCount+1
		});
	}
	
	render() {
		
		var btnState = !(this.state.trackCount < this.trackLimit),
		    i = 0,
		    tracks = [];
		    
		for(i;i<this.state.trackCount;i++) {
			tracks.push(<TrackPlayer index={i} key={i} />);
		}
		
		return (
			<View style={this.styles.container}>
				<View style={this.styles.bgWrapper}>
					<Image 
					 source={require('./assets/albatross-bg.jpg')}  
					 resizeMode={Image.resizeMode.cover}
					 style={this.styles.bgImage} />
				</View>
				<AlbaButton 
				 text={'add track'}
				 disabled={btnState}
				 onPress={this._addTrack.bind(this)} />
				<ScrollView
				 style={this.styles.scrollView}>
					{tracks.reverse()}
				</ScrollView>
			</View>
		);
		
	}
}

AppRegistry.registerComponent('AlbatrossPlayer', () => AlbatrossPlayer);
