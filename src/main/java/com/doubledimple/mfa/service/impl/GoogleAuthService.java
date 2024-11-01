package com.doubledimple.mfa.service.impl;

import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorConfig;
import org.apache.commons.codec.binary.Base32;
import org.apache.commons.codec.binary.Base64;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * @author doubleDimple
 * @date 2024:11:02日 00:26
 */
@Service
public class GoogleAuthService {
    private final GoogleAuthenticator gAuth;

    public GoogleAuthService() {
        // 配置TOTP参数
        GoogleAuthenticatorConfig config = new GoogleAuthenticatorConfig.GoogleAuthenticatorConfigBuilder()
                .setTimeStepSizeInMillis(TimeUnit.SECONDS.toMillis(30))
                .setWindowSize(2)  // 允许前后1个窗口的验证码
                .setCodeDigits(6)
                .build();

        this.gAuth = new GoogleAuthenticator(config);
    }

    /**
     * 处理并规范化密钥
     */
    public String normalizeSecretKey(String secretKey) {
        try {
            // 移除所有空白字符
            secretKey = secretKey.replaceAll("\\s+", "");

            // 如果是Base64格式，转换为Base32
            if (isBase64(secretKey)) {
                byte[] decodedKey = Base64.decodeBase64(secretKey);
                secretKey = new Base32().encodeAsString(decodedKey);
            }

            // 转换为大写并移除填充字符
            secretKey = secretKey.toUpperCase().replaceAll("=+$", "");

            // 验证密钥格式
            if (!isValidBase32(secretKey)) {
                throw new IllegalArgumentException("Invalid key format");
            }

            return secretKey;
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to normalize key: " + e.getMessage());
        }
    }

    /**
     * 生成验证码
     */
    public String generateTOTP(String secretKey) {
        try {
            // 规范化密钥
            String normalizedKey = normalizeSecretKey(secretKey);

            // 生成验证码
            int code = gAuth.getTotpPassword(normalizedKey);
            return String.format("%06d", code);
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to generate TOTP: " + e.getMessage());
        }
    }

    /**
     * 验证TOTP代码
     */
    public boolean verifyTOTP(String secretKey, String code) {
        try {
            // 规范化密钥
            String normalizedKey = normalizeSecretKey(secretKey);

            // 验证代码
            int codeInt = Integer.parseInt(code);
            return gAuth.authorize(normalizedKey, codeInt);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid code format");
        } catch (Exception e) {
            throw new IllegalArgumentException("Verification failed: " + e.getMessage());
        }
    }

    /**
     * 判断是否为Base64格式
     */
    private boolean isBase64(String str) {
        try {
            Base64.decodeBase64(str);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 验证Base32格式
     */
    private boolean isValidBase32(String str) {
        return str.matches("^[A-Z2-7]+$");
    }

    /**
     * 调试方法：显示密钥信息
     */
    public void debugKey(String secretKey) {
        try {
            String normalizedKey = normalizeSecretKey(secretKey);
            System.out.println("Original Key: " + secretKey);
            System.out.println("Normalized Key: " + normalizedKey);
            System.out.println("Current Code: " + generateTOTP(normalizedKey));
            System.out.println("Current Time: " + System.currentTimeMillis() / 1000);
            System.out.println("Time Step: " + (System.currentTimeMillis() / (30 * 1000)));
        } catch (Exception e) {
            System.out.println("Debug Error: " + e.getMessage());
        }
    }
}
