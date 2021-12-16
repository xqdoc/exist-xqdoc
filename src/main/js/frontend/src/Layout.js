import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import Navbar from "react-bootstrap/Navbar";
import packageJson from "../package.json";
import Button from "react-bootstrap/Button";
import Spinner from "react-bootstrap/Spinner";
import Container from "react-bootstrap/Container";
import { Outlet } from "react-router-dom";
import TreeMenu from "react-simple-tree-menu";
import '../node_modules/react-simple-tree-menu/dist/main.css';
import './App.css';


export default class Layout extends Component {

    constructor(props) {
        super(props);
        // Don't call this.setState() here!
        this.state = {
            isRegenerating: false,
            error: null,
            menu: []
        };
        this.regenerate = this.regenerate.bind(this);
    }

    componentDidMount() {
        fetch("/exist/restxq/xqdoc/menu")
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        isRegenerating: false,
                        error:null,
                        menu: result
                    })
                },
                (error) => {
                    this.setState({
                        isRegenerating: false,
                        error: error,
                        menu: []
                    })
                }
            )
    }

    regenerate() {
        this.setState({isRegenerating: true});
        fetch("modules/regenerate.xq")
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({isRegenerating: false})
                },
                (error) => {
                    this.setState({isRegenerating: false, error: error})
                }
            )
    }

    render() {
        return (
            <>
                <Navbar bg="dark" variant="dark" fixed="top">
                    <Navbar.Brand href="./">
                        <img
                            id="logo"
                            alt=""
                            src="book.svg"
                            width="80"
                            height="40"
                        />
                        {' '}
                        <span style={{fontSize: "24px"}}>XQuery Function Documentation</span>
                        {' '}
                        <span style={{fontSize: "8px"}}>Version {packageJson.version}</span>
                    </Navbar.Brand>
                    <Navbar.Collapse className="justify-content-end">
                        <Button variant="secondary" onClick={this.regenerate} style={{marginRight: 10}} >
                            {this.state.isRegenerating ?
                                <Spinner
                                    as="span"
                                    animation="grow"
                                    size="sm"
                                    role="status"
                                    aria-hidden="true"
                                />
                                : null}
                            Regenerate
                        </Button>
                    </Navbar.Collapse>
                </Navbar>
                <Container style={{marginTop: "70px"}} fluid>
                    <div style={{width: "100vw", height: "100vh", display: "flex", flexDirection: "row"}}>
                        <div style={{height: "100%", width: 300}}>
                            <TreeMenu
                                data={this.state.menu}
                                onClickItem={({key, label, ...props}) => {
                                    console.log(key);
                                    window.location.assign("/exist/apps/xqdoc/#/" + key);
                                }}
                            />
                        </div>
                        <div style={{height: "100%", width: "100%", marginLeft: 50}}>
                            <Outlet/>
                        </div>
                    </div>
                </Container>
            </>
        )
    }

}
