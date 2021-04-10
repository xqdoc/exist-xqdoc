import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import { Link } from "react-router-dom";
import ReactMarkdown from 'react-markdown'
import gfm from 'remark-gfm'
import './App.css';

class ApplicationModules extends Component {
    render() {
        return (
            <h1>Application {this.props.match.params.applicationID}</h1>
        )
    }
}

export default ApplicationModules;
