package com.cosylab.acs.maci.manager.recovery;

import java.util.Date;
import java.io.Serializable;

import com.cosylab.acs.maci.ComponentInfo;
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
public class ComponentCommandClientRemove implements TransactionWithQuery<ManagerImpl, Serializable> {
	
	private final int handle;
	private final int clientHandle;
	
	/**
	 * Constructor for AddCOBCommand.
	 */
	public ComponentCommandClientRemove(int handle, int clientHandle) {
		super();
		this.handle = handle;
		this.clientHandle = clientHandle;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		ComponentInfo cobInfo = (ComponentInfo)system.getComponents().get(handle);
		cobInfo.getClients().remove(clientHandle);
		return null;
	}
}
