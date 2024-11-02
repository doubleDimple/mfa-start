package com.doubledimple.mfa.repository;

import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.entity.SyncSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SyncSettingsRepository extends JpaRepository<SyncSettings, Long> , JpaSpecificationExecutor<SyncSettings> {
    // 获取第一条配置
    Optional<SyncSettings> findFirstByOrderById();
}
