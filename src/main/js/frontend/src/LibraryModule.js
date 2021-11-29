import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import { useParams } from "react-router-dom";
import './App.css';

function LibraryModule() {
    let {libraryID} = useParams();
    return (
        <h1>Library {libraryID}</h1>
    );
}

export default LibraryModule;
