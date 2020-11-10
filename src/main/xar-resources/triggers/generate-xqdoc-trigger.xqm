xquery version "3.0";
(:
    A simple XQuery for an XQueryTrigger that
    logs all trigger events for which it is executed
    in the file /db/triggersLogs.xml
:)
module namespace trigger='http://exist-db.org/xquery/trigger';

import module namespace xqp = "https://xqdoc.org/exist-db/ns/lib/xqdoc/parse";
import module namespace  functx = "http://www.functx.com";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";

declare %private function trigger:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            if (xmldb:collection-available($newColl))
            then ()
            else xmldb:create-collection($collection, $components[1]),
            trigger:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare %private function trigger:mkcol($collection, $path) {
    trigger:mkcol-recursive($collection, tokenize($path, "/"))
};


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
    let $path := functx:substring-before-last(xs:string($uri), '/')
    let $resource := functx:substring-after-last(xs:string($uri), '/')
    let $extension := functx:substring-after-last(xs:string($uri), '.')
    let $processed :=
        if (fn:starts-with($extension, "xq"))
        then
            let $bdoc := util:binary-doc($uri)
            let $source-code := util:binary-to-string($bdoc)
            let $xqdoc := xqp:parse($source-code)
            let $mkcol := trigger:mkcol("/db/system", "xqDoc" || $path)
            let $stored := xmldb:store(
                    xmldb:encode-uri("/db/system/xqDoc" || $path),
                    xmldb:encode-uri($resource || ".xml"),
                    $xqdoc)
            return ()
        else ()
    return ()
};
declare function trigger:before-update-document($uri as xs:anyURI) {
()
};
declare function trigger:after-update-document($uri as xs:anyURI) {
    let $path := functx:substring-before-last(xs:string($uri), '/')
    let $resource := functx:substring-after-last(xs:string($uri), '/')
    let $extension := functx:substring-after-last(xs:string($uri), '.')
    let $processed :=
        if (fn:starts-with($extension, "xq"))
        then
            let $bdoc := util:binary-doc($uri)
            let $source-code := util:binary-to-string($bdoc)
            let $xqdoc := xqp:parse($source-code)
            let $mkcol := trigger:mkcol("/db/system", "xqDoc" || $path)
            let $stored := xmldb:store(
                    xmldb:encode-uri("/db/system/xqDoc" || $path),
                    xmldb:encode-uri($resource || ".xml"),
                    $xqdoc)
            return ()
        else ()
    return ()
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
    let $path := functx:substring-before-last(xs:string($uri), '/')
    let $resource := functx:substring-after-last(xs:string($uri), '/')
    let $extension := functx:substring-after-last(xs:string($uri), '.')
    let $processed :=
        if (fn:starts-with($extension, "xq"))
        then
            if (fn:doc-available("/db/system/xqDoc" || $path || "/" || $resource || ".xml"))
            then xmldb:remove("/db/system/xqDoc" || $path,$resource || ".xml")
                ()
            else ()
        else ()
    return ()
};
declare function trigger:after-delete-document($uri as xs:anyURI) {
()
};

