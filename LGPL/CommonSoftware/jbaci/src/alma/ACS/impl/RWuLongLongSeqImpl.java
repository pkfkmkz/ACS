package alma.ACS.impl;

import alma.ACS.CBDescIn;
import alma.ACS.CBDescOut;
import alma.ACS.CBuLongLongSeq;
import alma.ACS.CBvoid;
import alma.ACS.Callback;
import alma.ACS.MonitoruLongLong;
import alma.ACS.MonitoruLongLongHelper;
import alma.ACS.MonitoruLongLongPOATie;
import alma.ACS.NoSuchCharacteristic;
import alma.ACS.RWuLongLongSeqOperations;
import alma.ACS.TimeSeqHolder;
import alma.ACS.uLongLongSeqSeqHolder;
import alma.ACS.jbaci.CallbackDispatcher;
import alma.ACS.jbaci.CompletionUtil;
import alma.ACS.jbaci.DataAccess;
import alma.ACS.jbaci.PropertyInitializationFailed;
import alma.ACSErr.Completion;
import alma.ACSErr.CompletionHolder;
import alma.ACSErrTypeCommon.wrappers.AcsJCouldntPerformActionEx;
import alma.acs.exceptions.AcsJException;

public class RWuLongLongSeqImpl extends RWCommonComparablePropertyImpl implements RWuLongLongSeqOperations {

	
	
	public RWuLongLongSeqImpl(String name, CharacteristicComponentImpl parentComponent,
			DataAccess<long[]> dataAccess) throws PropertyInitializationFailed {
		super(long[].class, name, parentComponent, dataAccess);
	}

	public RWuLongLongSeqImpl(String name, CharacteristicComponentImpl parentComponent)
			throws PropertyInitializationFailed {
		super(long[].class, name, parentComponent);
	}

	/**
	 * @see alma.ACS.CommonPropertyImpl#readPropertyTypeCharacteristic(java.lang.String)
	 */
	@Override
	public Object readPropertyTypeCharacteristic(String name)
		throws NoSuchCharacteristic {
		return characteristicModelImpl.getuLongLongSeq(name);
	}

	/**
	 * @see alma.ACS.PuLongOperations#create_monitor(alma.ACS.CBlong, alma.ACS.CBDescIn)
	 */
	@Override
	public MonitoruLongLong create_monitor(CBuLongLongSeq callback, CBDescIn descIn) {
		return create_postponed_monitor(0, callback, descIn);
	}

	/**
	 * @see alma.ACS.PuLongOperations#create_postponed_monitor(long, alma.ACS.CBlong, alma.ACS.CBDescIn)
	 */
	@Override
	public MonitoruLongLong create_postponed_monitor(
		long startTime,
		CBuLongLongSeq callback,
		CBDescIn descIn) {
			
		// create monitor and its servant
		MonitoruLongLongImpl monitorImpl = new MonitoruLongLongImpl(this, callback, descIn, startTime);
		MonitoruLongLongPOATie monitorTie = new MonitoruLongLongPOATie(monitorImpl);

		// register and activate		
		return MonitoruLongLongHelper.narrow(this.registerMonitor(monitorImpl, monitorTie));
	
	}

	/**
	 * @see alma.ACS.PuLongOperations#default_value()
	 */
	@Override
	public long default_value() {
		return ((long[])defaultValue)[0];
	}

	/**
	 * @see alma.ACS.PuLongOperations#get_async(alma.ACS.CBlong, alma.ACS.CBDescIn)
	 */
	@Override
	public void get_async(CBuLongLongSeq cb, CBDescIn desc) {
		// TODO Auto-generated method stub
		getAsync(cb,desc);
		
	}
	
	
	/**
	 * @see alma.ACS.PuLongOperations#get_history(int, alma.ACS.longSeqHolder, alma.ACS.TimeSeqHolder)
	 */
	@Override
	public int get_history(
		int arg0,
		uLongLongSeqSeqHolder arg1,
		TimeSeqHolder arg2) {
		arg1.value = (long[][])getHistory(arg0, arg2);
		return arg1.value.length;
	}

