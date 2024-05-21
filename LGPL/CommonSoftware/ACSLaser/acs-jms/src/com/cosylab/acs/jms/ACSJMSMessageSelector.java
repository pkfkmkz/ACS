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
package com.cosylab.acs.jms;

import java.util.Enumeration;

import jakarta.jms.Topic;
import jakarta.jms.Message;
import jakarta.jms.JMSException;
import jakarta.jms.InvalidSelectorException;

import org.apache.activemq.command.ActiveMQTopic;
import org.apache.activemq.command.ActiveMQMessage;
import org.apache.activemq.selector.SelectorParser;
import org.apache.activemq.filter.BooleanExpression;
import org.apache.activemq.filter.MessageEvaluationContext;
import org.apache.activemq.broker.region.MessageReference;

/**
 * This object is a message selector.
 * It owns an SQL92 string describing an SQL statement and checkes
 * if a message matches with that statement.
 * 
 * @see JMS specifications for further details
 * 
 * @author acaproni
 *
 */
public class ACSJMSMessageSelector {
	
	/**
	 * The message selector string
	 * It is an SQL92 string as described in JMS specification
	 * All the messages that do not match with this statement
	 * are discarded, the others are sent to the listeners
	 * If the selector is null or empty it matches to true with all messages.
	 */
	private String selectorString;
	
	/**
	 * The selector object
	 * @see org.apache.activemq.filter.BooleanExpression
	 */
	private BooleanExpression selector = null;

	/**
	 * The constructor
	 * 
	 * @param sqlSelectorString The SQL selector string (it can be
	 *                          null or empty)
	 * 
	 * @throws InvalidSelectorException 
	 * @see jakarta.jms.InvalidSelectorException
	 */
	public ACSJMSMessageSelector(String sqlSelectorString) throws InvalidSelectorException {
		setSelectorString(sqlSelectorString);
	}
	
	/**
	 * 
	 * @return The (eventually null or empty) SQL selector string 
	 * 
	 */
	public String getSelectorString() {
		return selectorString;
	}
	
	/**
	 * Set the new SQL selector string and create the instance of 
	 * selector. selector is set to null if the string is null or empty.
	 *
	 * 
	 * @param newSQLSelString The SQL92 selector string
	 * @throws InvalidSelectorException 
	 * 
	 * @see jakarta.jms.InvalidSelectorException
	 */
	public void setSelectorString(String newSQLSelString) throws InvalidSelectorException {
		this.selectorString=newSQLSelString;
		if (selectorString==null) {
			selector = null;
		} else if (selectorString.trim().length()==0) {
			selector = null;
		} else {
			selector = SelectorParser.parse(selectorString);
		}
	}
	
	/** 
	 * Check if the message matches with the SQL selector string.
	 * The test passes also if the string is empty or null.
	 * 
	 * @param message The message to check
	 * @return true if the message matches with the string
	 *         false otherwise
	 */
	public boolean match(ACSJMSMessage message) {
		if (selectorString==null) {
			return true;
		} else if (selectorString.length()==0) {
			return true;
		} else {
			MessageEvaluationContext context = new MessageEvaluationContext();
			boolean result = true;
			try {
				context.setMessageReference(createMessageReference(message));
				result = selector.matches(context);
			} catch (JMSException e) {
				System.err.println("Exception caught while filtering with ACSJMSMessageSelector:");
				System.err.println(e.getMessage());
			} catch (Throwable t) {
				t.printStackTrace();
			}
			context.clear();
			return result;
		}
	}

	public MessageReference createMessageReference(Message orig) throws JMSException {
		//Create base Message reference with current topic
		ActiveMQMessage message = new ActiveMQMessage();
		Topic topic = (Topic) orig.getJMSDestination();
		if (topic == null) {
			message.setJMSDestination(new ActiveMQTopic("DummyTopic"));
		} else {
			message.setJMSDestination(new ActiveMQTopic(topic.getTopicName()));
		}

		//Configure base values
		message.setJMSType(orig.getJMSType());

		//Copy all properties
		Enumeration<String> props = orig.getPropertyNames();
		while (props.hasMoreElements()) {
			String prop = props.nextElement();
			message.setObjectProperty(prop, orig.getObjectProperty(prop));
		}
		return message;
	}

}
