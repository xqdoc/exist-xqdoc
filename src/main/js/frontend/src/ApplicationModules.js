import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import { Outlet } from "react-router-dom";
import './App.css';

function ApplicationModules() {
    return (
        <Outlet/>
    );
}

export default ApplicationModules;
