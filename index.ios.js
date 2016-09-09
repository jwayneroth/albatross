/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { 
	Component 
} from 'react';

import {
	TouchableHighlight,
	AppRegistry,
	StyleSheet,
	Text,
	View,
	Image,
} from 'react-native';

import {TrackPlayer} from './jsx/TrackPlayer.js';

class AlbatrossPlayer extends Component {

	constructor(props) {
		super(props);
		
		this.state = {
			
		};
	};
	
	render() {
		
		return (
			<View style={styles.container}>
				<View style={styles.bgWrapper}>
					<Image 
					 source={require('./assets/albatross-bg.jpg')}  
					 resizeMode={Image.resizeMode.cover}
					 style={styles.bgImage} />
				</View>
				<TrackPlayer></TrackPlayer>
				<TrackPlayer></TrackPlayer>
			</View>
		);
		
	};
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: 'column',
		//justifyContent: 'center',
		//alignItems: 'center',
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
});

AppRegistry.registerComponent('AlbatrossPlayer', () => AlbatrossPlayer);
