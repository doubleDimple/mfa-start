package com.doubledimple.mfa.entity;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

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

    // 添加创建时间字段
    @Column(name = "createTime", nullable = false)
    private LocalDateTime createTime = LocalDateTime.now();  // 设置默认值

    // 添加更新时间字段
    @Column(name = "updateTime", nullable = false)
    private LocalDateTime updateTime = LocalDateTime.now();  // 设置默认值

    // 在每次更新实体时自动更新updateTime
    @PreUpdate
    public void preUpdate() {
        updateTime = LocalDateTime.now();
    }


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

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
}

