package com.cosylab.acs.maci.manager.recovery;

import java.util.Date;
import java.io.Serializable;

import com.cosylab.acs.maci.ClientInfo;
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
public class ClientInfoCommandComponentRemove implements TransactionWithQuery<ManagerImpl, Serializable> {
	
	private final int id;
	private final int handle;
	
	/**
	 * Constructor for AddCOBCommand.
	 */
	public ClientInfoCommandComponentRemove(int id, int handle) {
		super();
		this.id = id;
		this.handle = handle;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		ClientInfo clientInfo = system.noSyncGetClientInfo(id);
		clientInfo.getComponents().remove(handle);
		return null;
	}
}
