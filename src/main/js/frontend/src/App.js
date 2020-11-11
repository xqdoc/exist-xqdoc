import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import Navbar from 'react-bootstrap/Navbar';
import { HashRouter as Router } from 'react-router-dom';
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
      </Router>
  );
}

export default App;
