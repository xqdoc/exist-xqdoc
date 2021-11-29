import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import { useParams } from "react-router-dom";
import './App.css';

function ApplicationModule() {
    let {applicationID} = useParams();
    return (
        <h1>Application {applicationID}</h1>
    );
}

export default ApplicationModule;
