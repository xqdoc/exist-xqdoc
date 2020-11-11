xquery version "3.0";
(:
    A simple XQuery for an XQueryTrigger that
    logs all trigger events for which it is executed
    in the file /db/triggersLogs.xml
:)
module namespace trigger='http://exist-db.org/xquery/trigger';

import module namespace xqutil = "https://xqdoc.org/exist-db/ns/lib/xqdoc/util";


declare function trigger:before-create-collection($uri as xs:anyURI) {
()
};
declare function trigger:after-create-collection($uri as xs:anyURI) {
()
};
declare function trigger:before-update-collection($uri as xs:anyURI) {
()
};
declare function trigger:after-update-collection($uri as xs:anyURI) {
()
};
declare function trigger:before-copy-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
()
};
declare function trigger:after-copy-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
()
};
declare function trigger:before-move-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
()
};
declare function trigger:after-move-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
()
};
declare function trigger:before-delete-collection($uri as xs:anyURI) {
()
};
declare function trigger:after-delete-collection($uri as xs:anyURI) {
()
};
declare function trigger:before-create-document($uri as xs:anyURI) {
()
};
declare function trigger:after-create-document($uri as xs:anyURI) {
    xqutil:generate-external-xqdoc($uri)
};
declare function trigger:before-update-document($uri as xs:anyURI) {
()
};
declare function trigger:after-update-document($uri as xs:anyURI) {
    xqutil:generate-external-xqdoc($uri)
};
declare function trigger:before-copy-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
()
};
declare function trigger:after-copy-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
()
};
declare function trigger:before-move-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
()
};
declare function trigger:after-move-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
()
};
declare function trigger:before-delete-document($uri as xs:anyURI) {
    xqutil:remove-external-xqdoc($uri)
};
declare function trigger:after-delete-document($uri as xs:anyURI) {
()
};

