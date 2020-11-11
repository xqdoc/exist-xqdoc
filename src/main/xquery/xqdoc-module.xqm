xquery version "3.1";

(:~
 : A very simple xqdoc XQuery Library Module implemented
 : in XQuery.
 :)
module namespace xqutil = "https://xqdoc.org/exist-db/ns/lib/xqdoc/util";

declare function xqutil:say-hello($name as xs:string?) as document-node(element(hello)) {
    document {
        element hello {
            if($name) then
                $name
            else
                "stranger"
        }
    }
};

declare function xqutil:hello-world() as document-node(element(hello)) {
    xqutil:say-hello("world")
};

declare function xqutil:add($a as xs:int, $b as xs:int) as xs:int {
    $a + $b
};
