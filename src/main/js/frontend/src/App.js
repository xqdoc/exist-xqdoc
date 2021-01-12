import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import Navbar from 'react-bootstrap/Navbar';
import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"
import TreeMenu from 'react-simple-tree-menu'
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { HashRouter as Router, Link, Route, Switch } from "react-router-dom";
// import default minimal styling or your own styling
import '../node_modules/react-simple-tree-menu/dist/main.css';
import './App.css';

// <SwaggerClient
//     uri={'http://petstore.swagger.io/v2/swagger.json'}
//     authorizations: {{ petstore_auth: { token: { access_token: '234934239' } } } }
// ></SwaggerClient>


function App() {
    const treeData = [
        {
            key: 'SwaggerUI',
            label: 'Rest APIs'
        },
        {
            key: 'Applications',
            label: 'Applications',
            nodes: [
                {key: "dashboard", label: "dashboard"},
                {key: "doc", label: "doc"},
                {key: "eXide", label: "eXide"},
                {key: "fundocs", label: "fundocs"},
                {key: "markdown", label: "markdown"},
                {key: "monex", label: "monex"},
                {key: "packageservice", label: "packageservice"},
                {key: "shared-resources", label: "shared-resources"},
                {key: "xqdoc", label: "xqDoc"}
            ]
        },
        {
            key: 'Libraries',
            label: 'Libraries',
            nodes: [{
                "key": "http:~~www.w3.org~2005~xpath-functions~array",
                "label": "array"
            },{
                "key": "http:~~exist-db.org~xquery~backups",
                "label": "backups"
            },{
                "key": "http:~~exist-db.org~xquery~cache",
                "label": "cache"
            },{
                "key": "http:~~exist-db.org~xquery~compression",
                "label": "compression"
            },{
                "key": "http:~~exist-db.org~xquery~console",
                "label": "console"
            },{
                "key": "http:~~exist-db.org~xquery~contentextraction",
                "label": "contentextraction"
            },{
                "key": "http:~~exist-db.org~xquery~counter",
                "label": "counter"
            },{
                "key": "http:~~exist-db.org~xquery~cqlparser",
                "label": "cqlparser"
            },{
                "key": "http:~~exquery.org~ns~restxq~exist",
                "label": "exrest"
            },{
                "key": "http:~~exist-db.org~xquery~file",
                "label": "file"
            },{
                "key": "http:~~www.w3.org~2005~xpath-functions",
                "label": "fn"
            },{
                "key": "http:~~exist-db.org~xquery~lucene",
                "label": "ft"
            },{
                "key": "http:~~expath.org~ns~http-client",
                "label": "hc"
            },{
                "key": "http:~~exist-db.org~xquery~image",
                "label": "image"
            },{
                "key": "http:~~exist-db.org~xquery~inspection",
                "label": "inspect"
            },{
                "key": "http:~~exist-db.org~xquery~jndi",
                "label": "jndi"
            },{
                "key": "http:~~exist-db.org~xquery~mail",
                "label": "mail"
            },{
                "key": "http:~~www.w3.org~2005~xpath-functions~map",
                "label": "map"
            },{
                "key": "http:~~www.w3.org~2005~xpath-functions~math",
                "label": "math"
            },{
                "key": "http:~~exist-db.org~xquery~ngram",
                "label": "ngram"
            },{
                "key": "http:~~exist-db.org~xquery~persistentlogin",
                "label": "plogin"
            },{
                "key": "http:~~exist-db.org~xquery~process",
                "label": "process"
            },{
                "key": "http:~~exist-db.org~xquery~range",
                "label": "range"
            },{
                "key": "http:~~exist-db.org~xquery~repo",
                "label": "repo"
            },{
                "key": "http:~~exquery.org~ns~request",
                "label": "req"
            },{
                "key": "http:~~exist-db.org~xquery~request",
                "label": "request"
            },{
                "key": "http:~~exist-db.org~xquery~response",
                "label": "response"
            },{
                "key": "http:~~exquery.org~ns~restxq",
                "label": "rest"
            },{
                "key": "http:~~exist-db.org~xquery~scheduler",
                "label": "scheduler"
            },{
                "key": "http:~~exist-db.org~xquery~session",
                "label": "session"
            },{
                "key": "http:~~exist-db.org~xquery~simple-ql",
                "label": "simpleql"
            },{
                "key": "http:~~exist-db.org~xquery~securitymanager",
                "label": "sm"
            },{
                "key": "http:~~exist-db.org~xquery~sort",
                "label": "sort"
            },{
                "key": "http:~~exist-db.org~xquery~sql",
                "label": "sql"
            },{
                "key": "http:~~exist-db.org~xquery~system",
                "label": "system"
            },{
                "key": "http:~~exist-db.org~xquery~transform",
                "label": "transform"
            },{
                "key": "http:~~exist-db.org~xquery~util",
                "label": "util"
            },{
                "key": "http:~~exist-db.org~xquery~validation",
                "label": "validation"
            },{
                "key": "http:~~exist-db.org~xquery~xmldb",
                "label": "xmldb"
            },{
                "key": "http:~~exist-db.org~xquery~xmldiff",
                "label": "xmldiff"
            },{
                "key": "http:~~exist-db.org~xquery~xqdoc",
                "label": "xqdm"
            },{
                "key": "https:~~xqdoc.org~exist-db~ns~lib~xqdoc~parse",
                "label": "xqp"
            },{
                "key": "http:~~exist-db.org~xquery~xslfo",
                "label": "xslfo"
            },{
                "key": "http:~~expath.org~ns~zip",
                "label": "zip"
            }]
        },
    ];

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
          </Navbar>
          <Container style={{marginTop: "70px"}} fluid>
              <Row xs={1}>
                  <Col md={4} xl={3} xs={12} class="sidenav"
                  >
                      <TreeMenu
                          data={treeData}
                          onClickItem={({ key, label, ...props }) => {
                              console.log(key);
                          }}
                      />
                  </Col>
                  <Col md={8} xl={7} xs={12} >
                      <Switch>
                          <Route path="/SwaggerUI">
                              <h1>Swagger</h1>
                              <SwaggerUI url="/exist/restxq/xqdoc/openapi"></SwaggerUI>
                          </Route>
                          <Route path="/Libraries/:libraryID">
                              <h1>Library</h1>
                          </Route>
                          <Route path="/Applications/:applicationID">
                              <h1>Application</h1>
                          </Route>
                          <Route exact path="/">
                              <h1>Home</h1>
                          </Route>
                      </Switch>
                  </Col>
              </Row>
          </Container>
      </Router>
  );
}

export default App;
