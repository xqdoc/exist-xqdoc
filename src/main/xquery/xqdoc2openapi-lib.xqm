xquery version "3.1";

(:~
 :)
module namespace xqdoc2openapi="http://xqdoc.org/library/xqdoc/openapi";

declare namespace xqdoc="http://www.xqdoc.org/1.0";

(:~
 :)
declare variable $xqdoc2openapi:service-names := ("rest:GET", "rest:HEAD", "rest:PUT", "rest:POST", "rest:DELETE", "rest:OPTIONS", "rest:PATCH");

(:~
 :)
declare function xqdoc2openapi:param-name($literal as node())
as xs:string
{
    fn:substring(fn:substring-after(fn:substring-before(xs:string($literal), "}"), "{"), 2)
};

(:~
 :)
declare function xqdoc2openapi:get-parameter-description($function as node(), $literal as node())
as xs:string
{
  let $param-name := fn:substring-after(fn:substring-before(xs:string($literal), "}"), "{")
  return xqdoc2openapi:get-string-parameter-description($function, $param-name)
};

(:~
 :)
declare function xqdoc2openapi:get-string-parameter-description($function as node(), $param-name as xs:string)
as xs:string
{
  let $param := $function/xqdoc:comment/xqdoc:param[fn:starts-with(., $param-name)]/text()

  return
    if ($param)
    then replace(fn:substring-after($param, $param-name),'^\s+','')
    else ""
};

(:~
 :)
declare function xqdoc2openapi:schema-object($type as node())
as map(*)
{
    map:merge((
        if ($type/text() = "map:map")
        then
            map {
                "type": "array",
                "items": map {
                    "type": "file"
                }
            }
        else (
            map {
                "type": $type/text()
            },
            switch ($type/@occurrence/string())
            case "*" return map { "minItems": 0 }
            case "+" return map { "minItems": 1 }
            case "?" return map { "minItems": 0, "maxItems": 1 }
            default return map { "minItems": 1, "maxItems": 1 }
        )
    ))
};

(:~
 :)
declare function xqdoc2openapi:parameter-object($name as xs:string, $pname as xs:string, $in as xs:string, $description as xs:string?, $parameters as node()?)
as map(*)
{
    map:merge((
        map{ "name": $name },
        map{ "in": $in },
        map{ "description": $description },
        if ($parameters/xqdoc:parameter[xqdoc:name = $pname][xqdoc:type])
        then map{ "schema": xqdoc2openapi:schema-object($parameters/xqdoc:parameter[xqdoc:name = $pname]/xqdoc:type) }
        else ()
    ))
};

(:~
 :)
