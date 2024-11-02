package com.doubledimple.mfa.repository;

import com.doubledimple.mfa.entity.SyncHistory;
import com.doubledimple.mfa.entity.SyncSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SyncHistoryRepository extends JpaRepository<SyncHistory, Long>, JpaSpecificationExecutor<SyncHistory> {
    // 按时间倒序获取历史记录
    List<SyncHistory> findAllByOrderByTimeDesc();
}
