import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import { Link } from "react-router-dom";
import ReactMarkdown from 'react-markdown'
import gfm from 'remark-gfm'
import './App.css';

class LibraryModule extends Component {
    render() {
        return (
            <h1>Library {this.props.match.params.libraryID}</h1>
        )
    }
}

export default LibraryModule;
