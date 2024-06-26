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

import jakarta.jms.Connection;
import jakarta.jms.ConnectionConsumer;
import jakarta.jms.ConnectionMetaData;
import jakarta.jms.Destination;
import jakarta.jms.ExceptionListener;
import jakarta.jms.JMSException;
import jakarta.jms.ServerSessionPool;
import jakarta.jms.Session;
import jakarta.jms.Topic;

import alma.acs.container.ContainerServicesBase;

/**
 * @author kzagar
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class ACSJMSConnection implements Connection {

	private String clientID;

	private ExceptionListener listener;

	protected ContainerServicesBase containerServices;
	
	public ACSJMSConnection(ContainerServicesBase containerServices) {
		if (containerServices==null) {
			throw new IllegalArgumentException("Invalid null ContainerServices");
		}
		this.containerServices = containerServices;
	}

	/* 
	 * Create a session using the connection. Both parameters are ignored.
	 *
	 * (non-Javadoc)
	 * @see jakarta.jms.Connection#createSession(boolean, int)
	 */
	public Session createSession(boolean transacted, int acknowledgeMode) throws JMSException {
		return createSession();
	}

	/* 
	 * (non-Javadoc)
	 * @see jakarta.jms.Connection#createSession(int sessionsMode)
	 */
	public Session createSession(int sessionMode) throws JMSException {
		boolean transacted = sessionMode == Session.SESSION_TRANSACTED;
		int acknowledgeMode = 0;
		if (!transacted) acknowledgeMode = sessionMode;
		return createSession(transacted, acknowledgeMode);
	}

	/* 
	 * (non-Javadoc)
	 * @see jakarta.jms.Connection#createSession()
	 */
	public Session createSession() throws JMSException {
		return new ACSJMSSession(this.containerServices);
	}

    /**
     * 
     * @uml.property name="clientID"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.Connection#getClientID()
     */
    public String getClientID() throws JMSException {
        return this.clientID;
    }

    /**
     * 
     * @uml.property name="clientID"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.Connection#setClientID(java.lang.String)
     */
    public void setClientID(String clientID) throws JMSException {
        this.clientID = clientID;
    }

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#getMetaData()
	 */
	public ConnectionMetaData getMetaData() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#getExceptionListener()
	 */
	public ExceptionListener getExceptionListener() throws JMSException {
		return this.listener;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#setExceptionListener(jakarta.jms.ExceptionListener)
	 */
	public void setExceptionListener(ExceptionListener listener)
		throws JMSException {
		this.listener = listener;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#start()
	 */
	public void start() throws JMSException {
		// Start receiving events. In ACS, nothing needs to be done.
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#stop()
	 */
	public void stop() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#close()
	 */
	public void close() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#createConnectionConsumer(jakarta.jms.Destination, java.lang.String, jakarta.jms.ServerSessionPool, int)
	 */
	public ConnectionConsumer createConnectionConsumer(Destination arg0, String arg1, ServerSessionPool arg2, int arg3) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#createDurableConnectionConsumer(jakarta.jms.Topic, java.lang.String, java.lang.String, jakarta.jms.ServerSessionPool, int)
	 */
	public ConnectionConsumer createDurableConnectionConsumer(Topic arg0, String arg1, String arg2, ServerSessionPool arg3, int arg4) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#createSharedConnectionConsumer(jakarta.jms.Topic, java.lang.String, java.lang.String, jakarta.jms.ServerSessionPool, int)
	 */
	public ConnectionConsumer createSharedConnectionConsumer(Topic arg0, String arg1, String args2, ServerSessionPool arg3, int arg4) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.Connection#createSharedDurableConnectionConsumer(jakarta.jms.Topic, java.lang.String, java.lang.String, jakarta.jms.ServerSessionPool, int)
	 */
	public ConnectionConsumer createSharedDurableConnectionConsumer(Topic arg0, String arg1, String arg2, ServerSessionPool arg3, int arg4) throws JMSException {
		throw new UnsupportedOperationException();
	}
}
