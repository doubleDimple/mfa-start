package com.doubledimple.mfa.entity;
import javax.persistence.*;
import java.time.LocalDateTime;
/**
 * @author doubleDimple
 * @date 2024:10:05日 00:57
 */
@Entity
public class OTPKey {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "keyName",unique = true)
    private String keyName;
    private String secretKey;

    @Column(name = "qrCode", length = 1024, nullable = true)
    private String qrCode;

    private String issuer;


    public OTPKey() {
    }

    public OTPKey(String keyName, String secretKey) {
        this.keyName = keyName;
        this.secretKey = secretKey;
    }

    // Getters and Setters
    public String getKeyName() {
        return keyName;
    }

    public void setKeyName(String keyName) {
        this.keyName = keyName;
    }

    public String getSecretKey() {
        return secretKey;
    }

    public void setSecretKey(String secretKey) {
        this.secretKey = secretKey;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIssuer() {
        return issuer;
    }

    public void setIssuer(String issuer) {
        this.issuer = issuer;
    }
}

