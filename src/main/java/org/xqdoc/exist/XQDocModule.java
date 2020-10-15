package org.xqdoc.exist;

import org.exist.dom.QName;
import org.exist.xquery.*;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;

import java.util.List;
import java.util.Map;

import static org.exist.xquery.FunctionDSL.functionDefs;

/**
 * A very simple xqdoc XQuery Library Module implemented
 * in Java.
 */
public class XQDocModule extends AbstractInternalModule {

    public static final String NAMESPACE_URI = "https://xqdoc.org/exist-db/ns/app/my-java-module";
    public static final String PREFIX = "myjmod";
    public static final String RELEASED_IN_VERSION = "eXist-3.6.0";

    // register the functions of the module
    public static final FunctionDef[] functions = functionDefs(
        functionDefs(XQDocFunctions.class,
                XQDocFunctions.FS_HELLO_WORLD,
                XQDocFunctions.FS_SAY_HELLO,
                XQDocFunctions.FS_ADD
        )
    );

    public XQDocModule(final Map<String, List<? extends Object>> parameters) {
        super(functions, parameters);
    }

    @Override
    public String getNamespaceURI() {
        return NAMESPACE_URI;
    }

    @Override
    public String getDefaultPrefix() {
        return PREFIX;
    }

    @Override
    public String getDescription() {
        return "xqDoc Module for eXist-db XQuery";
    }

    @Override
    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }

    static FunctionSignature functionSignature(final String name, final String description,
            final FunctionReturnSequenceType returnType, final FunctionParameterSequenceType... paramTypes) {
        return FunctionDSL.functionSignature(new QName(name, NAMESPACE_URI), description, returnType, paramTypes);
    }

    static FunctionSignature[] functionSignatures(final String name, final String description,
            final FunctionReturnSequenceType returnType, final FunctionParameterSequenceType[][] variableParamTypes) {
        return FunctionDSL.functionSignatures(new QName(name, NAMESPACE_URI), description, returnType, variableParamTypes);
    }

    static class ExpathBinModuleErrorCode extends ErrorCodes.ErrorCode {
        private ExpathBinModuleErrorCode(final String code, final String description) {
            super(new QName(code, NAMESPACE_URI, PREFIX), description);
        }
    }
}
