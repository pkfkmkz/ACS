package alma.acs.logging.adapters;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.Marker;
import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.message.Message;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.message.MessageFactory;

import alma.acs.logging.AcsLogger;

/**
 * We intercept the log4j logs at the first level, the Logger itself.
 * It may have been good enough to inject the ACS logger as a log4j appender, 
 * but it seems that only the Logger allows us to implement <code>isDebugEnabled</code>
 * type of methods based on the ACS-configured log levels, 
 * rather than first creating and later dropping a LoggingEvent object.
 */
public class Log4jLogger extends Logger {
	private final AcsLogger delegate;

	/**
	 * 
	 */
	protected Log4jLogger(LoggerContext ctx, String name, MessageFactory messageFactory, AcsLogger delegate) {
		super(ctx, name, messageFactory);
		this.delegate = delegate;
		delegate.addLoggerClass(Log4jLogger.class);
	}

	@Override
	public boolean isTraceEnabled() {
		return delegate.isLoggable(log4jLevelToJdkLevel(Level.TRACE));
	}

	@Override
	public boolean isDebugEnabled() {
		return delegate.isLoggable(log4jLevelToJdkLevel(Level.DEBUG));
	}

	@Override
	public boolean isInfoEnabled() {
		return delegate.isLoggable(log4jLevelToJdkLevel(Level.INFO));
	}

	@Override
	public void logIfEnabled(final String fqcn, final Level level, final Marker marker, final String msg, final Throwable t) {
		if (delegate.isLoggable(log4jLevelToJdkLevel(level))) {
			logMessage(fqcn, level, marker, msg, t);
		}
	}

	@Override
	public void logMessage(final String fqcn, final Level level, final Marker marker, final Message message, final Throwable t) {
		delegate.log(log4jLevelToJdkLevel(level), message.getFormattedMessage(), t);
		super.logMessage(fqcn, level, marker, message, t);
	}

	@Override
	protected void log(final Level level, final Marker marker, final String fqcn, final StackTraceElement location, final Message message, final Throwable t) {
		delegate.log(log4jLevelToJdkLevel(level), message.getFormattedMessage(), t);
		super.log(level, marker, fqcn, location, message, t);
	}

	java.util.logging.Level log4jLevelToJdkLevel(Level level) {
		switch (level.getStandardLevel()) {
		case TRACE:
			return java.util.logging.Level.FINEST;

		case DEBUG:
			return java.util.logging.Level.FINER; // or FINE ?

		case INFO:
			return java.util.logging.Level.INFO;

		case FATAL:
			return java.util.logging.Level.SEVERE;
			
		case WARN:
		case ERROR:
		default:
			return java.util.logging.Level.WARNING;
		}
	}
}
