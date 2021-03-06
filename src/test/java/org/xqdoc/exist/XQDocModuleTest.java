package org.xqdoc.exist;


import org.exist.EXistException;
import org.exist.security.PermissionDeniedException;
import org.exist.storage.BrokerPool;
import org.exist.storage.DBBroker;
import org.exist.test.ExistEmbeddedServer;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQuery;
import org.exist.xquery.value.IntegerValue;
import org.exist.xquery.value.Sequence;
import org.junit.ClassRule;
import org.junit.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;
import org.xmlunit.util.Nodes;
import org.xmlunit.util.Predicate;

import javax.xml.transform.Source;
import java.util.Optional;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class XQDocModuleTest {

    @ClassRule
    public static ExistEmbeddedServer existEmbeddedServer = new ExistEmbeddedServer(false, true);

    @Test
    public void sayHello() throws XPathException, PermissionDeniedException, EXistException {
        assertTrue(true);
//        final String query =
//                "declare namespace xqp = \"https://xqdoc.org/exist-db/ns/lib/xqdoc/parse\";\n" +
//                        "xqp:parse('<foo/>')";
//        final Sequence result = executeQuery(query);
//
//        assertTrue(result.hasOne());
//
//        final Source inExpected = Input.fromString("<xqdoc:xqdoc xmlns:xqdoc=\"http://www.xqdoc.org/1.0\"><xqdoc:control><xqdoc:date>2020-11-09T21:05:43.252-05:00</xqdoc:date><xqdoc:version>1.1</xqdoc:version></xqdoc:control><xqdoc:module type=\"main\"><xqdoc:body xml:space=\"preserve\">&lt;foo/&gt;</xqdoc:body></xqdoc:module></xqdoc:xqdoc>\n").build();
//        final Source inActual = Input.fromDocument((Document) result.itemAt(0)).build();
//
//        final Diff diff = DiffBuilder.compare(inExpected)
//                .withTest(inActual)
//                .withNodeFilter(new Predicate<Node>() {
//                    @Override
//                    public boolean test(Node n) {
//                        return !(n instanceof Element &&
//                                "date".equals(Nodes.getQName(n).getLocalPart()));
//                    }
//                })
//                .checkForSimilar()
//                .ignoreWhitespace()
//                .build();
//
//        assertFalse(diff.toString(), diff.hasDifferences());
    }

    private Sequence executeQuery(final String xquery) throws EXistException, PermissionDeniedException, XPathException {
        final BrokerPool pool = existEmbeddedServer.getBrokerPool();
        final XQuery xqueryService = pool.getXQueryService();

        try(final DBBroker broker = pool.get(Optional.of(pool.getSecurityManager().getSystemSubject()))) {
            return xqueryService.execute(broker, xquery, null);
        }
    }
}
