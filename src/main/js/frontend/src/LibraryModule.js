import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from "react-router-dom";
import ReactMarkdown from 'react-markdown'
import gfm from 'remark-gfm'
import './App.css';

class LibraryModule extends Component {

    constructor(props) {
        super(props);
        // Don't call this.setState() here!
        this.state = {
            error: null,
            module: {
                response: {
                    uri: "",
                    control: {
                        location: ""
                    },
                    comment: {
                        description: ""
                    },
                    dummy: []
                }
            }
        }
    }

    componentDidMount() {
        fetch("/exist/restxq/xqdoc/library/" + this.props.match.params.libraryID)
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        error:null,
                        module: result
                    })
                },
                (error) => {
                    this.setState({
                        error: error,
                        module: {
                            response: {
                                uri: "",
                                control: {
                                    location: ""
                                },
                                comment: {
                                    description: ""
                                },
                                dummy: []
                            }
                        }
                    })
                }
            )
    }

    componentDidUpdate(prevProps, prevState, snapshot) {
        if (prevProps.match.params.libraryID !== this.props.match.params.libraryID) {
            fetch("/exist/restxq/xqdoc/library/" + this.props.match.params.libraryID)
                .then(res => res.json())
                .then(
                    (result) => {
                        this.setState({
                            error:null,
                            module: result
                        })
                    },
                    (error) => {
                        this.setState({
                            error: error,
                            module: {
                                response: {
                                    uri: "",
                                    control: {
                                        location: ""
                                    },
                                    comment: {
                                        description: ""
                                    },
                                    dummy: []
                                }
                            }
                        })
                    }
                )
        }
    }

    render() {
        const listItems = this.state.module.response.dummy.map((bod) =>
            <Card>
                <Card.Header>{this.state.module.response.name}:{bod.name}</Card.Header>
                <Card.Body>
                    <Card.Text>
                        <ReactMarkdown source={bod.comment.description} />
                    </Card.Text>
                </Card.Body>
            </Card>
        );
        return (
            <>
                <Card>
                    <Card.Header>{this.state.module.response.control.location}</Card.Header>
                    <Card.Body>
                        <Card.Title>{this.state.module.response.uri}</Card.Title>
                        <Card.Text>
                            <ReactMarkdown source={this.state.module.response.comment.description} />
                        </Card.Text>
                    </Card.Body>
                </Card>
                {listItems}
            </>
        )
    }
}

export default LibraryModule;
