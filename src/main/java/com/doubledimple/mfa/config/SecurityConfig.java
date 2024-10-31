package com.doubledimple.mfa.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;

/**
 * @author doubleDimple
 * @date 2024:10:05日 23:27
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeRequests()
                .antMatchers("/login", "/css/**", "/js/**").permitAll() // 允许访问登录页面和静态资源
                .anyRequest().authenticated() // 其他请求需要认证
                .and()
                .formLogin()
                .loginPage("/login") // 自定义登录页面
                .loginProcessingUrl("/perform_login") // 表单提交处理路径
                .defaultSuccessUrl("/", true) // 登录成功后跳转到根路径
                .permitAll()
                .and()
                .logout()
                .logoutUrl("/perform_logout")
                .logoutSuccessUrl("/login?logout") // 登出后跳转的页面
                .permitAll();

        return http.build();
    }

    @Bean
    public HttpFirewall allowUrlSemicolonHttpFirewall() {
        StrictHttpFirewall firewall = new StrictHttpFirewall();
        // 允许分号
        firewall.setAllowSemicolon(true);
        // 如果需要,还可以允许其他字符
        firewall.setAllowUrlEncodedSlash(true);  // 允许URL编码的斜杠
        firewall.setAllowBackSlash(true);        // 允许反斜杠
        firewall.setAllowUrlEncodedPercent(true);// 允许URL编码的百分号
        return firewall;
    }
}
