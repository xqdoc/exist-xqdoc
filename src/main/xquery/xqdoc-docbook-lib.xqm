xquery version "3.1";
(:
 : Module Name:
 :
 : Module Version: 1.0
 :
 : Date: May 17, 2019
 :
 : Copyright (c) 2019. EasyMetaHub, LLC
 :
 : Proprietary
 : Extensions: eXist-db
 :
 : XQuery
 : Specification March 2017
 :
 : Module Overview:
 :
 :)

(:~
# Introduction

This module retrieves an xqDoc document based on the query parameter `rs:module`.
It then transforms that XML document to it's JSON equivalent for displaying
in a Polymer 3 webpage.
@author Loren Cahlander
@version 1.0
@since 1.0
 :)
module namespace xqdb = "http://xqdoc.org/resource/xqdoc/docbook";

declare namespace rest = "http://exquery.org/ns/restxq";

declare namespace xqdoc = "http://www.xqdoc.org/1.0";
declare namespace db = "http://docbook.org/ns/docbook";

(:~
 :  This variable defines the name for the xqDoc collection.
 :  The xqDoc XML for all modules should be stored into the
 :  XML database with this collection value.
 :)
declare variable $xqdb:XQDOC_COLLECTION as xs:string := "xqdoc";



declare function xqdb:comment-row($name as xs:string, $descriptions as node()*)
as element()*
{
    for $description in $descriptions
    return
        element {'db:row'} {
            element {'db:entry'} {$name},
            element {'db:entry'} {
                if (fn:string-length(fn:string-join($description/text())) gt 0)
                then
                    if ($name = "openapi")
                    then
                        element {'db:programlisting'} {
                            attribute {'language'} {'javascript'},
                            xs:string($description)
                        }
                    else
                        element {'db:para'} {
                            attribute { 'role' } { 'description' },
                            $description/text()
                        }
                else
                    element {'db:warning'} {
                        element {'db:para'} {'NO COMMENT!!'}
                    }
            }
        }
};

