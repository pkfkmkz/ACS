package cern.cmw.mom.pubsub;


/**
 * Public interface. Notification periodically generated for any active subscription.
 * The frequency is determined by the property <blockquote><pre>cmw.mom.keepalive</blockquote></pre>,
 * representing the number of seconds between each notification (0 if keep-alive notifications
 * are not needed).
 * @version 1.0   23 Jan 2001
 * @author   Controls Middleware Project
 */
public interface ConsumerAliveNotification extends Notification {
  /**
   * Return the topic related to the active subscription.
   * @return String The topic name
   *
   * @throws jakarta.jms.JMSException
   */
  public String getTopicName() throws jakarta.jms.JMSException;

  /**
   * Return the selector related to the active subscription.
   * @return String The selector
   *
   * @throws jakarta.jms.JMSException
   */
  public String getSelector() throws jakarta.jms.JMSException;

  /**
   * Return the unique subscription identifier.
   * @return String The subscription id
   *
   * @throws jakarta.jms.JMSException
   */
  public String getSubscriptionId() throws jakarta.jms.JMSException;
}

