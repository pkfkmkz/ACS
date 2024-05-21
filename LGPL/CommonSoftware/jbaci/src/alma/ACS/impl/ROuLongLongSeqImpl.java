package alma.ACS.impl;

import org.omg.CORBA.NO_IMPLEMENT;

import alma.ACS.AlarmuLongLong;
import alma.ACS.CBDescIn;
import alma.ACS.CBDescOut;
import alma.ACS.CBuLongLongSeq;
import alma.ACS.Callback;
import alma.ACS.MonitoruLongLong;
import alma.ACS.MonitoruLongLongHelper;
import alma.ACS.MonitoruLongLongPOATie;
import alma.ACS.NoSuchCharacteristic;
import alma.ACS.ROuLongLongSeqOperations;
import alma.ACS.Subscription;
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
import alma.baciErrTypeProperty.DisableAlarmsErrorEx;

public class ROuLongLongSeqImpl extends ROCommonComparablePropertyImpl implements ROuLongLongSeqOperations {

	
	
	public ROuLongLongSeqImpl(String name, CharacteristicComponentImpl parentComponent,
			DataAccess dataAccess) throws PropertyInitializationFailed {
		super(long[].class, name, parentComponent, dataAccess);
	}

	public ROuLongLongSeqImpl(String name, CharacteristicComponentImpl parentComponent)
			throws PropertyInitializationFailed {
		super(long[].class, name, parentComponent);
	}

	@Override
	public long min_delta_trigger() {
		return ((long[])minDeltaTrigger)[0];
	}

	@Override
	public long default_value() {
		return ((long[])defaultValue)[0];
	}

	@Override
	public long graph_min() {
		return ((long[])graphMin)[0];
	}

	@Override
	public long graph_max() {
		return ((long[])graphMax)[0];
	}

	@Override
	public long min_step() {
		return ((long[])minStep)[0];
	}

	@Override
	public long[] get_sync(CompletionHolder completionHolder) {
		try
		{
			return (long[])getSync(completionHolder);
		}
		catch (AcsJException acsex)
		{
			AcsJCouldntPerformActionEx cpa =
				new AcsJCouldntPerformActionEx(acsex);
			cpa.setProperty("message", "Failed to retrieve value");
			completionHolder.value = CompletionUtil.generateCompletion(cpa);
			// return default value in case of error
			//return default_value();
			return new long[1];
		}
	}

	@Override
	public void get_async(CBuLongLongSeq cb, CBDescIn desc) {
		getAsync(cb, desc);
	}

	@Override
	public int get_history(int n_last_values, uLongLongSeqSeqHolder vs, TimeSeqHolder ts) {
		vs.value = (long[][])getHistory(n_last_values, ts);
		return vs.value.length;
	}

	@Override
	public MonitoruLongLong create_monitor(CBuLongLongSeq cb, CBDescIn desc) {
		return create_postponed_monitor(0, cb, desc);
	}

	@Override
	public MonitoruLongLong create_postponed_monitor(long start_time, CBuLongLongSeq cb, CBDescIn desc) {
		// create monitor and its servant
		MonitoruLongLongImpl monitorImpl = new MonitoruLongLongImpl(this, cb, desc, start_time);
		MonitoruLongLongPOATie monitorTie = new MonitoruLongLongPOATie(monitorImpl);

		// register and activate
		return MonitoruLongLongHelper.narrow(this.registerMonitor(monitorImpl, monitorTie));
	}

	@Override
	public boolean dispatchCallback(CallbackDispatcher.CallbackType type, Object value, Callback callback, Completion completion, CBDescOut desc) {
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

	@Override
	public long alarm_low_on() {
		return ((long[])alarmLowOn)[0];
	}

	@Override
	public long alarm_low_off() {
		return ((long[])alarmLowOff)[0];
	}

	@Override
	public long alarm_high_on() {
		return ((long[])alarmHighOn)[0];
	}

	@Override
	public long alarm_high_off() {
		return ((long[])alarmHighOff)[0];
	}

	@Override
	public Subscription new_subscription_Alarm(AlarmuLongLong cb, CBDescIn desc) {
		// TODO NO_IMPLEMENT
		throw new NO_IMPLEMENT();
	}

	@Override
	public void enable_alarm_system() {
		// TODO NO_IMPLEMENT
		throw new NO_IMPLEMENT();
	}

	@Override
	public void disable_alarm_system() throws DisableAlarmsErrorEx {
		// TODO NO_IMPLEMENT
		throw new NO_IMPLEMENT();
	}

	@Override
	public boolean alarm_system_enabled() {
		// TODO NO_IMPLEMENT
		throw new NO_IMPLEMENT();
	}

	@Override
	public boolean lessThanDelta(Object value1, Object value2, Object delta) {
		return Math.abs(((Long)value1).longValue()-((Long)value2).longValue()) < ((Long)delta).longValue();
	}

	@Override
	public boolean noDelta(Object value) {
		return ((Long)value).longValue() == 0;
	}

	@Override
	public Object sum(Object value1, Object value2, boolean substract) {
		long val2 = ((Long)value2).longValue();
		if (substract)
			val2 = -val2;
		return Long.valueOf(((Long)value1).longValue() + val2);
	}

	@Override
	public Object readPropertyTypeCharacteristic(String name) throws NoSuchCharacteristic {
		return (characteristicModelImpl.getuLongLongSeq(name));
	}

}