declare function xqdoc2openapi:service-object($function as node()?, $path as xs:string)
as map(*)?
{
  if ($function)
  then
    let $path-parameters :=
            for $token in fn:tokenize($path, "[{{}}]")[fn:starts-with(., "$")]
            return if (fn:contains($token, "=")) then fn:substring-before($token, "=") else $token

    let $responses-object :=
        if ($function//xqdoc:annotation[fn:starts-with(@name, "rest:produces")])
        then
            map {
                "content" : map:merge(
                    for $producer in $function//xqdoc:annotation[fn:starts-with(@name, "rest:produces")]
                    return
                    for $literal in $producer/xqdoc:literal
                    return map { xs:string($literal) : map { "schema": map { "type": "object" } } }
                )
            }
        else ()

    let $tags-array := (
              if (fn:contains(fn:base-uri($function), "/db/apps/"))
              then
              fn:substring-before(fn:substring-after(fn:base-uri($function), "/db/apps/"), "/")
              else (),
              for $tag in $function//xqdoc:custom[@tag = 'openapi-tag']
              return fn:normalize-space($tag/text())
    )

    let $request-body :=
        if ($function//xqdoc:annotation[fn:starts-with(@name, "rest:consumes")])
        then
            map {
                "content" : map:merge(
            for $consumer in $function//xqdoc:annotation[fn:starts-with(@name, "rest:consumes")]
            return
                for $literal in $consumer/xqdoc:literal
                let $consumes-opject := map { "schema" : map { "type" : "object" } }
                return map { xs:string($literal) : $consumes-opject }

                )
            }
        else ()

    let $parameters-array := (
                for $param in $function//xqdoc:annotation[fn:starts-with(@name, "rest:form-param")]
                let $name := $param/xqdoc:literal[1]/text()
                let $pname := xqdoc2openapi:param-name($param/xqdoc:literal[2])
                let $description := xqdoc2openapi:get-parameter-description($function, $param/xqdoc:literal[2])
                return xqdoc2openapi:parameter-object($name, $pname, "formData", $description, $function//xqdoc:parameters),
                for $param in $function//xqdoc:annotation[fn:starts-with(@name, "rest:query-param")]
                let $name := $param/xqdoc:literal[1]/text()
                let $pname := xqdoc2openapi:param-name($param/xqdoc:literal[2])
                let $description := xqdoc2openapi:get-parameter-description($function, $param/xqdoc:literal[2])
                return xqdoc2openapi:parameter-object($name, $pname, "query", $description, $function//xqdoc:parameters),
                for $param in $function//xqdoc:annotation[fn:starts-with(@name, "rest:header-param")]
                let $name := $param/xqdoc:literal[1]/text()
                let $pname := xqdoc2openapi:param-name($param/xqdoc:literal[2])
                let $description := xqdoc2openapi:get-parameter-description($function, $param/xqdoc:literal[2])
                return xqdoc2openapi:parameter-object($name, $pname, "header", $description, $function//xqdoc:parameters),
                for $param in $function//xqdoc:annotation[fn:starts-with(@name, "rest:cookie-param")]
                let $name := $param/xqdoc:literal[1]/text()
                let $pname := xqdoc2openapi:param-name($param/xqdoc:literal[2])
                let $description := xqdoc2openapi:get-parameter-description($function, $param/xqdoc:literal[2])
                return xqdoc2openapi:parameter-object($name, $pname, "cookie", $description, $function//xqdoc:parameters),
                for $param in $path-parameters
                let $name := fn:substring($param, 2)
                let $description := xqdoc2openapi:get-string-parameter-description($function, $param)
                return xqdoc2openapi:parameter-object($name, $name, "path", $description, $function//xqdoc:parameters)
    )
    return map:merge((
            map { "description" : fn:string-join($function/xqdoc:comment/xqdoc:description/text()) },
            map { "responses" : $responses-object },
            if (fn:count($tags-array) gt 0)
            then map { "tags" : array { $tags-array } }
            else (),
            if (fn:count($parameters-array) gt 0)
            then map { "parameters" : array { $parameters-array } }
            else (),
            if ($function//xqdoc:annotation[@name = ("rest:PUT", "rest:POST")])
            then map { "requestBody": $request-body }
            else ()
    ))
  else ()
};

(:~
 :)
declare function xqdoc2openapi:process-xqrs-to-xqDoc-to-OpenAPI()
as map(*)
{
let $functions := fn:collection("/db/system/xqDoc")//xqdoc:xqdoc/xqdoc:functions/xqdoc:function[xqdoc:annotations/xqdoc:annotation[@name = "rest:path"]]
let $path-names :=
    for $path in fn:distinct-values($functions//xqdoc:annotation[@name = "rest:path"]/xqdoc:literal[1]/text())
    order by $path
    return $path

let $paths :=
    for $path in $path-names
    let $path-functions := $functions[xqdoc:annotations/xqdoc:annotation[@name = "rest:path"][xqdoc:literal = $path]]
    let $services := (
          if (fn:not($path-functions[xqdoc:annotations/xqdoc:annotation[@name = $xqdoc2openapi:service-names]]))
          then
            let $function := $path-functions[xqdoc:annotations/xqdoc:annotation[fn:not(@name = $xqdoc2openapi:service-names)]][1]
            let $service-object := xqdoc2openapi:service-object($function, $path)
            return
              if (fn:exists($service-object))
              then
                if ($function//xqdoc:annotation[fn:starts-with(@name, "rest:form-param")])
                then map { "post" : $service-object }
                else map { "get" : $service-object }
              else ()
          else (),
          for $service-name in $xqdoc2openapi:service-names
          let $function := $path-functions[xqdoc:annotations/xqdoc:annotation[@name = $service-name]][1]
          let $service-object := xqdoc2openapi:service-object($function, $path)
          return
            if (fn:exists($service-object))
            then map { fn:lower-case(fn:substring-after($service-name, ":")) : $service-object }
            else ()
    )
    return map { fn:replace($path, "\{\$", "{") : map:merge($services) }
return map:merge($paths)
};
