import 'bootstrap/dist/css/bootstrap.min.css';
import React, { useEffect, useState } from 'react';
import {useParams, useNavigate, Outlet} from "react-router-dom";
import ReactMarkdown from "react-markdown";
import './App.css';
import {Button, Card, Spinner} from "react-bootstrap";

function ApplicationModuleList() {
    let navigate = useNavigate();
    let {applicationID} = useParams();
    const [resultData, setResultData] = useState({});
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        setLoading(true);
        fetch("/exist/restxq/xqdoc/app/" + applicationID)
            .then((response) => response.json())
            .then(
                (result) => {
                    setResultData(result);
                    setLoading(false);
                },
                (error) => {
                    setResultData({});
                    setLoading(false);
                }
            );
    }, [applicationID]);

    return (
        loading ? <span><Spinner animation="grow" /> Loading</span>
            :
            <>
            <div style={{width: "100%"}}>
                <h1>Application {applicationID}</h1>
                {
                    resultData.response ?
                    resultData.response.map((mod) => {
                        return (
                            <Card style={{width: "100%", marginBottom: 5}}>
                                <Card.Header>{mod.type}</Card.Header>
                                <Card.Body>
                                    <Card.Title><a  onClick={() =>
                                    {
                                        navigate("/Application/" + applicationID + "/" + mod.path.replace("/", "~"))
                                    }
                                    }>{mod.path}</a></Card.Title>
                                    <div style={{width: "100%", minHeight: 50, padding: 3, marginBottom: 3}}>
                                        <ReactMarkdown>{mod.comment ? mod.comment.description : ""}</ReactMarkdown>
                                    </div>
                                </Card.Body>
                            </Card>
                        )
                    })
                        : null
                }
            </div>
            <Outlet/>
            </>
    );
}

export default ApplicationModuleList;
