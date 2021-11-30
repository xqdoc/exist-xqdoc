import 'bootstrap/dist/css/bootstrap.min.css';
import React, { useEffect, useState } from 'react';
import ReactMarkdown from "react-markdown";
import {Card, Spinner} from "react-bootstrap";
import { useParams } from "react-router-dom";
import './App.css';

function LibraryModule() {
    let {libraryID} = useParams();
    const [resultData, setResultData] = useState({});
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        setLoading(true);
        fetch("/exist/restxq/xqdoc/library/" + libraryID)
            .then((response) => response.json())
            .then(
                (result) => {
                    setResultData(result.response);
                    setLoading(false);
                },
                (error) => {
                    setResultData({});
                    setLoading(false);
                }
            );
    }, [libraryID]);
    return (loading ? <span><Spinner animation="grow" /> Loading</span>
        :
        <div style={{width: "100%"}}>
            <h1>Library {resultData.uri}</h1>
            <ReactMarkdown>{resultData.comment ? resultData.comment.description : ""}</ReactMarkdown>
            <div>
                {resultData.dummy ?
                    resultData.dummy.map((xqfunc) => {
                        return (
                            <Card style={{width: "100%", marginBottom: 5}}>
                                <Card.Header>{resultData.name + ":" + xqfunc.name}</Card.Header>
                                <Card.Body>
                                    <div style={{width: "100%", border: "thin solid black", padding: 3, marginBottom: 3}}>{resultData.name + ":" + xqfunc.name + "(" +
                                        xqfunc.parameters.map((param) => {
                                            return param.name + " " + param.type + param.occurrence;
                                        }).join(", ")
                                    + ") as " + xqfunc.return.type + (xqfunc.return.occurence ? xqfunc.return.occurence : "")}</div>
                                    <ReactMarkdown>{xqfunc.comment ? xqfunc.comment.description : ""}</ReactMarkdown>
                                    {xqfunc.comment.params.map((param) => {
                                          return (<div>{param}</div>);
                                        })}
                                    <div style={{marginTop: 5}}><b>Returns:</b></div>
                                    <ReactMarkdown>{xqfunc.return.description}</ReactMarkdown>
                                </Card.Body>
                            </Card>
                            )
                    })
                    : ""
                }
            </div>
        </div>
    );
}

export default LibraryModule;
