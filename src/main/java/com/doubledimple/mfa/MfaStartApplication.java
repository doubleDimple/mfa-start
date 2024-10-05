package com.doubledimple.mfa;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * @author doubleDimple
 * @date 2024:10:05日 00:52
 */
@SpringBootApplication
//@EnableJpaRepositories(basePackages = {"com.doubledimple.mfa.service.*"})
public class MfaStartApplication {

    public static void main(String[] args) {
        SpringApplication.run(MfaStartApplication.class, args);
    }
}
