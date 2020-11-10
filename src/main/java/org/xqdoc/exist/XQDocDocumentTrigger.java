package org.xqdoc.exist;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.exist.EXistException;
import org.exist.collections.Collection;
import org.exist.collections.triggers.DocumentTrigger;
import org.exist.collections.triggers.TriggerException;
import org.exist.dom.persistent.BinaryDocument;
import org.exist.dom.persistent.DocumentImpl;
import org.exist.source.DBSource;
import org.exist.source.Source;
import org.exist.storage.DBBroker;
import org.exist.storage.txn.Txn;
import org.exist.xmldb.XmldbURI;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xqdoc.DocumentUtility;
import org.xqdoc.XQueryVisitor;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class XQDocDocumentTrigger implements DocumentTrigger {
    @Override
    public void beforeCreateDocument(DBBroker dbBroker, Txn txn, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public void afterCreateDocument(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {
        if (document.getResourceType() == DocumentImpl.BINARY_FILE) {
            BinaryDocument bdoc = (BinaryDocument)document;
            final String documentURI = bdoc.getDocumentURI();
            if (documentURI.matches("(.*)\\.xq(.*)")) {
                Source source = null;
                try {
                    source = new DBSource(document.getBrokerPool().getBroker(),
                            bdoc,
                            true);
                } catch (EXistException e) {
                    e.printStackTrace();
                }

                if (source != null) {
                    try {
                        final String content = source.getContent();
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
                        CharStream inputStream = CharStreams.fromString(content);
                        org.xqdoc.XQueryLexer markupLexer = new org.xqdoc.XQueryLexer(inputStream);
                        CommonTokenStream commonTokenStream = new CommonTokenStream(markupLexer);
                        org.xqdoc.XQueryParser markupParser = new org.xqdoc.XQueryParser(commonTokenStream);

                        org.xqdoc.XQueryParser.ModuleContext fileContext = markupParser.module();
                        StringBuilder buffer = new StringBuilder();


                        XQueryVisitor visitor = new XQueryVisitor(buffer, uriMap);
                        visitor.visit(fileContext);
                        final Document documentFromBuffer = DocumentUtility.getDocumentFromBuffer(buffer);
                    } catch (IOException e) {
                        e.printStackTrace();
                    } catch (SAXException e) {
                        e.printStackTrace();
                    } catch (ParserConfigurationException e) {
                        e.printStackTrace();
                    }
                }

            }
        }
    }

    @Override
    public void beforeUpdateDocument(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

    }

    @Override
    public void afterUpdateDocument(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

    }

    @Override
    public void beforeUpdateDocumentMetadata(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

    }

    @Override
    public void afterUpdateDocumentMetadata(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

    }

    @Override
    public void beforeCopyDocument(DBBroker dbBroker, Txn txn, DocumentImpl document, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public void afterCopyDocument(DBBroker dbBroker, Txn txn, DocumentImpl document, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public void beforeMoveDocument(DBBroker dbBroker, Txn txn, DocumentImpl document, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public void afterMoveDocument(DBBroker dbBroker, Txn txn, DocumentImpl document, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public void beforeDeleteDocument(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

    }

    @Override
    public void afterDeleteDocument(DBBroker dbBroker, Txn txn, XmldbURI xmldbURI) throws TriggerException {

    }

    @Override
    public boolean isValidating() {
        return false;
    }

    @Override
    public void setValidating(boolean b) {

    }

    @Override
    public void configure(DBBroker dbBroker, Txn txn, Collection collection, Map<String, List<?>> map) throws TriggerException {

    }
}
