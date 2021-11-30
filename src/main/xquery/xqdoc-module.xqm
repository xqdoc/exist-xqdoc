xquery version "3.1";

(:~
 : A very simple xqdoc XQuery Library Module implemented
 : in XQuery.
 :)
module namespace xqutil = "https://xqdoc.org/exist-db/ns/lib/xqdoc/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace xqp = "https://xqdoc.org/exist-db/ns/lib/xqdoc/parse";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";
import module namespace inspect="http://exist-db.org/xquery/inspection" at "java:org.exist.xquery.functions.inspect.InspectionModule";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace sm ="http://exist-db.org/xquery/securitymanager";
import module namespace  functx = "http://www.functx.com";

declare namespace xqdoc = "http://www.xqdoc.org/1.0";

(:~
 :  This variable defines the name for the xqDoc collection.
 :  The xqDoc XML for all modules should be stored into the
 :  XML database with this collection value.
 :)
declare variable $xqutil:XQDOC_PARENT_COLLECTION := "/db/system";
declare variable $xqutil:XQDOC_ROOT_NAME := "xqDoc";
declare variable $xqutil:XQDOC_ROOT_COLLECTION := $xqutil:XQDOC_PARENT_COLLECTION || "/" || $xqutil:XQDOC_ROOT_NAME;
declare variable $xqutil:XQDOC_LIB_NAME := "lib";
declare variable $xqutil:XQDOC_LIB_COLLECTION := $xqutil:XQDOC_ROOT_COLLECTION || "/" || $xqutil:XQDOC_LIB_NAME;

declare function xqutil:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            if (xmldb:collection-available(xmldb:encode-uri($newColl)))
            then ()
            else xmldb:create-collection(xmldb:encode-uri($collection), xmldb:encode-uri($components[1])),
            xqutil:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function xqutil:mkcol($collection, $path) {
    xqutil:mkcol-recursive($collection, tokenize($path, "/"))
};


