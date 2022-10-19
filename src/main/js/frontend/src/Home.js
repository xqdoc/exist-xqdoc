import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
//import XMLViewer from 'react-xml-viewer'
import './App.css';

const xml = `<trigger event="update" className="org.exist.collections.triggers.XQueryTrigger">
    <parameter name="url" value="xmldb:exist:///db/apps/xqdoc/triggers/generate-xqdoc-trigger.xqm"/>
</trigger>`;

export default class Home extends Component {
    render() {
        return (
            <>
                <h1>Home</h1>
                <div>The information for this application is generated out of the xqDoc
                    files that are generated from the XQuery code and the Rest APIs
                    are generated from the RestXQ annotations within the code.</div>
                <h2>Regeneration</h2>
                <div>If new code has been added , then there are two ways to get
                    the xqDoc files up to date.</div>
                <ol>
                    <li><p>Click the <b>Regenerate</b> button in the upper right</p></li>
                    <li>
                        <p>Add the following trigger to your applications' collection.xconf file:</p>
                    </li>
                </ol>
                <h2>RestAPIs</h2>
                <div>In order to set the Servers dropdown value, in eXide open
                    &nbsp;<b>/db/apps/xqdoc/data/openapi.json</b> and edit the
                    &nbsp;<b>servers</b> entry and save it.</div>
            </>
        )
    }

}
