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

import jakarta.jms.JMSContext;
import jakarta.jms.Connection;
import jakarta.jms.JMSException;
import jakarta.jms.ConnectionFactory;

import alma.acs.container.ContainerServicesBase;

/**
 * @author kzagar
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class ACSJMSConnectionFactory implements ConnectionFactory {
	protected ContainerServicesBase containerServices;

	public ACSJMSConnectionFactory(ContainerServicesBase containerServices)
	{
		this.containerServices = containerServices;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createConnection()
	 */
	public Connection createConnection() throws JMSException {
		return new ACSJMSConnection(this.containerServices);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createConnection(java.lang.String, java.lang.String)
	 */
	public Connection createConnection(String arg0, String arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createContext()
	 */
	public JMSContext createContext() {
		return createContext(0);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createContext(int)
	 */
	public JMSContext createContext(int sessionMode) {
		return createContext(null, null, sessionMode);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createContext(java.lang.String, java.lang.String)
	 */
	public JMSContext createContext(String user, String pass) {
		return createContext(user, pass, 0);
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.ConnectionFactory#createContext(java.lang.String, java.lang.String, int)
	 */
	public JMSContext createContext(String user, String pass, int sessionMode) {
		throw new UnsupportedOperationException();
	}
}
