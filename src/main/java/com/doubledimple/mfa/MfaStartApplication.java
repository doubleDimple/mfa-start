package com.doubledimple.mfa;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * @author doubleDimple
 * @date 2024:10:05日 00:52
 */
@SpringBootApplication
//@EnableJpaRepositories(basePackages = {"com.doubledimple.mfa.service.*"})
@Slf4j
public class MfaStartApplication {

    public static void main(String[] args) {
        SpringApplication.run(MfaStartApplication.class, args);

        log.info("MFA-START START SUCCESS........");
    }
}
