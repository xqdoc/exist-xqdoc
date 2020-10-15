package org.xqdoc.exist;

import org.exist.collections.Collection;
import org.exist.collections.triggers.DocumentTrigger;
import org.exist.collections.triggers.TriggerException;
import org.exist.dom.persistent.DocumentImpl;
import org.exist.storage.DBBroker;
import org.exist.storage.txn.Txn;
import org.exist.xmldb.XmldbURI;

import java.util.List;
import java.util.Map;

public class XQDocDocumentTrigger implements DocumentTrigger {
    @Override
    public void beforeCreateDocument(DBBroker dbBroker, Txn txn, XmldbURI xmldbURI) throws TriggerException {
        
    }

    @Override
    public void afterCreateDocument(DBBroker dbBroker, Txn txn, DocumentImpl document) throws TriggerException {

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
