import React, { 
	Component 
} from 'react';

import {
	TouchableHighlight,
	StyleSheet,
	Text,
	View,
} from 'react-native';

/**
 * AlbaButton
 */
export class AlbaButton extends Component {
	constructor(props) {
		super(props);
	}
	
	render() {
		
		var btnStyles = [JRButtonStyles.button];
		
		if (this.props.disabled) btnStyles.push(JRButtonStyles.disabled);
		
		return (
			<View style={JRButtonStyles.buttonContainer, this.props.styleOverrides}>
				<TouchableHighlight 
				 style={btnStyles}
				 onPress={this.props.onPress}
				 underlayColor={this.props.underlayColor}
				 disabled={this.props.disabled} >
					<Text style={JRButtonStyles.buttonText}>{this.props.text}</Text>
				</TouchableHighlight>
			</View>
		);
	}
}
AlbaButton.propTypes = {
	text: React.PropTypes.string,
	onPress: React.PropTypes.func,
	underlayColor: React.PropTypes.string,
	disabled: React.PropTypes.bool,
};
AlbaButton.defaultProps = {
	text: 'click me',
	onPress: React.PropTypes.func,
	underlayColor: '#f9dc91',
	disabled: false,
};

const JRButtonStyles = StyleSheet.create({
	buttonContainer: {
		//flex: 1,
		//flexDirection: 'column',
		//alignItems: 'flex-start',
		//margin: 15,
	},
	button: {
		//flex: 1,
		//flexWrap: 'wrap',
		//flexDirection: 'column',
		//backgroundColor: 'rgba(255,255,255,.7)',
		//borderRadius: 15,
		padding: 10,
		//paddingTop: 15,
		//paddingBottom: 15,
	},
	disabled: {
		opacity: .3,
	},
	buttonText: {
		//flexDirection: 'column',
		//flex: 1,
		//flexWrap: 'wrap',
	}
});