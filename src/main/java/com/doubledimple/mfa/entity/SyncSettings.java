package com.doubledimple.mfa.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * @author doubleDimple
 * @date 2024:11:02日 12:38
 */
@Entity
@Table(name = "sync_settings")
@Data
public class SyncSettings {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private boolean enabled;
    private String aListUrl;
    private String aListToken;
    private String backupPath;
    // 同步周期（天数）
    private Integer syncInterval;

    // 上次同步时间
    @Column(name = "last_sync_time")
    private LocalDateTime lastSyncTime;
}
