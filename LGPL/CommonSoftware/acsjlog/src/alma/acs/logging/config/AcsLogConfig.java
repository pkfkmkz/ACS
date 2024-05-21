package alma.acs.logging.config;

import java.io.InputStream;

import java.util.logging.LogManager;

public class AcsLogConfig {
    public AcsLogConfig() {
        try {
            // Load a properties file from class path that way can't be achieved with java.util.logging.config.file
            final LogManager logManager = LogManager.getLogManager();
            final InputStream is = getClass().getResourceAsStream("/almalogging.properties");
            logManager.readConfiguration(is);
        } catch (Exception e) {
            // The runtime won't show stack traces if the exception is thrown
            e.printStackTrace();
        }
    }
}
