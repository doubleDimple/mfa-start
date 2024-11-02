package com.doubledimple.mfa.service;

import com.doubledimple.mfa.entity.SyncHistory;
import com.doubledimple.mfa.entity.SyncSettings;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public interface SyncService {

    void saveSettings(SyncSettings settings);

    public SyncSettings getSettings();

    public List<SyncHistory> getHistory();

    public boolean testConnection(String url, String token);

    public CompletableFuture<Boolean> syncNow();

    public LocalDateTime getNextSyncTime();

    public void syncNowTask();
}
