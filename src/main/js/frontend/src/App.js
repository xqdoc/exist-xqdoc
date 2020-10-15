import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import NavBar from 'react-bootstrap/NavBar';
import { HashRouter as Router, Link, Route, Switch } from 'react-router-dom';
import './App.css';

function App() {
  return (
      <Router>
          <NavBar bg="dark" variant="dark" fixed="top">
              <NavBar.Brand href="./">
                  <img
                      id="logo"
                      alt=""
                      src="book.svg"
                      width="80"
                      height="40"
                  />{' '}XQuery Function Documentation</NavBar.Brand>
          </NavBar>
      </Router>
  );
}

export default App;
