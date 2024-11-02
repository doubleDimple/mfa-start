package com.doubledimple.mfa.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * @author doubleDimple
 * @date 2024:11:02日 12:39
 */
@Entity
@Table(name = "sync_history")
@Data
public class SyncHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime time;

    private boolean success;
    private String details;
    private Long size;  // 文件大小（字节）
}
