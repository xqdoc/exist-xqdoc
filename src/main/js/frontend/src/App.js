import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import Navbar from 'react-bootstrap/Navbar';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { HashRouter as Router, Link, Route, Switch } from "react-router-dom";
import './App.css';

function App() {
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
          <Container style={{marginTop: "70px"}}>
              <Row xs={1}>
                  <Col md={3} xl={2} xs={12} style={{border: 1, borderColor: "black", height: "100vh"}}>Foo</Col>
                  <Col md={9} xl={8} xs={12} style={{border: 1, borderColor: "black", height: "100vh"}}>Bar</Col>
              </Row>
          </Container>
      </Router>
  );
}

export default App;
