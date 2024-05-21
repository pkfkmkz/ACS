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
public class ComponentCommandAllocateHandle implements TransactionWithQuery<ManagerImpl, Serializable> {

	private final int handle;
	private final boolean preallocate;

	public ComponentCommandAllocateHandle(int handle) {
		super();
		this.handle = handle;
		this.preallocate = false;
	}

	public ComponentCommandAllocateHandle(int handle, boolean preallocate ) {
		super();
		this.handle = handle;
		this.preallocate = preallocate;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		int newHandle = system.getComponents().allocate(handle, preallocate);
		return Integer.valueOf(newHandle);
	}

}
