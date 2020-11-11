package org.xqdoc.exist;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.exist.dom.memtree.DocumentImpl;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.util.DocUtils;
import org.exist.xquery.value.IntegerValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.StringValue;
import org.exist.xquery.value.Type;
import org.xqdoc.XQueryVisitor;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.HashMap;

import static org.exist.xquery.FunctionDSL.*;

/**
 * Some very simple XQuery xqdoc functions implemented
 * in Java.
 */
public class XQDocFunctions extends BasicFunction {

    private static final String FS_PARSE_NAME = "parse";
    static final FunctionSignature FS_PARSE = XQDocModule.functionSignature(
            FS_PARSE_NAME,
            "An xqdoc function that returns <hello>{$name}</hello>.",
            returns(Type.DOCUMENT),
            param("name", Type.STRING, "A name")
    );

    public XQDocFunctions(final XQueryContext context, final FunctionSignature signature) {
        super(context, signature);
    }

    @Override
    public Sequence eval(final Sequence[] args, final Sequence contextSequence) throws XPathException {
        switch (getName().getLocalPart()) {

            case FS_PARSE_NAME:
                return parseXQuery((StringValue) args[0].itemAt(0));

            default:
                throw new XPathException(this, "No function: " + getName() + "#" + getSignature().getArgumentCount());
        }
    }

    /**
     * Creates an XML document like <hello>name</hello>.
     *
     * @param name An optional name, if empty then "stranger" is used.
     *
     * @return An XML document
     */
    private DocumentImpl parseXQuery(final StringValue name) throws XPathException {
        HashMap<String, String> uriMap = new HashMap<String,String>();
        uriMap.put("lucene", "http://exist-db.org/xquery/lucene");
        uriMap.put("ngram", "http://exist-db.org/xquery/ngram");
        uriMap.put("sort", "http://exist-db.org/xquery/sort");
        uriMap.put("range", "http://exist-db.org/xquery/range");
        uriMap.put("spatial", "http://exist-db.org/xquery/spatial");
        uriMap.put("inspection", "http://exist-db.org/xquery/inspection");
        uriMap.put("mail", "http://exist-db.org/xquery/mail");
        uriMap.put("request", "http://exist-db.org/xquery/request");
        uriMap.put("response", "http://exist-db.org/xquery/response");
        uriMap.put("sm", "http://exist-db.org/xquery/securitymanager");
        uriMap.put("session", "http://exist-db.org/xquery/session");
        uriMap.put("system", "http://exist-db.org/xquery/system");
        uriMap.put("transform", "http://exist-db.org/xquery/transform");
        uriMap.put("util", "http://exist-db.org/xquery/util");
        uriMap.put("validation", "http://exist-db.org/xquery/validation");
        uriMap.put("xmldb", "http://exist-db.org/xquery/xmldb");
        uriMap.put("map", "http://www.w3.org/2005/xpath-functions/map");
        uriMap.put("math", "http://www.w3.org/2005/xpath-functions/math");
        uriMap.put("array", "http://www.w3.org/2005/xpath-functions/array");
        uriMap.put("process", "http://exist-db.org/xquery/process");
        uriMap.put("xs", "http://www.w3.org/2001/XMLSchema"); // XML Schema namespace
        CharStream inputStream = CharStreams.fromString(name.getStringValue());
        org.xqdoc.XQueryLexer markupLexer = new org.xqdoc.XQueryLexer(inputStream);
        CommonTokenStream commonTokenStream = new CommonTokenStream(markupLexer);
        org.xqdoc.XQueryParser markupParser = new org.xqdoc.XQueryParser(commonTokenStream);

        org.xqdoc.XQueryParser.ModuleContext fileContext = markupParser.module();
        StringBuilder buffer = new StringBuilder();


        XQueryVisitor visitor = new XQueryVisitor(buffer, uriMap);
        visitor.visit(fileContext);
        InputStream targetStream = new ByteArrayInputStream(buffer.toString().getBytes());
        return DocUtils.parse(context, targetStream);
    }

    /**
     * Adds two numbers together.
     *
     * @param a The first number
     * @param b The second number
     *
     * @return The result;
     */
    private IntegerValue add(final IntegerValue a, final IntegerValue b) throws XPathException {
        final int result = a.getInt() + b.getInt();
        return new IntegerValue(result);
    }
}
