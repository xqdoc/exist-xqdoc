import React from 'react';
import { HashRouter as Router, Route, Routes } from "react-router-dom";
import ApplicationModules from "./ApplicationModules";
import ApplicationModule from "./ApplicationModule";
import LibraryModules from "./LibraryModules";
import LibraryModule from "./LibraryModule";
import RestAPI from "./RestAPI";
import Home from "./Home";
import Layout from "./Layout";



function App() {

  return (
          <Router>
              <Routes>
                  <Route path="/" element={<Layout />} >
                      <Route index element={<Home />} />
                      <Route path="/SwaggerUI" element={<RestAPI />}/>
                      <Route path="/Libraries" element={<LibraryModules />}>
                          <Route path=":libraryID" element={<LibraryModule />}/>
                      </Route>
                      <Route path="/Applications" element={<ApplicationModules />}>
                          <Route path=":applicationID" element={<ApplicationModule />}/>
                      </Route>
                  </Route>
              </Routes>
          </Router>
  );
}

export default App;
