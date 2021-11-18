import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import Navbar from 'react-bootstrap/Navbar';
import Button from 'react-bootstrap/Button';
import Spinner from 'react-bootstrap/Spinner';
import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"
import TreeMenu from 'react-simple-tree-menu'
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { HashRouter as Router, Link, Route, Switch } from "react-router-dom";
// import default minimal styling or your own styling
import '../node_modules/react-simple-tree-menu/dist/main.css';
import ReactMarkdown from 'react-markdown'
import gfm from 'remark-gfm'
import './App.css';
import ApplicationModules from "./ApplicationModules";
import LibraryModule from "./LibraryModule";

// <SwaggerClient
//     uri={'http://petstore.swagger.io/v2/swagger.json'}
//     authorizations: {{ petstore_auth: { token: { access_token: '234934239' } } } }
// ></SwaggerClient>


class App extends Component {

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
      <Router>
          <Navbar bg="dark" variant="dark" fixed="top">
              <Navbar.Brand href="./">
                  <img
                      id="logo"
                      alt=""
                      src="book.svg"
                      width="80"
                      height="40"
                  />{' '}XQuery Function Documentation</Navbar.Brand>
              <Navbar.Collapse className="justify-content-end">
                  <Button variant="secondary" onClick={this.regenerate} >
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
              <Row xs={1}>
                  <Col md={4} xl={3} xs={12} class="sidenav"
                  >
                      <TreeMenu
                          data={this.state.menu}
                          onClickItem={({key, label, ...props}) => {
                              console.log(key);
                              window.location.assign("/exist/apps/xqdoc/#/" + key);
                          }}
                      />
                  </Col>
                  <Col md={8} xl={7} xs={12}>
                      <Switch>
                          <Route path="/SwaggerUI">
                              <h1>Swagger</h1>
                              <SwaggerUI url="/exist/restxq/xqdoc/openapi"></SwaggerUI>
                          </Route>
                          <Route path="/Libraries/:libraryID" component={LibraryModule}/>
                          <Route path="/Applications/:applicationID" component={ApplicationModules}/>
                          <Route exact path="/">
                              <h1>Home</h1>
                          </Route>
                      </Switch>
                  </Col>
              </Row>
          </Container>
      </Router>
      )
  }
}

export default App;
