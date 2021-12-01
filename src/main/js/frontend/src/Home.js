import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import XMLViewer from 'react-xml-viewer'
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
                <div>If new code has been added , then there are two ways to get
                    the xqDoc files up to date.</div>
                <ol>
                    <li><p>Click the <b>Regenerate</b> button in the upper right</p></li>
                    <li>
                        <p>Add the following trigger to your applications' collection.xconf file:</p>
                        <XMLViewer xml={xml} />
                    </li>
                </ol>
            </>
        )
    }

}