	/**
	 * @see alma.ACS.PuLongOperations#get_sync(alma.ACSErr.CompletionHolder)
	 */
	@Override
	public long[] get_sync(CompletionHolder completionHolder) {
		try
		{
			return ((long[])getSync(completionHolder));
		}
		catch (AcsJException acsex)
		{
			AcsJCouldntPerformActionEx cpa =
				new AcsJCouldntPerformActionEx(acsex);
			cpa.setProperty("message", "Failed to retrieve value");
			completionHolder.value = CompletionUtil.generateCompletion(cpa);
			// return default value in case of error
			// return default_value(); <- not valid, because ir a long not an long[]
			return new long[1];
		}
	}

	/**
	 * @see alma.ACS.PuLongOperations#graph_max()
	 */
	@Override
	public long graph_max() {
		return ((long[])graphMax)[0];
	}

	/**
	 * @see alma.ACS.PuLongOperations#graph_min()
	 */
	@Override
	public long graph_min() {
		return ((long[])graphMin)[0];
	}

	/**
	 * @see alma.ACS.PuLongOperations#min_delta_trigger()
	 */
	@Override
	public long min_delta_trigger() {
		return ((long[])minDeltaTrigger)[0];
	}

	/**
	 * @see alma.ACS.PuLongOperations#min_step()
	 */
	@Override
	public long min_step() {
		return ((long[])minStep)[0];
	}


	/**
	 * @see alma.ACS.CommonComparablePropertyImpl#lessThanDelta(java.lang.Object, java.lang.Object, java.lang.Object)
	 */
	@Override
	public boolean lessThanDelta(Object value1, Object value2, Object delta) {
		return Math.abs(((Long)value1).longValue()-((Long)value2).longValue()) < ((Long)delta).longValue();
	}

	/**
	 * @see alma.ACS.CommonComparablePropertyImpl#noDelta(java.lang.Object)
	 */
	@Override
	public boolean noDelta(Object value) {
		return ((Long)value).longValue() == 0;
	}

	/**
	 * @see alma.ACS.jbaci.CallbackDispatcher#dispatchCallback(int, java.lang.Object, alma.ACSErr.Completion, alma.ACS.CBDescOut)
	 */
	@Override
	public boolean dispatchCallback(
		CallbackDispatcher.CallbackType type,
		Object value,
		Callback callback,
		Completion completion,
		CBDescOut desc) {
		try
		{	
			if (type == CallbackDispatcher.CallbackType.DONE_TYPE)
				((CBuLongLongSeq)callback).done(((long[])value), completion, desc);
			else if (type == CallbackDispatcher.CallbackType.WORKING_TYPE)
				((CBuLongLongSeq)callback).working(((long[])value), completion, desc);
			else 
				return false;
				
			return true;
		}
		catch (Throwable th)
		{
			return false;
		}
	}

	/**
	 * @see alma.ACS.CommonComparablePropertyImpl#sum(java.lang.Object, java.lang.Object, boolean)
	 */
	@Override
	public Object sum(Object value1, Object value2, boolean substract) {
		long val2 = ((Long)value2).longValue();
		if (substract)
			val2 = -val2;
		return Long.valueOf(((Long)value1).longValue() + val2);
	}



	/**
	 * @see alma.ACS.RWlongOperations#max_value()
	 */
	@Override
	public long max_value() {
		return ((long[])maxValue)[0];
	}

	/**
	 * @see alma.ACS.RWlongOperations#min_value()
	 */
	@Override
	public long min_value() {
		return ((long[])minValue)[0];
	}

	/**
	 * @see alma.ACS.RWlongOperations#set_async(long, alma.ACS.CBvoid, alma.ACS.CBDescIn)
	 */
	@Override
	public void set_async(long[] value, CBvoid callback, CBDescIn descIn) {
		setAsync(value, callback, descIn);
	}

	/**
	 * @see alma.ACS.RWlongOperations#set_nonblocking(long)
	 */
	@Override
	public void set_nonblocking(long[] value) {
		setNonblocking(value);
	}

	/**
	 * @see alma.ACS.RWlongOperations#set_sync(long)
	 */
	@Override
	public Completion set_sync(long[] value) {
		try
		{
			return setSync(value);
		}
		catch (AcsJException acsex)
		{
			AcsJCouldntPerformActionEx cpa =
				new AcsJCouldntPerformActionEx(acsex);
			cpa.setProperty("message", "Failed to set value");
			return CompletionUtil.generateCompletion(cpa);
		}
	}

}
