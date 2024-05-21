package alma.acs.cdb.rest;

import java.util.Collections;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@SpringBootApplication(exclude={SecurityAutoConfiguration.class})
public class APIServer {


    public static void main(String[] args) {
        
        SpringApplication app = new SpringApplication(APIServer.class);
        app.setDefaultProperties(Collections
                    .singletonMap("server.port", "3031"));
        
        app.run(args);

        }
}