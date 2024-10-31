package com.doubledimple.mfa.service;

import com.doubledimple.mfa.entity.OTPKey;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OTPKeyRepository extends JpaRepository<OTPKey, Long>, JpaSpecificationExecutor<OTPKey> {

    // 根据 name 删除一条记录
    void deleteByKeyName(String keyName);

    OTPKey queryOTPKeyByKeyName(String keyName);

    OTPKey findByKeyName(String keyName);
}
