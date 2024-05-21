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
public class DefaultComponentCommandPut implements TransactionWithQuery<ManagerImpl, Serializable> {

	private final String type;
	private final ComponentInfo componentInfo;

	/**
	 */
	public DefaultComponentCommandPut(String type, ComponentInfo componentInfo) {
		super();
		this.type = type;
		this.componentInfo = componentInfo;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		system.getDefaultComponents().put(type, componentInfo);
		return null;
	}

}
