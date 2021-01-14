xquery version "3.1";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace xqutil = "https://xqdoc.org/exist-db/ns/lib/xqdoc/util";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $a := (xqutil:generate-internal-xqdocs(),
xqutil:generate-external-xqdocs())

return map { "success" : fn:true() }