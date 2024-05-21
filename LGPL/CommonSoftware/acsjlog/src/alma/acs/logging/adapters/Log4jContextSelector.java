package alma.acs.logging.adapters;

import java.net.URI;

//import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.core.selector.ClassLoaderContextSelector;

public class Log4jContextSelector extends ClassLoaderContextSelector {
	static boolean ACSLoggerEnabled = false;

	/**
	 * This method must be called once in order to enable ACS logging behind the scenes of log4j logging.
	 * <p>
	 * The log4j framework is quite resistant against being substituted with a different logging framework.
	 * Even though it is possible to configure a custom logger factory using <code>log4j.loggerFactory</code>,
	 * that factory will not be used when 3rd party code calls the usual <code>Logger.getLogger(name)</code>.
	 * It seems to make sense only for cases where the custom logger is used as in <code>MyLogger.getLogger(name)</code>.
	 * log4j-over-slf4j (http://www.slf4j.org/legacy.html) simply re-implements the relevant log4j classes, 
	 * which is too much trouble here for us because only basic log4j features are being used. 
	 * <p>
	 * We make use of the RepositorySelector mechanism, which log4j foresees for a different purpose, 
	 * to separate logging contexts in an application server that does not have classloader separation.
	 * (See also http://articles.qos.ch/sc.html.) 
	 * It is not possible to configure this externally, so that an application must call this method.
	 * See also http://mail-archives.apache.org/mod_mbox/logging-log4j-user/200904.mbox/%3Ca44e15a30904020424g4b7d7fcx63ca32152c81f80d@mail.gmail.com%3E
	 * <p>
	 * @TODO: In the future we could let ClientLogManager call this method, 
	 * but currently we are afraid of side effects with frameworks other than the laser alarm system
	 * that also use log4j (see http://jira.alma.cl/browse/COMP-8423).
	 */
	public static void enableAcsLogging() {
		Log4jContextSelector.ACSLoggerEnabled = true;
		CONTEXT_MAP.clear(); //Allows to use our custom context even if there were log4j calls previousto this point
		Log4jLogger rootLogger = (Log4jLogger)LogManager.getRootLogger();
		for (var entry : rootLogger.getAppenders().entrySet()) {
			rootLogger.removeAppender(entry.getValue());
		}
		//rootLogger.removeAllAppenders();
		//rootLogger.addAppender(new NullAppender()); // to avoid "log4j:WARN No appenders could be found for logger (root)."
		rootLogger.setLevel(Level.ALL);
	}

	public Log4jContextSelector() {
		super();
	}

	protected LoggerContext createContext(final String name, final URI configLocation) {
		if (Log4jContextSelector.ACSLoggerEnabled)
			return new Log4jLoggerContext(name, null, configLocation);
		return super.createContext(name, configLocation);
	}
}
