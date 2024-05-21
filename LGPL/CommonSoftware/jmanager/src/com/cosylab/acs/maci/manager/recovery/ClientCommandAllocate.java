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
public class ClientCommandAllocate implements TransactionWithQuery<ManagerImpl, Serializable> {

	/**
	 * Constructor for COBCommandAckAlloc.
	 */
	public ClientCommandAllocate() {
		super();
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		return Integer.valueOf(system.getClients().allocate());
	}

}
