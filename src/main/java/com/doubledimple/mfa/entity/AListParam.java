package com.doubledimple.mfa.entity;

import lombok.Builder;
import lombok.Data;

/**
 * @author doubleDimple
 * @date 2024:11:03日 09:27
 */
@Data
@Builder
public class AListParam {

    private String userName;
    private String password;
}
