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
 * Created on Jun 27, 2004
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package com.cosylab.acs.jms;

import jakarta.jms.JMSException;
import jakarta.jms.Topic;
import jakarta.jms.TopicPublisher;
import jakarta.jms.TopicSession;
import jakarta.jms.TopicSubscriber;

import alma.acs.container.ContainerServicesBase;

/**
 * @author kzagar
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class ACSJMSTopicSession extends ACSJMSSession implements TopicSession {

	/**
	 * @param containerServices
	 */
	public ACSJMSTopicSession(ContainerServicesBase containerServices) {
		super(containerServices);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.TopicSession#createSubscriber(jakarta.jms.Topic)
	 */
	public TopicSubscriber createSubscriber(Topic topic) throws JMSException {
		return new ACSJMSTopicSubscriber(topic, this.containerServices,null);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.TopicSession#createSubscriber(jakarta.jms.Topic, java.lang.String, boolean)
	 */
	public TopicSubscriber createSubscriber(
		Topic topic,
		String messageSelector,
		boolean noLocal)
		throws JMSException {
		// TODO messageSelector and noLocal arguments should be used somehow
		return new ACSJMSTopicSubscriber(topic, this.containerServices,messageSelector);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.TopicSession#createPublisher(jakarta.jms.Topic)
	 */
	public TopicPublisher createPublisher(Topic topic) throws JMSException {
		ACSJMSTopicPublisher newPublisher;
		try {
			newPublisher = new ACSJMSTopicPublisher(topic, this.containerServices);
		} catch (JMSException e) {
			System.err.println("######################################");
			System.err.println("Exception caught "+e.getMessage());
			e.printStackTrace(System.err);
			System.err.println("######################################");
			throw e;
		}
		return newPublisher;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Session#close()
	 */
	public void close() throws JMSException {
	}
}
