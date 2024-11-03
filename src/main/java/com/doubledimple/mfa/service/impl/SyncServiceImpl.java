package com.doubledimple.mfa.service.impl;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpException;
import cn.hutool.http.HttpResponse;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.doubledimple.mfa.entity.AListParam;
import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.entity.SyncHistory;
import com.doubledimple.mfa.entity.SyncSettings;
import com.doubledimple.mfa.repository.OTPKeyRepository;
import com.doubledimple.mfa.repository.SyncHistoryRepository;
import com.doubledimple.mfa.repository.SyncSettingsRepository;
import com.doubledimple.mfa.response.AListResponse;
import com.doubledimple.mfa.response.AListTokenResponse;
import com.doubledimple.mfa.service.SyncService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.awt.print.Pageable;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

import static com.doubledimple.mfa.constant.Constant.A_LIST_AUTH_LOGIN_URL_SUFFIX;
import static com.doubledimple.mfa.constant.Constant.A_LIST_PUT_URL_SUFFIX;

/**
 * @author doubleDimple
 * @date 2024:11:02日 12:46
 */
@Service
@Slf4j
public class SyncServiceImpl implements SyncService {
    @Resource
    private SyncSettingsRepository syncSettingsRepository;

    @Resource
    private SyncHistoryRepository syncHistoryRepository;

    @Resource
    OTPKeyRepository otpKeyRepository;

    @Value("${upload.baseUrl}")
    private String baseurl;

    private final ObjectMapper objectMapper = new ObjectMapper();


    public SyncSettings getSettings() {
        return syncSettingsRepository.findFirstByOrderById()
                .orElse(new SyncSettings());
    }

    @Override
    @Transactional
    public void saveSettings(SyncSettings settings) {
        if (settings.getId() == null) {
            // 如果是新设置，确保只有一条记录
            syncSettingsRepository.findFirstByOrderById().ifPresent(existing -> {
                settings.setId(existing.getId());
            });
        }
        syncSettingsRepository.save(settings);
    }

    @Override
    public List<SyncHistory> getHistory() {
        int pageSize = 15;
        PageRequest time = PageRequest.of(0, pageSize, Sort.by(Sort.Direction.DESC, "time"));
        return syncHistoryRepository.findAllByOrderByTimeDesc(time);
    }

    @Override
    public boolean testConnection(String url,String username, String password) {
        SyncSettings syncSettings = new SyncSettings();
        syncSettings.setAListUrl(url);
        syncSettings.setUserName(username);
        syncSettings.setPassword(password);
        String aListToken = getAListToken(syncSettings);
        if (StringUtils.isEmpty(aListToken)){
            log.error("Test connection failed please your userName and password");
            return false;
        }
        return true;
    }