declare function xqutil:generate-root-collection() {
    if (sm:id()//sm:group = "dba")
    then
        if (xmldb:collection-available($xqutil:XQDOC_ROOT_COLLECTION))
        then ()
        else xmldb:create-collection($xqutil:XQDOC_PARENT_COLLECTION, $xqutil:XQDOC_ROOT_NAME)
    else ()
};

declare function xqutil:generate-external-xqdocs() {
    for $uri in dbutil:find-by-mimetype(xs:anyURI("/db"), "application/xquery")
    return xqutil:generate-external-xqdoc(xs:anyURI($uri))
};


declare function xqutil:generate-external-xqdoc($uri as xs:anyURI) {
    let $decoded := xmldb:decode-uri($uri)
    let $path := functx:substring-before-last($decoded, '/')
    let $resource := functx:substring-after-last($decoded, '/')
    let $extension := functx:substring-after-last($decoded, '.')
    let $processed :=
        if (fn:starts-with($extension, "xq"))
        then
            let $bdoc := util:binary-doc($uri)
            let $source-code := util:binary-to-string($bdoc)
            let $xqdoc := xqp:parse($source-code)
            let $mkcol := xqutil:mkcol($xqutil:XQDOC_PARENT_COLLECTION, $xqutil:XQDOC_ROOT_NAME || $path)
            let $stored := xmldb:store(
                    xmldb:encode-uri($xqutil:XQDOC_ROOT_COLLECTION || $path),
                    xmldb:encode-uri($resource || ".xml"),
                    $xqdoc)
            return ()
        else ()
    return ()
};

declare function xqutil:remove-external-xqdoc($uri as xs:anyURI) {
    let $decoded := xmldb:decode-uri($uri)
    let $path := functx:substring-before-last($decoded, '/')
    let $resource := functx:substring-after-last($decoded, '/')
    let $extension := functx:substring-after-last($decoded, '.')
    let $processed :=
        if (fn:starts-with($extension, "xq"))
        then
            if (fn:doc-available(xmldb:encode-uri($xqutil:XQDOC_ROOT_COLLECTION || $path || "/" || $resource || ".xml")))
            then xmldb:remove(xmldb:encode-uri($xqutil:XQDOC_ROOT_COLLECTION || $path),xmldb:encode-uri($resource || ".xml"))
                ()
            else ()
        else ()
    return ()
};

declare function xqutil:generate-internal-xqdocs() {
    if (sm:id()//sm:group = "dba")
    then
        let $removed :=
            if (xmldb:collection-available($xqutil:XQDOC_LIB_COLLECTION))
            then xmldb:remove($xqutil:XQDOC_LIB_COLLECTION)
            else ()
        let $root-made := xqutil:generate-root-collection()
        let $remade := xmldb:create-collection($xqutil:XQDOC_ROOT_COLLECTION,$xqutil:XQDOC_LIB_NAME)
        return
            for $reg in util:registered-modules()
            order by $reg
            let $meta := try { inspect:inspect-module-uri($reg) } catch * { () }
            return
                if ($meta)
                then
                    let $xqdoc := xqutil:generate-internal-xqdoc($meta)
                    let $location := fn:replace($xqdoc//xqdoc:control/xqdoc:location/text(), "java:", "")
                     let $stored := xmldb:store("/db/system/xqDoc/lib", $location || ".xml", $xqdoc)
                    return ()
                else
                    util:log("WARN", "Module not found: " || $reg)
    else ()
};

declare function xqutil:generate-internal-xqdoc($module as element(module)) {
    <xqdoc:xqdoc>
        <xqdoc:control>
            <xqdoc:date>{current-dateTime()}</xqdoc:date>
            <xqdoc:location>{$module/@location/string()}</xqdoc:location>
        </xqdoc:control>
        <xqdoc:module type="library">
            <xqdoc:uri>{$module/@uri/string()}</xqdoc:uri>
            <xqdoc:name>{$module/@prefix/string()}</xqdoc:name>
            <xqdoc:comment>
                <xqdoc:description>{$module/description/string()}</xqdoc:description>
                {
                    if ($module/version) then
                        <xqdoc:version>{$module/version/string()}</xqdoc:version>
                    else
                        ()
                }
                {
                    if ($module/author) then
                        <xqdoc:author>{$module/author/string()}</xqdoc:author>
                    else
                        ()
                }
            </xqdoc:comment>
        </xqdoc:module>
        <xqdoc:functions>
        {
            for $func in $module/function
            return
                <xqdoc:function>
                    <xqdoc:comment>
                        <xqdoc:description>{$func/description/string()}</xqdoc:description>
                        {
                            for $param in $func/argument
                            return
                                <xqdoc:param>${$param/@var/string()}{xqutil:cardinality($param/@cardinality)}{" "}{$param/text()}</xqdoc:param>
                        }
                        <xqdoc:return>
                        {$func/returns/@type/string()}{xqutil:cardinality($func/returns/@cardinality)}{if(empty($func/returns/text())) then "" else " : " || $func/returns/text()}

                        </xqdoc:return>
                        {
                            if ($func/deprecated) then
                                <xqdoc:deprecated>{$func/deprecated/string()}</xqdoc:deprecated>
                            else
                                ()
                        }
                    </xqdoc:comment>
                    <xqdoc:name>{if (fn:contains($func/@name/string(), ":"))
    then fn:substring-after($func/@name/string(), ":")
    else $func/@name/string() }</xqdoc:name>
                    <xqdoc:signature>{xqutil:generate-signature($func)}</xqdoc:signature>
                    <xqdoc:parameters>{
                        for $param in $func/argument
                        return
                            <xqdoc:parameter>
                                <xqdoc:name>${$param/@var/string()}</xqdoc:name>
                                <xqdoc:type occurrence="{xqutil:cardinality($param/@cardinality)}">{$param/@type/string()}</xqdoc:type>
                            </xqdoc:parameter>
                    }</xqdoc:parameters>
                    <xqdoc:return>
                        <xqdoc:type occurence="{xqutil:cardinality($func/returns/@cardinality)}">{$func/returns/@type/string()}</xqdoc:type>
                    </xqdoc:return>
                </xqdoc:function>
        }
        </xqdoc:functions>
    </xqdoc:xqdoc>
};

declare %private function xqutil:cardinality($cardinality as xs:string) {
    switch ($cardinality)
        case "zero or one" return "?"
        case "zero or more" return "*"
        case "one or more" return "+"
        default return ()
};


declare %private function xqutil:generate-signature($func as element(function)) {
    if (fn:contains($func/@name/string(), ":"))
    then fn:substring-after($func/@name/string(), ":")
    else $func/@name/string() || "(" ||
    string-join(
        for $param in $func/argument
        return
            "$" || $param/@var/string()  || " as " || $param/@type/string() || xqutil:cardinality($param/@cardinality),
        ", "
    ) ||
    ")" || " as " || $func/returns/@type/string() || xqutil:cardinality($func/returns/@cardinality)
};
