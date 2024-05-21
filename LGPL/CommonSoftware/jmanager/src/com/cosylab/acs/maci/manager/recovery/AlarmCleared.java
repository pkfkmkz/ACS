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
public class AlarmCleared implements TransactionWithQuery<ManagerImpl, Serializable> {

	private final String faultMember;
	
	/**
	 * Constructor for AlarmRaised.
	 */
	public AlarmCleared(String faultMember) {
		super();
		this.faultMember = faultMember;
	}

	/**
	 * @see Command#executeAndQuery(PrevalentSystem)
	 */
	public Serializable executeAndQuery(ManagerImpl system, Date ignored) {
		return Boolean.valueOf(system.getActiveAlarms().remove(faultMember));
	}

}
