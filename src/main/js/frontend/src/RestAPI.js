import 'bootstrap/dist/css/bootstrap.min.css';
import React, { Component } from 'react';
import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"

// <SwaggerClient
//     uri={'http://petstore.swagger.io/v2/swagger.json'}
//     authorizations: {{ petstore_auth: { token: { access_token: '234934239' } } } }
// ></SwaggerClient>

class RestAPI extends Component {
    render() {
        return (
            <>
                <h1>Swagger</h1>
                <SwaggerUI url="/exist/restxq/xqdoc/openapi"></SwaggerUI>
            </>
        )
    }
}

export default RestAPI;
