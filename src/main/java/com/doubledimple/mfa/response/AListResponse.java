package com.doubledimple.mfa.response;

import lombok.Data;

/**
 * @author doubleDimple
 * @date 2024:11:03日 09:30
 */
@Data
public class AListResponse<T> {

    private String code;
    private String message;
    private T data;
}