(:~
  Generates the JSON for an xqDoc comment
  @param $comment the xqdoc:comment element
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xqdb:comment($comment as node()?, $required as xs:boolean) {
    if ($comment)
    then
        (
        if (fn:string-length(fn:string-join($comment/xqdoc:description/text(), " ")) gt 0)
        then
            element {'db:para'} {
                attribute { 'role' } { 'description' },
                fn:replace(
                    fn:replace(
                        fn:string-join($comment/xqdoc:description/text(), " "),
                        "&amp;lt;",
                        "<"),
                        "&amp;gt;",
                        ">")
            }
        else
            element {'db:warning'} {
                element {'db:para'} {'NO COMMENT DESCRIPTION!!'}
            }
        ,
        if (fn:exists(($comment//xqdoc:author,
        $comment//xqdoc:version,
        $comment//xqdoc:error,
        $comment//xqdoc:deprecated,
        $comment//xqdoc:see,
        $comment//xqdoc:since,
        $comment//xqdoc:custom
        )))
        then
            element {'db:table'} {
                attribute {'frame'} {"all"},
                attribute {'rowsep'} {"1"},
                attribute {'colsep'} {"1"},
                element {'db:title'} {'xqDoc'},
                element {'db:tgroup'} {
                    attribute {'cols'} {"2"},
                    attribute {'align'} {"left"},
                    element {'db:colspec'} {
                        attribute {'colname'} {"c1"},
                        attribute {'colnum'} {"1"},
                        attribute {'colwidth'} {"1*"},
                        attribute {'align'} {"left"},
                        attribute {'colsep'} {"1"},
                        attribute {'rowsep'} {"1"}
                    },
                    element {'db:colspec'} {
                        attribute {'colname'} {"c2"},
                        attribute {'colnum'} {"2"},
                        attribute {'colsep'} {"1"},
                        attribute {'rowsep'} {"1"},
                        attribute {'colwidth'} {"7*"}
                    },
                    element {'db:thead'} {
                        element {'db:row'} {
                            attribute {'valign'} {"top"},
                            attribute {'rowsep'} {"1"},
                            element {'db:entry'} {
                                attribute {'align'} {"left"},
                                attribute {'valign'} {"top"},
                                attribute {'colsep'} {"1"},
                                attribute {'rowsep'} {"1"}, "Type"
                            },
                            element {'db:entry'} {"Description"}
                        }
                    },
                    element {'db:tbody'} {
                        xqdb:comment-row("Author", $comment//xqdoc:author),
                        xqdb:comment-row("Version", $comment//xqdoc:version),
                        xqdb:comment-row("Error", $comment//xqdoc:error),
                        xqdb:comment-row("Deprecated", $comment//xqdoc:deprecated),
                        xqdb:comment-row("See", $comment//xqdoc:see),
                        xqdb:comment-row("Since", $comment//xqdoc:since),
                        for $custom in $comment//xqdoc:custom
                        return
                            xqdb:comment-row(xs:string($custom/@tag), $custom),
                        ()
                    }
                }
            }


        else
            ()
        )
    else
        if ($required)
        then
            element {'db:warning'} {
                element {'db:para'} {'NO COMMENT SECTION!!'}
            }
        else
            ()
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
declare function xqdb:occurrence($type as node()?)
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
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xqdb:functions($functions as node()*, $module-uri as xs:string?) {
    for $function in $functions
    let $name := fn:string-join($function/xqdoc:name/text())
    let $function-comment := $function/xqdoc:comment
        order by $name
    return
        element {'db:section'} {
            element {'db:title'} {$name},
            xqdb:comment($function-comment, fn:true()),
            element {'db:para'} {fn:string-join($function/xqdoc:signature/text(), " ")},
            if ($function/xqdoc:annotations)
            then
                (
                element {'db:table'} {
                    attribute {'frame'} {"all"},
                    attribute {'rowsep'} {"1"},
                    attribute {'colsep'} {"1"},
                    element {'db:title'} {'Annotations'},
                    element {'db:tgroup'} {
                        attribute {'cols'} {"2"},
                        attribute {'align'} {"left"},
                        element {'db:colspec'} {
                            attribute {'colname'} {"c1"},
                            attribute {'colnum'} {"1"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c2"},
                            attribute {'colnum'} {"2"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"},
                            attribute {'colwidth'} {"3*"}
                        },
                        element {'db:thead'} {
                            element {'db:row'} {
                                attribute {'valign'} {"top"},
                                attribute {'rowsep'} {"1"},
                                element {'db:entry'} {
                                    attribute {'align'} {"left"},
                                    attribute {'valign'} {"top"},
                                    attribute {'colsep'} {"1"},
                                    attribute {'rowsep'} {"1"}, "Annotation"
                                },
                                element {'db:entry'} {"Literals"}
                            }
                        },
                        element {'db:tbody'} {
                            for $annotation in $function/xqdoc:annotations/xqdoc:annotation
                            return
                                element {'db:row'} {
                                    element {'db:entry'} {xs:string($annotation/@name)},
                                    element {'db:entry'} {
                                        fn:string-join($annotation/xqdoc:literal, "; ")
                                    }
                                }
                        }
                    }
                }
                )
            else
                (),
            if ($function/xqdoc:parameters)
            then
                (
                element {'db:table'} {
                    attribute {'frame'} {"all"},
                    attribute {'rowsep'} {"1"},
                    attribute {'colsep'} {"1"},
                    element {'db:title'} {'Parameters'},
                    element {'db:tgroup'} {
                        attribute {'cols'} {"4"},
                        attribute {'align'} {"left"},
                        element {'db:colspec'} {
                            attribute {'colname'} {"c1"},
                            attribute {'colnum'} {"1"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c2"},
                            attribute {'colnum'} {"2"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c3"},
                            attribute {'colnum'} {"3"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c4"},
                            attribute {'colnum'} {"4"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"},
                            attribute {'colwidth'} {"2*"}
                        },
                        element {'db:thead'} {
                            element {'db:row'} {
                                attribute {'valign'} {"top"},
                                attribute {'rowsep'} {"1"},
                                element {'db:entry'} {
                                    attribute {'align'} {"left"},
                                    attribute {'valign'} {"top"},
                                    attribute {'colsep'} {"1"},
                                    attribute {'rowsep'} {"1"}, "Parameter"
                                },
                                element {'db:entry'} {"Type"},
                                element {'db:entry'} {"Occurrence"},
                                element {'db:entry'} {"Description"}
                            }
                        },
                        element {'db:tbody'} {
                            for $parameter in $function/xqdoc:parameters/xqdoc:parameter
                            let $ptest := '$' || $parameter/xqdoc:name/text()
                            let $param := $function//xqdoc:param[fn:starts-with(., $ptest)]
                            let $pbody := fn:substring(fn:string-join($param/text(), " "), fn:string-length($ptest) + 1)
                            let $description := replace($pbody, '^\s+', '')
                            let $type := fn:string-join($parameter/xqdoc:type/text(), " ")
                            return
                                element {'db:row'} {
                                    element {'db:entry'} {fn:string-join($parameter/xqdoc:name/text(), " ")},
                                    element {'db:entry'} {
                                        if (fn:string-length($type) gt 0)
                                        then
                                            element {'db:para'} {$type}
                                        else
                                            element {'db:warning'} {
                                                element {'db:para'} {'NO DATA TYPE SPECIFIED!!'}
                                            }
                                    },
                                    element {'db:entry'} {xqdb:occurrence($parameter/xqdoc:type)},
                                    element {'db:entry'} {
                                        if (fn:string-length($description) gt 0)
                                        then
                                            element {'db:para'} {
                                                attribute { 'role' } { 'description' },
                                                $description
                                            }
                                        else
                                            element {'db:warning'} {
                                                element {'db:para'} {'NO COMMENT!!'}
                                            }
                                    }
                                }
                        }
                    }
                }
                )
            else
                (),
            if ($function/xqdoc:return)
            then
                element {'db:table'} {
                    attribute {'frame'} {"all"},
                    attribute {'rowsep'} {"1"},
                    attribute {'colsep'} {"1"},
                    element {'db:title'} {'Return'},
                    element {'db:tgroup'} {
                        attribute {'cols'} {"3"},
                        attribute {'align'} {"left"},
                        element {'db:colspec'} {
                            attribute {'colname'} {"c1"},
                            attribute {'colnum'} {"1"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c2"},
                            attribute {'colnum'} {"2"},
                            attribute {'colwidth'} {"1*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c3"},
                            attribute {'colnum'} {"3"},
                            attribute {'colwidth'} {"4*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:thead'} {
                            element {'db:row'} {
                                attribute {'valign'} {"top"},
                                attribute {'rowsep'} {"1"},
                                element {'db:entry'} {"Type"},
                                element {'db:entry'} {"Occurrence"},
                                element {'db:entry'} {"Description"}
                            }
                        },
                        element {'db:tbody'} {
                            element {'db:row'} {
                                element {'db:entry'} {
                                    if (fn:string-length(xs:string($function/xqdoc:return/xqdoc:type)) gt 0)
                                    then
                                        fn:string-join($function/xqdoc:return/xqdoc:type/text(), " ")
                                    else
                                        "empty-sequence()"
                                },
                                element {'db:entry'} {
                                    if (fn:string-length(xs:string($function/xqdoc:return/xqdoc:type)) gt 0)
                                    then
                                        xqdb:occurrence($function/xqdoc:return/xqdoc:type)
                                    else
                                        ""
                                },
                                element {'db:entry'} {
                                    if (fn:string-length($function/xqdoc:comment/xqdoc:return) gt 0)
                                    then
                                        element { 'db:para' } {
                                            attribute { 'role' } { 'description' },
                                            xs:string($function/xqdoc:comment/xqdoc:return)
                                        }
                                    else
                                        element {'db:warning'} {
                                            element {'db:para'} {'NO COMMENT!!'}
                                        }
                                }
                            }
                        }
                    }
                }
            else
                element {'db:warning'} {
                    element {'db:para'} {'NO RETURN TYPE SPECIFIED!!'}
                },
            if ($function/xqdoc:invoked)
            then
                element {'db:table'} {
                    attribute {'frame'} {"all"},
                    attribute {'rowsep'} {"1"},
                    attribute {'colsep'} {"1"},
                    element {'db:title'} {'Functions Invoked'},
                    element {'db:tgroup'} {
                        attribute {'cols'} {"2"},
                        attribute {'align'} {"left"},
                        element {'db:colspec'} {
                            attribute {'colname'} {"c1"},
                            attribute {'colnum'} {"1"},
                            attribute {'colwidth'} {"3*"},
                            attribute {'align'} {"left"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"}
                        },
                        element {'db:colspec'} {
                            attribute {'colname'} {"c2"},
                            attribute {'colnum'} {"2"},
                            attribute {'colsep'} {"1"},
                            attribute {'rowsep'} {"1"},
                            attribute {'colwidth'} {"1*"}
                        },
                        element {'db:thead'} {
                            element {'db:row'} {
                                attribute {'valign'} {"top"},
                                attribute {'rowsep'} {"1"},
                                element {'db:entry'} {
                                    attribute {'align'} {"left"},
                                    attribute {'valign'} {"top"},
                                    attribute {'colsep'} {"1"},
                                    attribute {'rowsep'} {"1"}, "URI"
                                },
                                element {'db:entry'} {"Name"}
                            }
                        },
                        element {'db:tbody'} {
                            for $uri in fn:distinct-values($function/xqdoc:invoked/xqdoc:uri/text())
                            let $trimmed-uri :=
                            if (fn:starts-with($uri, '"'))
                            then
                                fn:substring(fn:substring($uri, 1, fn:string-length($uri) - 1), 2)
                            else
                                $uri
                                order by $trimmed-uri
                            return
                                for $invoke in $function/xqdoc:invoked[xqdoc:uri = $uri]
                                let $name := $invoke/xqdoc:name/text()
                                    order by $name
                                return
                                    element {'db:row'} {
                                        element {'db:entry'} {$trimmed-uri},
                                        element {'db:entry'} {$name}
                                    }
                        }
                    }
                }
            else
                ()
        }
};

(:~
  @param $variables A sequence of the xqdoc:variable elements
  @param $module-uri The URI of the selected module
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xqdb:variables($variables as node()*, $module-uri as xs:string?) {
    element {'db:table'} {
        attribute {'frame'} {"all"},
        attribute {'rowsep'} {"1"},
        attribute {'colsep'} {"1"},
        element {'db:title'} {'Variables'},
        element {'db:tgroup'} {
            attribute {'cols'} {"3"},
            attribute {'align'} {"left"},
            element {'db:colspec'} {
                attribute {'colname'} {"c1"},
                attribute {'colnum'} {"1"},
                attribute {'colwidth'} {"1*"},
                attribute {'align'} {"left"},
                attribute {'colsep'} {"1"},
                attribute {'rowsep'} {"1"}
            },
            element {'db:colspec'} {
                attribute {'colname'} {"c2"},
                attribute {'colnum'} {"2"},
                attribute {'colwidth'} {"2*"},
                attribute {'align'} {"left"},
                attribute {'colsep'} {"1"},
                attribute {'rowsep'} {"1"}
            },
            element {'db:colspec'} {
                attribute {'colname'} {"c3"},
                attribute {'colnum'} {"3"},
                attribute {'colwidth'} {"2*"},
                attribute {'align'} {"left"},
                attribute {'colsep'} {"1"},
                attribute {'rowsep'} {"1"}
            },
            element {'db:thead'} {
                element {'db:row'} {
                    attribute {'valign'} {"top"},
                    attribute {'rowsep'} {"1"},
                    element {'db:entry'} {"Name"},
                    element {'db:entry'} {"Namespace"},
                    element {'db:entry'} {"Description"}
                }
            },
            element {'db:tbody'} {
                for $variable in $variables
                let $uri := $variable/xqdoc:uri/text()
                let $name := $variable/xqdoc:name/text()
                return
                    element {'db:row'} {
                        element {'db:entry'} {$name},
                        element {'db:entry'} {$uri},
                        element {'db:entry'} {
                            xqdb:comment($variable/xqdoc:comment, fn:false())
                        }
                    }
            }
        }
    }
};

(:~
  @param $imports A sequence of the xqdoc:import elements
  @author Loren Cahlander
  @version 1.0
  @since 1.0
 :)
declare function xqdb:imports($imports as node()*)
as element()*
{
    element {'db:table'} {
        attribute {'frame'} {"all"},
        attribute {'rowsep'} {"1"},
        attribute {'colsep'} {"1"},
        element {'db:title'} {'Imports'},
        element {'db:tgroup'} {
            attribute {'cols'} {"2"},
            attribute {'align'} {"left"},
            element {'db:colspec'} {
                attribute {'colname'} {"c1"},
                attribute {'colnum'} {"1"},
                attribute {'colwidth'} {"1.5*"},
                attribute {'align'} {"left"},
                attribute {'colsep'} {"1"},
                attribute {'rowsep'} {"1"}
            },
            element {'db:colspec'} {
                attribute {'colname'} {"c2"},
                attribute {'colnum'} {"2"},
                attribute {'colsep'} {"1"},
                attribute {'rowsep'} {"1"},
                attribute {'colwidth'} {"1*"}
            },
            element {'db:thead'} {
                element {'db:row'} {
                    attribute {'valign'} {"top"},
                    attribute {'rowsep'} {"1"},
                    element {'db:entry'} {
                        attribute {'align'} {"left"},
                        attribute {'valign'} {"top"},
                        attribute {'colsep'} {"1"},
                        attribute {'rowsep'} {"1"}, "Namespace"
                    },
                    element {'db:entry'} {"Description"}
                }
            },
            element {'db:tbody'} {
                for $import in $imports
                let $uri := $import/xqdoc:uri/text()
                return
                    element {'db:row'} {
                        element {'db:entry'} {fn:substring(fn:substring($uri, 1, fn:string-length($uri) - 1), 2)},
                        element {'db:entry'} {
                            xqdb:comment($import/xqdoc:comment, fn:false())
                        }
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
declare function xqdb:module(
$doc as node(),
$filename as xs:string
)
as element()
{
    let $module-comment := $doc/xqdoc:module/xqdoc:comment
    return
        element {'db:section'} {
            element {'db:title'} {
                ($doc/xqdoc:module/xqdoc:name/text(), $filename)[1]
            },
            if ($doc/xqdoc:module/@type = "library")
            then
                (
                element { 'db:para' } { $filename },
                element { 'db:para' } { $doc/xqdoc:module/xqdoc:uri/text() }
                )
            else (),
            xqdb:comment($module-comment, fn:true()),
            if ($doc/xqdoc:variables)
            then
                element {'db:section'} {
                    element {'db:title'} {'Variables'},
                    xqdb:variables($doc/xqdoc:variables/xqdoc:variable, $doc/xqdoc:module/xqdoc:uri/text())
                }
            else
                (),
            if ($doc/xqdoc:imports)
            then
                element {'db:section'} {
                    element {'db:title'} {'Imports'},
                    xqdb:imports($doc/xqdoc:imports/xqdoc:import)
                }
            else
                (),
            if ($doc/xqdoc:functions)
            then
                element {'db:section'} {
                    element {'db:title'} {'Functions'},
                    xqdb:functions($doc/xqdoc:functions/xqdoc:function, $doc/xqdoc:module/xqdoc:uri/text())
                }
            else
                ()
        }
};