    @Async
    @Transactional
    public CompletableFuture<Boolean> syncNow() {
        SyncSettings settings = getSettings();
        if (!settings.isEnabled()) {
            return CompletableFuture.completedFuture(false);
        }

        SyncHistory history = new SyncHistory();
        history.setTime(LocalDateTime.now());

        File tempFile = null;
        try {
            // 创建备份文件
            tempFile = createBackupFile();

            // 上传到Alist
            boolean success = uploadToAlist(tempFile, settings);

            // 记录历史
            history.setSuccess(success);
            history.setSize(tempFile.length());
            history.setDetails(success ? "Successfully synced " + otpKeyRepository.count() + " keys"
                    : "Sync failed");

            return CompletableFuture.completedFuture(success);

        } catch (Exception e) {
            log.error("Sync failed", e);
            history.setSuccess(false);
            history.setDetails("Error: " + e.getMessage());
            return CompletableFuture.completedFuture(false);

        } finally {
            // 保存历史记录
            syncHistoryRepository.save(history);

            // 清理临时文件
            if (tempFile != null && tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    private File createBackupFile() throws Exception {
        SyncSettings settings = getSettings();
        String backupPath = baseurl + settings.getBackupPath();
        File backupFolder = new File(backupPath);
        if (!backupFolder.exists()) {
            backupFolder.mkdirs();
        }
        // 获取所有OTP密钥数据
        List<OTPKey> keys = otpKeyRepository.findAll();

        // 创建导出数据对象
        Map<String, Object> exportData = new HashMap<>();
        exportData.put("exportTime", LocalDateTime.now().toString());
        exportData.put("totalCount", keys.size());

        // 转换密钥数据，移除不需要的字段
        List<Map<String, String>> keyList = new ArrayList<>();
        for (OTPKey key : keys) {
            Map<String, String> keyMap = new HashMap<>();
            keyMap.put("keyName", key.getKeyName());
            keyMap.put("secretKey", key.getSecretKey());
            keyMap.put("issuer", key.getIssuer());
            keyList.add(keyMap);
        }
        exportData.put("keys", keyList);

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        File backupFile = new File(backupPath, "otp_backup_" + timestamp + ".json");
        objectMapper.writerWithDefaultPrettyPrinter().writeValue(backupFile, exportData);

        // 创建临时文件
        //File tempFile = File.createTempFile("otp_backup_", ".json");
        //objectMapper.writerWithDefaultPrettyPrinter().writeValue(tempFile, exportData);

        // 验证文件是否成功写入
        if (!backupFile.exists()) {
            log.error("File was not created: {}", backupFile.getAbsolutePath());
            throw new IOException("Failed to create backup file");
        }

        if (backupFile.length() == 0) {
            log.error("File was created but is empty: {}", backupFile.getAbsolutePath());
            throw new IOException("Backup file is empty");
        }

        // 尝试读取文件内容进行验证
        String content = new String(Files.readAllBytes(backupFile.toPath()));
        if (content.isEmpty()) {
            log.error("File content is empty");
            throw new IOException("Backup file content is empty");
        }

        log.info("Successfully created backup file: {}, size: {} bytes",
                backupFile.getAbsolutePath(), backupFile.length());

        return backupFile;
    }

    private boolean uploadToAlist(File file, SyncSettings settings) {
        try {
            String alistUrl = settings.getAListUrl();
            // 确保URL格式正确
            if (!alistUrl.startsWith("http://") && !alistUrl.startsWith("https://")) {
                alistUrl = "http://" + alistUrl;
            }
            alistUrl = alistUrl.replaceAll("/$", "");

            // 构建上传路径
            String uploadPath = settings.getBackupPath();
            // 确保路径格式正确 (新版本不需要开头的斜杠)
            uploadPath = uploadPath.replaceAll("^/+", "");

            // 构建完整的上传URL
            String uploadUrl = alistUrl + A_LIST_PUT_URL_SUFFIX;

            log.info("Uploading to: {}", uploadUrl);
            log.info("Upload path: {}", uploadPath);
            String aListToken = getAListToken(settings);
            if (StringUtils.isEmpty(aListToken)){
                log.error("Failed to get aList token");
                return false;
            }
            uploadFile(file.getPath(),uploadPath,uploadUrl,aListToken);
            return true;

        } catch (Exception e) {
            log.error("Failed to upload file to Alist", e);
            return false;
        }
    }

    @Override
    public void syncNowTask() {
        File tempFile = null;
        try {
            SyncSettings settings = getSettings();
            if (!settings.isEnabled()) {
                log.info("Sync is disabled, skipping backup");
                return;
            }

            log.info("Creating backup file...");
            tempFile = createBackupFile();

            log.info("Uploading backup file to Alist...");
            boolean success = uploadToAlist(tempFile, settings);

            if (success) {
                log.info("Backup completed successfully");
                // 更新上次同步时间
                settings.setLastSyncTime(LocalDateTime.now());
                syncSettingsRepository.save(settings);
            } else {
                log.error("Backup failed");
            }

        } catch (Exception e) {
            log.error("Backup failed", e);
        } finally {
            if (tempFile != null && tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    @Override
    public String getAListToken(SyncSettings settings) {
        String userName = settings.getUserName();
        String password = settings.getPassword();
        String aListUrl = settings.getAListUrl();
        // 如果URL以/结尾，去掉/
        String token = null;
        try {
            if (aListUrl.endsWith("/")) {
                aListUrl = StrUtil.removeSuffix(aListUrl, "/");
            }
            String fullPath = aListUrl + A_LIST_AUTH_LOGIN_URL_SUFFIX;
            AListParam build = AListParam.builder().userName(userName).password(password).build();
            String s = JSONUtil.toJsonStr(build);
            HttpResponse execute = HttpUtil.createPost(fullPath).body(s).execute();
            String body = execute.body();

            AListResponse aListResponse = JSONUtil.toBean(body, AListResponse.class);
            // 将data转换为JSONObject
            JSONObject jsonObject = JSONUtil.parseObj(aListResponse.getData());
            // 获取token
            token = jsonObject.getStr("token");
        } catch (HttpException e) {
            log.error("get aList token err: {}",e.getMessage(),e);
            return StringUtils.EMPTY;
        }
        return token;
    }

    public LocalDateTime getNextSyncTime() {
        SyncSettings settings = getSettings();
        if (!settings.isEnabled() || settings.getSyncInterval() == null
                || settings.getLastSyncTime() == null) {
            return null;
        }
        return settings.getLastSyncTime().plusDays(settings.getSyncInterval());
    }


    public static void uploadFile(String filePath, String targetPath,String url,String token) {
        OkHttpClient client = new OkHttpClient();

        try {
            // 创建文件对象
            File file = new File(filePath);

            // 构建完整的上传路径：挂载路径 + 子路径
            String fullPath = targetPath;
            // 添加文件名
            fullPath += "/" + file.getName();

            System.out.println("完整上传路径: " + fullPath);

            // 构建multipart请求体
            RequestBody requestBody = new MultipartBody.Builder()
                    .setType(MultipartBody.FORM)
                    .addFormDataPart("file", file.getName(),
                            RequestBody.create(MediaType.parse("application/octet-stream"), file))
                    .build();

            // 构建请求
            Request request = new Request.Builder()
                    .url(url)
                    .put(requestBody)
                    .addHeader("Authorization", token)
                    .addHeader("File-Path", URLEncoder.encode(targetPath + "/" + file.getName(), StandardCharsets.UTF_8.toString()))
                    .addHeader("Content-Length", String.valueOf(file.length()))
                    .addHeader("Content-Type", "multipart/form-data")
                    .build();

            // 发送请求
            try (Response response = client.newCall(request).execute()) {
                if (response.isSuccessful()) {
                    if (response.code() == 200){
                        log.info("Upload successful: {}",response.body().string());
                    }else {
                        log.error("Upload failed code:{}  message:{}",response.code(),response.message());
                    }
                } else {
                    log.error("Upload failed code:{}  message:{}",response.code(),response.message());
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        String userName = "admin";
        String password = "NEW_PASSWORD_20240919@@@";
        AListParam build = AListParam.builder().userName(userName).password(password).build();
        String s = JSONUtil.toJsonStr(build);
        HttpResponse execute = HttpUtil.createPost(" http://152.53.1.173:5244/api/auth/login").body(s).execute();
        String body = execute.body();

        AListResponse aListResponse = JSONUtil.toBean(body, AListResponse.class);
        // 将data转换为JSONObject
        JSONObject jsonObject = JSONUtil.parseObj(aListResponse.getData());
        // 获取token
        String token = jsonObject.getStr("token");
        System.out.println(token);
    }
}
