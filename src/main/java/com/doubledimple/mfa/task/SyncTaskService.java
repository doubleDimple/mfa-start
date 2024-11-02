package com.doubledimple.mfa.task;

import com.doubledimple.mfa.entity.SyncSettings;
import com.doubledimple.mfa.service.SyncService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * @author doubleDimple
 * @date 2024:11:02日 13:14
 */
@Component
@Slf4j
public class SyncTaskService {

    @Resource
    SyncService syncService;


    @Scheduled(cron = "0 0 1 * * ?")
    public void checkAndSync() {
        try {
            SyncSettings settings = syncService.getSettings();
            if (!settings.isEnabled() || settings.getSyncInterval() == null) {
                return;
            }

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime lastSync = settings.getLastSyncTime();

            if (lastSync == null ||
                    ChronoUnit.DAYS.between(lastSync, now) >= settings.getSyncInterval()) {
                log.info("Starting scheduled sync...");
                syncService.syncNowTask();
            }
        } catch (Exception e) {
            log.error("Failed to check and sync", e);
        }
    }
}
