xquery version "3.1";

(:~
 : A very simple xqdoc XQuery Library Module implemented
 : in XQuery.
 :)
module namespace myxqmod = "https://xqdoc.org/exist-db/ns/app/my-xquery-module";

declare function myxqmod:say-hello($name as xs:string?) as document-node(element(hello)) {
    document {
        element hello {
            if($name) then
                $name
            else
                "stranger"
        }
    }
};

declare function myxqmod:hello-world() as document-node(element(hello)) {
    myxqmod:say-hello("world")
};

declare function myxqmod:add($a as xs:int, $b as xs:int) as xs:int {
    $a + $b
};
