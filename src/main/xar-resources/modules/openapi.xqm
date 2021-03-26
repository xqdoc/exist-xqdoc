xquery version "3.1";

(:~
 This module generates the OpenAPI JSON document for the OpenAPI display.
 @author Loren Cahlander
 @version 1.0
 @since 1.0
 @return the OpenAPI JSON document for the OpenAPI display
 @see https://github.com/OAI/OpenAPI-Specification
 @see https://github.com/lcahlander/xqdoc
 :)
module namespace openapirest = "http://xqdoc.org/modules/ns/openapi";

import module namespace config="http://xqdoc.org/apps/xqdoc/config" at "config.xqm";
import module namespace xqdoc2openapi="http://xqdoc.org/library/xqdoc/openapi";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map= "http://www.w3.org/2005/xpath-functions/map";
declare namespace json="http://www.json.org";

declare
    %rest:GET
    %rest:path("/xqdoc/openapi")
    %rest:produces("application/json")
    %output:media-type("application/json")
    %output:method("json")
function openapirest:get() {

let $base := fn:json-doc($config:data-root || "/openapi.json")


let $paths-object :=
		xqdoc2openapi:process-xqrs-to-xqDoc-to-OpenAPI()

return map {
    "openapi" : "3.0.0",
    "info" : $base?info,
    "servers" : array { $base?servers?* },
    "paths" : $paths-object,
    "components" : $base?components
    }
};
