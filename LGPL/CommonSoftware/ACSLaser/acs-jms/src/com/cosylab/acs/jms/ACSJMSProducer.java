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

import jakarta.jms.Destination;
import jakarta.jms.JMSException;
import jakarta.jms.Message;
import jakarta.jms.MessageProducer;
import jakarta.jms.CompletionListener;

import alma.acs.container.ContainerServicesBase;

/**
 * @author kzagar
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public abstract class ACSJMSProducer implements MessageProducer {
	protected ContainerServicesBase containerServices;

	private long timeToLive;

	private int deliveryMode;

	protected Destination destination;

	/**
	 * @param arg0
	 */
	public ACSJMSProducer(Destination destination, ContainerServicesBase containerServices) throws JMSException {
		this.destination = destination;
		this.containerServices = containerServices;
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#setDisableMessageID(boolean)
	 */
	public void setDisableMessageID(boolean arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#getDisableMessageID()
	 */
	public boolean getDisableMessageID() throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#setDisableMessageTimestamp(boolean)
	 */
	public void setDisableMessageTimestamp(boolean arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#getDisableMessageTimestamp()
	 */
	public boolean getDisableMessageTimestamp() throws JMSException {
		throw new UnsupportedOperationException();
	}

    /**
     * 
     * @uml.property name="deliveryMode"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#setDeliveryMode(int)
     */
    public void setDeliveryMode(int deliveryMode) throws JMSException {
        this.deliveryMode = deliveryMode;
    }

    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#setDeliveryDelay()
     */
    public void setDeliveryDelay(long deliveryDelay) throws JMSException {
        throw new UnsupportedOperationException();
    }

    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#getDeliveryDelay()
     */
    public long getDeliveryDelay() throws JMSException {
        throw new UnsupportedOperationException();
    }

    /**
     * 
     * @uml.property name="deliveryMode"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#getDeliveryMode()
     */
    public int getDeliveryMode() throws JMSException {
        return this.deliveryMode;
    }


	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#setPriority(int)
	 */
	public void setPriority(int arg0) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#getPriority()
	 */
	public int getPriority() throws JMSException {
		throw new UnsupportedOperationException();
	}

    /**
     * 
     * @uml.property name="timeToLive"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#setTimeToLive(long)
     */
    public void setTimeToLive(long timeToLive) throws JMSException {
        this.timeToLive = timeToLive;
    }

    /**
     * 
     * @uml.property name="timeToLive"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#getTimeToLive()
     */
    public long getTimeToLive() throws JMSException {
        return this.timeToLive;
    }

    /**
     * 
     * @uml.property name="destination"
     */
    /* (non-Javadoc)
     * @see jakarta.jms.MessageProducer#getDestination()
     */
    public Destination getDestination() throws JMSException {
        return this.destination;
    }

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Message, jakarta.jms.CompletionListener)
	 */
	public void send(Message arg0, CompletionListener arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Message, int, int, long)
	 */
	public void send(Message arg0, int arg1, int arg2, long arg3) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Message, int, int, long, jakarta.jms.CompletionListener)
	 */
	public void send(Message arg0, int arg1, int arg2, long arg3, CompletionListener arg4) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Destination, jakarta.jms.Message)
	 */
	public void send(Destination arg0, Message arg1) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Destination, jakarta.jms.Message, jakarta.jms.CompletionListener)
	 */
	public void send(Destination arg0, Message arg1, CompletionListener arg2) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Destination, jakarta.jms.Message, int, int, long)
	 */
	public void send(Destination arg0, Message arg1, int arg2, int arg3, long arg4) throws JMSException {
		throw new UnsupportedOperationException();
	}

	/* (non-Javadoc)
	 * @see jakarta.jms.MessageProducer#send(jakarta.jms.Destination, jakarta.jms.Message, int, int, long, jakarta.jms.CompletionListener)
	 */
	public void send(Destination arg0, Message arg1, int arg2, int arg3, long arg4, CompletionListener arg5) throws JMSException {
		throw new UnsupportedOperationException();
	}
}
