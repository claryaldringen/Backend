
import React from 'react'
import { sendRequest } from '../utils/request'

class SiteSelect extends React.Component{

	constructor(props) {
		super(props);
		this.state = {options: []}
	}

	change(event) {
		sendRequest('setSite', {id: event.target.value}, (response) => {
			window.location.reload();
		});
	}

	componentDidMount() {
		sendRequest('loadSites', {}, (response) => {
			this.setState({options: response});
		});
	}

	render() {

		let options = this.state.options.map( (value, index) => {
			return(<option value={value.id} key={'option_' + index}>{value.site}</option>);
		});

		return(
			<label>
				Doména:&nbsp;
				<select className="form-control" onChange={this.change.bind(this)}>{options}</select>
				&nbsp;&nbsp;
			</label>
		);
	}

}

module.exports = SiteSelect;