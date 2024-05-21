package com.cosylab.acs.maci.manager.recovery;

import java.util.Date;
import java.io.Serializable;

import com.cosylab.acs.maci.manager.ManagerImpl;

import org.prevayler.TransactionWithQuery;

/**
 * @author dragan
 *
 * To change this generated comment edit the template variable "typecomment":
 * Window>Preferences>Java>Templates.
 * To enable and disable the creation of type comments go to
 * Window>Preferences>Java>Code Generation.
 */
public class ComponentCommandSet implements TransactionWithQuery<ManagerImpl, Serializable> {
	
	private final int handle;
	private final Object data;
	
	/**
	 * Constructor for COBCommandSet.
	 */
	public ComponentCommandSet(int handle, Object data) {
		super();
		this.handle = handle;
		this.data = data;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		system.getComponents().set(handle, data);
		return null;
	}
}
