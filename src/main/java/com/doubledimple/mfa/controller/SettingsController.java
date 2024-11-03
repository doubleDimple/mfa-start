package com.doubledimple.mfa.controller;

import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.entity.SyncHistory;
import com.doubledimple.mfa.entity.SyncSettings;
import com.doubledimple.mfa.service.SyncService;
import com.google.zxing.WriterException;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * @author doubleDimple
 * @date 2024:11:02日 12:30
 */
@Controller
@Slf4j
@RequestMapping("/")
public class SettingsController {

    @Resource
    private SyncService syncService;

    @GetMapping("/settings")
    public String settings(Model model) {
        model.addAttribute("syncSettings", syncService.getSettings());
        model.addAttribute("syncHistory", syncService.getHistory());
        return "settings";
    }

    @PostMapping("/api/test-connection")
    @ResponseBody
    public Map<String, Object> testConnection(@RequestBody Map<String, String> request) {
        String userName = request.get("userName");
        String password = request.get("password");
        String url = request.get("url");
        boolean success = syncService.testConnection(url, userName,password);
        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("message", success ? "Connection successful" : "Connection failed");
        return response;
    }

    @PostMapping("/api/sync-now")
    @ResponseBody
    public Map<String, Object> sync() {
        Map<String, Object> response = new HashMap<>();
        try {
            boolean success = syncService.syncNow().get(30, TimeUnit.SECONDS);
            response.put("success", success);
            response.put("message", success ? "Sync completed" : "Sync failed");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Sync failed: " + e.getMessage());
        }
        return response;
    }

    @GetMapping("/api/sync-history")
    @ResponseBody
    public List<SyncHistory> getHistory() {
        return syncService.getHistory();
    }

    @GetMapping("/api/settings")
    @ResponseBody
    public SyncSettings getSettings() {
        return syncService.getSettings();
    }

    @PostMapping("/api/save-settings")
    @ResponseBody
    public Map<String, Object> saveSettings(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        String aListUrl = request.get("alistUrl");
        Boolean enabled = Boolean.valueOf(request.get("enabled"));
        String password = request.get("password");
        String userName = request.get("userName");
        String backupPath = request.get("backupPath");
        Integer interval = Integer.valueOf(request.get("syncInterval"));
        try {
            SyncSettings settingsDb = syncService.getSettings();
            if (null != settingsDb) {
                settingsDb.setId(settingsDb.getId());
                settingsDb.setSyncInterval(interval);
                settingsDb.setBackupPath(backupPath);
                settingsDb.setEnabled(enabled);
                settingsDb.setAListUrl(aListUrl);
                settingsDb.setPassword(password);
                settingsDb.setUserName(userName);
                syncService.saveSettings(settingsDb);

            }else {
                settingsDb.setSyncInterval(interval);
                settingsDb.setBackupPath(backupPath);
                settingsDb.setEnabled(enabled);
                settingsDb.setAListUrl(aListUrl);
                settingsDb.setPassword(password);
                settingsDb.setUserName(userName);
                syncService.saveSettings(settingsDb);
            }
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        return response;
    }

    @GetMapping("/api/sync-status")  // 这个路径会变成 /api/sync-status
    public ResponseEntity<Map<String, Object>> getSyncStatus() {
        Map<String, Object> status = new HashMap<>();
        try {
            SyncSettings settings = syncService.getSettings();

            status.put("lastSync", settings.getLastSyncTime() != null ?
                    settings.getLastSyncTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : null);

            LocalDateTime nextSync = syncService.getNextSyncTime();
            status.put("nextSync", nextSync != null ?
                    nextSync.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : null);

            status.put("interval", settings.getSyncInterval());
            status.put("enabled", settings.isEnabled());

            return ResponseEntity.ok(status);
        } catch (Exception e) {
            status.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(status);
        }
    }
}
