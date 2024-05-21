package alma.acs.logging.adapters;

import java.net.URI;
import java.util.Map;
import java.util.HashMap;

import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.message.MessageFactory;

import alma.acs.logging.AcsLogger;
import alma.acs.logging.ClientLogManager;

public class Log4jLoggerContext extends LoggerContext {
	/**
	 * Laser alarm system logger name base.
	 */
	public static final String LASER_LOGGER_NAME_PREFIX = "laser";

	/**
	 * key = framework name (e.g. "laser"), value = Logger
	 */
	private final Map<String, Logger> loggerMap = new HashMap<String, Logger>();

	public Log4jLoggerContext(final String name, final Object externalContext, final URI configLocn) {
		super(name, externalContext, configLocn);
	}

	protected synchronized Logger newInstance(LoggerContext ctx, final String name, final MessageFactory messageFactory) {
		// Check which framework is requesting the log4j logger
		String loggerNameBase = "unknown";
		StackTraceElement[] stackTrace = (new Exception()).getStackTrace();
		for (StackTraceElement stackTraceElement : stackTrace) {
			if (stackTraceElement.getClassName().contains("cern.laser.")) {
				loggerNameBase = LASER_LOGGER_NAME_PREFIX;
				break;
			}
			// TODO: add check for other frameworks that use log4j, once we have those
		}
		
		// Check if we already have a logger for the client framework, and create it if needed.
		Logger myLogger = loggerMap.get(loggerNameBase);
		if (myLogger == null) {
			AcsLogger delegate = ClientLogManager.getAcsLogManager().getLoggerForCorba(loggerNameBase, true);
			myLogger = new Log4jLogger(ctx, loggerNameBase, messageFactory, delegate);
			loggerMap.put(loggerNameBase, myLogger);
		}
		
		return myLogger;
	}
}
