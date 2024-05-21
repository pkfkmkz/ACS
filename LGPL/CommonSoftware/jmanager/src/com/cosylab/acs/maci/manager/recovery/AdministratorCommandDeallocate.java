package com.cosylab.acs.maci.manager.recovery;

import java.util.Date;
import java.io.Serializable;

import com.cosylab.acs.maci.HandleConstants;
import com.cosylab.acs.maci.manager.ManagerImpl;
import com.cosylab.acs.maci.manager.ManagerImpl.WhyUnloadedReason;

import org.prevayler.TransactionWithQuery;

/**
 * @author dragan
 *
 * To change this generated comment edit the template variable "typecomment":
 * Window>Preferences>Java>Templates.
 * To enable and disable the creation of type comments go to
 * Window>Preferences>Java>Code Generation.
 */
public class AdministratorCommandDeallocate implements TransactionWithQuery<ManagerImpl, Serializable> {
	
	private final int handle;
	private final int fullHandle;
	private final WhyUnloadedReason reason;
	
	/**
	 * Constructor for AddCOBCommand.
	 */
	public AdministratorCommandDeallocate(int handle, int fullHandle, WhyUnloadedReason reason) {
		super();
		this.handle = handle;
		this.fullHandle = fullHandle;
		this.reason = reason;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		system.logHandleRelease(fullHandle, reason);
		system.getAdministrators().deallocate(handle);
		return null;
	}
}
