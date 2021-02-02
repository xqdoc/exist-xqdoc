xquery version "3.1";

(:~
# Introduction

This module retrieves an xqDoc document based on the query parameter `rs:module`.
It then transforms that XML document to it's JSON equivalent for displaying
in a Polymer 3 webpage.
@author Loren Cahlander
@version 1.0
@since 1.0
 :)
module namespace xq = "http://xqdoc.org/restxq/resource/xqdoc";
import module namespace xqutil = "https://xqdoc.org/exist-db/ns/lib/xqdoc/util" at "../content/xqdoc-module.xqm";

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace xqdoc = "http://www.xqdoc.org/1.0";

(:~
  Generates the JSON for an xqDoc comment
  @param $comment the xqdoc:comment element
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:comment($comment as node()?) {
    if ($comment)
    then
        map {
            "description": fn:string-join($comment/xqdoc:description/text(), " "),
            "authors": array {$comment/xqdoc:author/text()},
            "versions": array {$comment/xqdoc:version/text()},
            "params": array {$comment/xqdoc:param/text()},
            "errors": array {$comment/xqdoc:error/text()},
            "deprecated": array {$comment/xqdoc:deprecated/text()},
            "see": array {$comment/xqdoc:see/text()},
            "since": array {$comment/xqdoc:since/text()},
            "custom": array {
                for $custom in $comment/xqdoc:custom
                return
                    map {
                        "tag": $custom/@tag/string(),
                        "description": $custom/text()
                    }
            }
        }
    else
        fn:false()
};

(:~
Generate the occurrence string for the xqDoc display

&lt;table border="1" style="border-collapse: collapse;"&gt;
&lt;tr&gt;
&lt;th&gt;Occurrence&lt;/th&gt;
&lt;th&gt;Description&lt;/th&gt;
&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;?&lt;/td&gt;&lt;td&gt;zero or one&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;+&lt;/td&gt;&lt;td&gt;one or more&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;*&lt;/td&gt;&lt;td&gt;zero or more&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;td&gt;exactly one&lt;/td&gt;&lt;/tr&gt;
&lt;/table&gt;

@param $type the data type xqDoc element.
@return The description of the occurrence
 :)
declare function xq:occurrence($type as node()?)
as xs:string
{
    switch ($type/@occurrence)
        case "+"
            return
                "one or more"
        case "*"
            return
                "zero or more"
        case "?"
            return
                "zero or one"
        default return
            "exactly one"
};

(:~
  Generates the JSON for the xqDoc functions
  @param $functions
  @param $module-path The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:functions($functions as node()*, $module-path as xs:string) {
    let $module-uri := $functions[1]/fn:root()//xqdoc:module/xqdoc:uri/text()
    return
    for $function in $functions
    let $name := fn:string-join($function/xqdoc:name/text())
    let $function-comment := $function/xqdoc:comment
        order by $name
    return
        map {
            "repeatItemType": "function",
            "comment": xq:comment($function-comment),
            "name": $name,
            "signature": fn:string-join($function/xqdoc:signature/text(), " "),
            "annotations": array {
                for $annotation in $function/xqdoc:annotations/xqdoc:annotation
                return
                    map {
                        "name": xs:string($annotation/@name),
                        "literals": array {
                            for $literal in $annotation/xqdoc:literal
                            return
                                xs:string($literal)
                        }
                    }
            },
            "parameters": array {
                for $parameter in $function/xqdoc:parameters/xqdoc:parameter
                let $ptest := '$' || $parameter/xqdoc:name/text()
                let $param := $function//xqdoc:param[fn:starts-with(., $ptest)]
                let $pbody := fn:substring(fn:string-join($param/text(), " "), fn:string-length($ptest) + 1)
                let $description := replace($pbody, '^\s+', '')
                return
                    map {
                        "name": fn:string-join($parameter/xqdoc:name/text(), " "),
                        "type": fn:string-join($parameter/xqdoc:type/text(), " "),
                        "occurrence": xq:occurrence($parameter/xqdoc:type),
                        "description": $description
                    }
            },
            "return": map {
                "type":
                if (fn:string-length(xs:string($function/xqdoc:return/xqdoc:type)) gt 0)
                then
                    fn:string-join($function/xqdoc:return/xqdoc:type/text(), " ")
                else
                    "empty-sequence()",
                "occurrence":
                if (fn:string-length(xs:string($function/xqdoc:return/xqdoc:type)) gt 0)
                then
                    xq:occurrence($function/xqdoc:return/xqdoc:type)
                else
                    "",
                "description":
                if ($function/xqdoc:comment/xqdoc:return)
                then
                    xs:string($function/xqdoc:comment/xqdoc:return)
                else
                    ""
            },
            "invoked": array {
                            xq:invoked($function/xqdoc:invoked, $module-path, $module-uri)
                       },
            "refVariables": array {
                            xq:ref-variables($function/xqdoc:ref-variable, $module-path, $module-uri)
                            },
            "references": array {
                xq:all-function-references(
                fn:collection($xqutil:XQDOC_ROOT_COLLECTION)/xqdoc:xqdoc/xqdoc:functions/xqdoc:function/xqdoc:invoked[xqdoc:uri = $module-uri][xqdoc:name = $name],
                $module-uri
                )
            },
            "body": fn:string-join($function/xqdoc:body/text(), " ")
        }
};

declare function xq:path-to-uri($uri as xs:string, $import as node()?, $module-path as xs:string, $module-uri as xs:string?) {
    if ($uri eq $module-uri)
    then $module-path
    else if ($import)
         then $module-path || '/' || xs:string($import/@location)
         else
            let $module := fn:collection($xqutil:XQDOC_LIB_COLLECTION)/xqdoc:xqdoc[xqdoc:module/xqdoc:uri = $uri]
            return
                if ($module)
                then fn:substring-after(fn:base-uri($module), $xqutil:XQDOC_ROOT_COLLECTION)
                else ""
};

(:~
  Generates the JSON for the xqDoc function calls from within a function or a body
  @param $invokes
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:invoked($invokes as node()*, $module-path as xs:string, $module-uri as xs:string?) {
    for $uri in fn:distinct-values($invokes/xqdoc:uri/text())
    let $invoke-path := xq:path-to-uri($uri, $invokes/fn:root()//xqdoc:import[xqdoc:uri = $uri], $module-path, $module-uri)
    order by $uri
    return
        map {
            "repeatItemType": "invoked",
            "uri": $uri,
            "functions": array {
                for $invoke in $invokes[xqdoc:uri = $uri]
                let $name := $invoke/xqdoc:name/text()
                    order by $name
                return
                    map {
                        "uri": $uri,
                        "path": $invoke-path,
                        "name": $name,
                        "isReachable":
                        if (
                            fn:string-length($invoke-path) gt 0
                            and
                            fn:doc($xqutil:XQDOC_ROOT_COLLECTION || $invoke-path)/xqdoc:xqdoc[xqdoc:functions/xqdoc:function/xqdoc:name = $name]
                            )
                        then
                            fn:true()
                        else
                            fn:false(),
                        "isInternal":
                        if ($invoke/xqdoc:uri/text() = $module-uri)
                        then
                            fn:true()
                        else
                            fn:false()
                    }
            }
        }
};

(:~
  Generates the JSON for the xqDoc variable references from within a function or a body
  @param $references
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:ref-variables($references as node()*, $module-path as xs:string, $module-uri as xs:string?) {
    for $uri in fn:distinct-values($references/xqdoc:uri/text())
    let $invoke-path := xq:path-to-uri($uri, $references[1]/fn:root()//xqdoc:import[xqdoc:uri = $uri], $module-path, $module-uri)
    order by $uri
    return
        map {
            "repeatItemType": "refVariable",
            "uri": $uri,
            "variables":
            array {
                for $reference in $references[xqdoc:uri = $uri]
                let $name := $reference/xqdoc:name/text()
                    order by $name
                return
                    map {
                        "uri": $uri,
                        "path": $invoke-path,
                        "name": $name,
                        "isReachable":
                        if (
                            fn:string-length($invoke-path) gt 0
                            and
                            fn:doc($xqutil:XQDOC_ROOT_COLLECTION || $invoke-path)/xqdoc:xqdoc[xqdoc:variables/xqdoc:variable/xqdoc:name = $name]
                            )
                        then
                            fn:true()
                        else
                            fn:false(),
                        "isInternal":
                        if ($reference/xqdoc:uri/text() = $module-uri)
                        then
                            fn:true()
                        else
                            fn:false()
                    }

            }
        }
};

(:~
  @param $references
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:all-variable-references($references as node()*, $module-uri as xs:string?) {
    let $uris := fn:distinct-values(
    for $reference in $references
    let $uri := $reference/fn:root()//xqdoc:module/xqdoc:uri/text()
        order by $uri
    return
        $uri
    )
    return
        for $uri in $uris
        return
            map {
                "uri": $uri,
                "functions":
                array {
                    for $reference in $references
                    let $testuri := $reference/fn:root()//xqdoc:module/xqdoc:uri/text()
                    let $name := $reference/../xqdoc:name/text()
                        order by $name
                    return
                        if ($testuri = $uri)
                        then
                            map {
                                "name": $name,
                                "uri": $uri,
                                "isReachable":
                                if (fn:collection($xqutil:XQDOC_ROOT_COLLECTION)/xqdoc:xqdoc[xqdoc:module/xqdoc:uri = $uri][xqdoc:functions/xqdoc:function/xqdoc:name = $name])
                                then
                                    fn:true()
                                else
                                    fn:false(),
                                "isInternal":
                                if ($uri = $module-uri)
                                then
                                    fn:true()
                                else
                                    fn:false()
                            }
                        else
                            ()
                }

            }
};

(:~
  @param $references
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:all-function-references($references as node()*, $module-uri as xs:string?) {
    let $uris := fn:distinct-values(
    for $reference in $references
    let $uri := $reference/fn:root()//xqdoc:module/xqdoc:uri/text()
        order by $uri
    return
        $uri
    )
    return
        for $uri in $uris
        return
            map {
                "uri": $uri,
                "functions":
                array {
                    for $reference in $references
                    let $testuri := $reference/fn:root()//xqdoc:module/xqdoc:uri/text()
                    let $name := $reference/../xqdoc:name/text()
                        order by $name
                    return
                        if ($testuri = $uri)
                        then
                            map {
                                "name": $name,
                                "uri": $uri,
                                "isReachable":
                                if (fn:collection($xqutil:XQDOC_ROOT_COLLECTION)/xqdoc:xqdoc[xqdoc:module/xqdoc:uri = $uri][xqdoc:functions/xqdoc:function/xqdoc:name = $name])
                                then
                                    fn:true()
                                else
                                    fn:false(),
                                "isInternal":
                                if ($uri = $module-uri)
                                then
                                    fn:true()
                                else
                                    fn:false()
                            }
                        else
                            ()
                }

            }
};

(:~
  @param $variables A sequence of the xqdoc:variable elements
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:variables($variables as node()*, $module-uri as xs:string?) {
    for $variable in $variables
    let $uri := $variable/xqdoc:uri/text()
    let $name := $variable/xqdoc:name/text()
    return
        map {
            "repeatItemType": "variable",
            "comment": xq:comment($variable/xqdoc:comment),
            "uri": $uri,
            "name": $name,
            "references":
            array {
                xq:all-variable-references(
                fn:collection($xqutil:XQDOC_ROOT_COLLECTION)/xqdoc:xqdoc/xqdoc:functions/xqdoc:function/xqdoc:ref-variable[xqdoc:uri = $uri][xqdoc:name = $name],
                $module-uri
                )
            }
        }
};

(:~
  @param $imports A sequence of the xqdoc:import elements
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xq:imports($imports as node()*) {
    for $import in $imports
    let $uri := $import/xqdoc:uri/text()
    return
        map {
            "repeatItemType": "import",
            "comment": xq:comment($import/xqdoc:comment),
            "uri": fn:substring(fn:substring($uri, 1, fn:string-length($uri) - 1), 2),
            "type": xs:string($import/@type)
        }
};

declare
%rest:GET
%rest:path("/xqdoc/menu")
%rest:produces("application/json")
%output:media-type("application/json")
%output:method("json")
function xq:menu()
{
    array {
        map {
            "key": 'SwaggerUI',
            "label": 'Rest APIs'
        },
        map {
            "key": 'Applications',
            "label": 'Applications',
            "nodes": array {
            for $app in fn:sort(xmldb:get-child-collections("/db/system/xqDoc/db/apps"))
            return
                map {
                    "key": $app,
                    "label": $app
                }
            }
        },
        map {
            "key": 'Libraries',
            "label": 'Libraries',
            "nodes": array {
            for $lib in fn:collection("/db/system/xqDoc/lib")//xqdoc:xqdoc
            let $prefix := ($lib/xqdoc:module/xqdoc:name/text(), "fn")[1]
            let $namespace := $lib/xqdoc:module/xqdoc:uri/text()
            let $desc := $lib/xqdoc:module/xqdoc:comment/xqdoc:description/text()
            let $location := $lib/xqdoc:control/xqdoc:location/text()
            order by $prefix ascending
            return
                map {
                    "key": fn:replace($namespace, "/", "~"),
                    "label": $prefix,
                    "namespace": $namespace,
                    "description": $desc,
                    "location": $location
                }
            }
        }
    }
};

(:~
  Gets the xqDoc of a module as JSON
  @param $module The URI of the module to display
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare
%rest:GET
%rest:path("/xqdoc/level")
%rest:query-param("page", "{$page}")
%rest:query-param("per_page", "{$size}")
%rest:query-param("path", "{$path}")
%rest:produces("application/json")
%output:media-type("application/json")
%output:method("json")
function xq:get-level($page as xs:integer*, $size as xs:integer*, $path as xs:string*)
{
    let $spath := $xqutil:XQDOC_ROOT_COLLECTION || $path[1]
    let $resources := xmldb:get-child-resources($spath)
    let $collections := xmldb:get-child-collections($spath)
    let $count := fn:count(($resources, $collections))
    return map {
        "totalSize": $count,
        "data": array {
            for $item in $resources
            let $full-path := $path || "/" || $item
            order by $item
            return map {
                "name" : fn:substring-before($item, ".xml"),
                "fullpath" : $full-path,
                "hasChildren": fn:false()
            },
            for $item in $collections
            let $full-path := $path || "/" || $item
            order by $item
            return map {
                "name" : $item,
                "fullpath" : $full-path,
                "hasChildren": fn:true()
            }

        }
    }
};

(:~
  Gets the xqDoc of a module as JSON
  @param $module The URI of the module to display
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare
%rest:GET
%rest:path("/xqdoc/module")
%rest:query-param("module", "{$module}")
%rest:produces("application/json")
%output:media-type("application/json")
%output:method("json")
function xq:get(
$module as xs:string*
)
{
    let $decoded-module := if (fn:count($module) gt 0) then xmldb:decode($module[1]) else ""
    let $doc := fn:doc($xqutil:XQDOC_ROOT_COLLECTION || $decoded-module)/xqdoc:xqdoc
    let $module-comment := $doc/xqdoc:module/xqdoc:comment
    return
        map {
            "response":
            if ($doc)
            then
                map {
                    "control": map {
                        "date": $doc/xqdoc:control/xqdoc:date/text(),
                        "version": $doc/xqdoc:control/xqdoc:version/text()
                    },
                    "comment": xq:comment($module-comment),
                    "uri": $doc/xqdoc:module/xqdoc:uri/text(),
                    "name":
                    if ($doc/xqdoc:module/xqdoc:name)
                    then
                        $doc/xqdoc:module/xqdoc:name/text()
                    else
                        fn:false(),
                    "dummy": array {(
                            xq:variables($doc/xqdoc:variables/xqdoc:variable, $decoded-module),
                            xq:imports($doc/xqdoc:imports/xqdoc:import),
                            xq:functions($doc/xqdoc:functions/xqdoc:function, $decoded-module)
                        )},
                    "invoked":
                    array {
                        xq:invoked(
                            $doc/xqdoc:module/xqdoc:invoked,
                            $decoded-module,
                            ($doc/xqdoc:module/xqdoc:uri/text(), "http://www.w3.org/2005/xquery-local-functions")[1])
                    },
                    "refVariables":
                    array {
                        xq:ref-variables(
                            $doc/xqdoc:module/xqdoc:ref-variable,
                            $decoded-module,
                            ($doc/xqdoc:module/xqdoc:uri/text(), "http://www.w3.org/2005/xquery-local-functions")[1])
                    },
                    "variables":
                    if ($doc/xqdoc:variables)
                    then
                        array {
                            xq:variables($doc/xqdoc:variables/xqdoc:variable, $decoded-module)
                        }
                    else
                        fn:false(),
                    "imports":
                    if ($doc/xqdoc:imports)
                    then
                        array {
                            xq:imports($doc/xqdoc:imports/xqdoc:import)
                        }
                    else
                        fn:false(),
                    "functions":
                    if ($doc/xqdoc:functions)
                    then
                        array {
                            xq:functions($doc/xqdoc:functions/xqdoc:function, $decoded-module)
                        }
                    else
                        fn:false(),
                    "body": fn:string-join($doc/xqdoc:module/xqdoc:body/text(), " ")
                }
            else
                fn:false()
        }
};
