package cern.cmw.mom.test;



import cern.cmw.mom.pubsub.*;
import cern.cmw.mom.util.*;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import java.io.*;


/**
 * Publisher&Subscriber test example.
 */
public class TestPkgSimple implements SubscriptionListener {

    private final static Logger log = LogManager.getLogger(TestPkgSimple.class.getName());
    private final static String   TOPIC             = "CMW.TEMP";
    private final static String   MSG               = "high";
    private Publisher             p                 = null;
    private Subscriber            s                 = null;
    private long                  subscriptionToken = 0;

    /**
     * Constructor TestPkgSimple
     *
     *
     */
    public TestPkgSimple() {

        try {
            p = PubSubFactory.publisher();

            log.debug("Publisher allocated.");

            s = PubSubFactory.subscriber();

            log.debug("Subscriber allocated.");

            subscriptionToken = s.subscribe(TOPIC, this, null);

            log.debug("Subscription done.");

            BufferedReader in   = new BufferedReader(new InputStreamReader(System.in));
            boolean        flag = true;

            while (flag) {
                log.debug("Messaggio : ");

                String s = in.readLine();

                if (s.equals("bye")) {
                    flag = false;
                }

                jakarta.jms.TextMessage text = p.createTextMessage();

                text.setText(s);
                p.publish(TOPIC, text);
                log.debug("Publication done.");
            }

            log.debug("Closing the publisher...");
            p.close();
            log.debug("Closing the subscriber...");
            s.unSubscribe(subscriptionToken);
            s.close();
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Method onMessage
     *
     *
     * @param message
     *
     */
    public void onMessage(jakarta.jms.Message message) {

        // Subscriber implementation of the listener
        try {
            jakarta.jms.TextMessage msg = (jakarta.jms.TextMessage) message;

            log.debug("Got message  : " + msg.getText());
        } catch (jakarta.jms.JMSException e) {
            log.debug("Error processing message: " + message);
        }
    }

    /**
     * Method main
     *
     *
     * @param args
     *
     */
    public static void main(String[] args) {

        TestPkgSimple testPkg1 = new TestPkgSimple();
    }
}


/*--- Formatted in Sun Java Convention Style on Mon, Sep 24, '01 ---*/


/*------ Formatted by Jindent 3.23 Gold 1.02 --- http://www.jindent.de ------*/
