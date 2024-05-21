package cern.cmw.mom.pubsub;

import jakarta.jms.MessageListener;


/**
 * Public interface. The method <b>void onMessage(Message)</b> has to be
 * implemented to handle message reception. The example below shows a possible implementation :
 * <P><blockquote><pre>
 * class myListener implements SubscriptionListener {
 * ...
 * public void onMessage(jakarta.jms.Message message) {
 *   try {
 *     jakarta.jms.TextMessage msg = (jakarta.jms.TextMessage)message;
 *     System.out.println("Got message  : " + msg.getText());
 *     if (msg.getText().equals("bye")) {
 *       System.out.println("Time to close!");
 *       exit(0);
 *     }
 *   } catch(jakarta.jms.JMSException je) {
 *     System.out.println("JMSException raised while processing message: "+message);
 *     je.printStackTrace();
 *   }
 * }
 * ...
 * }
 * <P></blockquote></pre>
 *
 * @version 1.0   23 Jan 2001
 * @author   Controls Middleware Project
 */
public interface SubscriptionListener extends MessageListener {
}
