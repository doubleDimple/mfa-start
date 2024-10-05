package com.doubledimple.mfa.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * @author doubleDimple
 * @date 2024:10:06日 00:03
 */
@Controller
public class LoginController {

    @GetMapping("/login")
    public String login() {
        return "login"; // 指定视图名为 `login.ftl`
    }
}
