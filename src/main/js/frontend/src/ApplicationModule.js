import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import { useParams } from "react-router-dom";
import './App.css';

function ApplicationModule() {
    let {applicationID, moduleID} = useParams();
    return (
        <div>
            <h1>{applicationID}</h1>
            <h2>{moduleID}</h2>
        </div>
    )
}

export default ApplicationModule;
