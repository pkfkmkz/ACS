/*******************************************************************************
 * ALMA - Atacama Large Millimeter Array
 * Copyright (c) COSYLAB - Control System Laboratory, 2011
 * (in the framework of the ALMA collaboration).
 * All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 *******************************************************************************/
/*
 * Created on Jun 24, 2004
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package com.cosylab.acs.jms;

import java.io.Serializable;

import jakarta.jms.BytesMessage;
import jakarta.jms.Destination;
import jakarta.jms.JMSException;
import jakarta.jms.MapMessage;
import jakarta.jms.Message;
import jakarta.jms.MessageConsumer;
import jakarta.jms.MessageListener;
import jakarta.jms.MessageProducer;
import jakarta.jms.ObjectMessage;
import jakarta.jms.Queue;
import jakarta.jms.QueueBrowser;
import jakarta.jms.Session;
import jakarta.jms.StreamMessage;
import jakarta.jms.TemporaryQueue;
import jakarta.jms.TemporaryTopic;
import jakarta.jms.TextMessage;
import jakarta.jms.Topic;
import jakarta.jms.TopicSubscriber;

import alma.acs.container.ContainerServicesBase;

/**
 * @author kzagar
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class ACSJMSSession implements Session {

	protected ContainerServicesBase containerServices;

	public ACSJMSSession(ContainerServicesBase containerServices)
	{
		if (containerServices==null) {
			throw new IllegalArgumentException("Invalid null ContainerServices");
		}
		this.containerServices = containerServices;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createBytesMessage()
	 */
	public BytesMessage createBytesMessage() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createMapMessage()
	 */
	public MapMessage createMapMessage() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createMessage()
	 */
	public Message createMessage() throws JMSException {
		return new ACSJMSMessage(containerServices);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createObjectMessage()
	 */
	public ObjectMessage createObjectMessage() throws JMSException 
	{
		return new ACSJMSObjectMessage(containerServices);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createObjectMessage(java.io.Serializable)
	 */
	public ObjectMessage createObjectMessage(Serializable obj)
		throws JMSException 
	{
		ObjectMessage result = new ACSJMSObjectMessage(obj,containerServices);
		return result;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createStreamMessage()
	 */
	public StreamMessage createStreamMessage() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createTextMessage()
	 */
	public TextMessage createTextMessage() throws JMSException {
		return new ACSJMSTextMessage(containerServices);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createTextMessage(java.lang.String)
	 */
	public TextMessage createTextMessage(String arg0) throws JMSException {
		TextMessage result = new ACSJMSTextMessage(containerServices);
		result.setText(arg0);
	    return result;	
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#getTransacted()
	 */
	public boolean getTransacted() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#getAcknowledgeMode()
	 */
	public int getAcknowledgeMode() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#commit()
	 */
	public void commit() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#rollback()
	 */
	public void rollback() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#close()
	 */
	public void close() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#recover()
	 */
	public void recover() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#getMessageListener()
	 */
	public MessageListener getMessageListener() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#setMessageListener(jakarta.jms.MessageListener)
	 */
	public void setMessageListener(MessageListener arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createProducer(jakarta.jms.Destination)
	 */
	public MessageProducer createProducer(Destination destination)
		throws JMSException {
		if(destination instanceof Topic) {
			return new ACSJMSTopicPublisher((Topic)destination, this.containerServices);
		} else throw new IllegalArgumentException("Only Topic destinations are supported by ACSJMSSession.");
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createConsumer(jakarta.jms.Destination)
	 */
	public MessageConsumer createConsumer(Destination destination) throws JMSException {
		if(destination instanceof Topic) {
			return new ACSJMSTopicSubscriber((Topic)destination, this.containerServices,null);
		} else throw new IllegalArgumentException("Only Topic destinations are supported by ACSJMSSession.");
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createConsumer(jakarta.jms.Destination, java.lang.String)
	 */
	public MessageConsumer createConsumer(Destination arg0, String arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createConsumer(jakarta.jms.Destination, java.lang.String, boolean)
	 */
	public MessageConsumer createConsumer(Destination arg0, String arg1, boolean arg2) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createDurableConsumer(jakarta.jms.Topic, java.lang.String)
	 */
	public MessageConsumer createDurableConsumer(Topic arg0, String arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createDurableConsumer(jakarta.jms.Destination, java.lang.String, java.lang.String, boolean)
	 */
	public MessageConsumer createDurableConsumer(Topic arg0, String arg1, String arg2, boolean arg3) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createQueue(java.lang.String)
	 */
	public Queue createQueue(String arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createSharedConsumer(jakarta.jms.Topic, java.lang.String)
	 */
	public MessageConsumer createSharedConsumer(Topic arg0, String arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createSharedConsumer(jakarta.jms.Destination, java.lang.String, java.lang.String)
	 */
	public MessageConsumer createSharedConsumer(Topic arg0, String arg1, String arg2) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createSharedDurableConsumer(jakarta.jms.Topic, java.lang.String)
	 */
	public MessageConsumer createSharedDurableConsumer(Topic arg0, String arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createSharedDurableConsumer(jakarta.jms.Destination, java.lang.String, java.lang.String)
	 */
	public MessageConsumer createSharedDurableConsumer(Topic arg0, String arg1, String arg2) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createTopic(java.lang.String)
	 */
	public Topic createTopic(String topic) throws JMSException {
		return new ACSJMSTopic(topic);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createDurableSubscriber(jakarta.jms.Topic, java.lang.String)
	 */
	public TopicSubscriber createDurableSubscriber(Topic arg0, String arg1)
		throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createDurableSubscriber(jakarta.jms.Topic, java.lang.String, java.lang.String, boolean)
	 */
	public TopicSubscriber createDurableSubscriber(
		Topic arg0,
		String arg1,
		String arg2,
		boolean arg3)
		throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createBrowser(jakarta.jms.Queue)
	 */
	public QueueBrowser createBrowser(Queue arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createBrowser(jakarta.jms.Queue, java.lang.String)
	 */
	public QueueBrowser createBrowser(Queue arg0, String arg1)
		throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createTemporaryQueue()
	 */
	public TemporaryQueue createTemporaryQueue() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#createTemporaryTopic()
	 */
	public TemporaryTopic createTemporaryTopic() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#unsubscribe(java.lang.String)
	 */
	public void unsubscribe(String arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}
}
