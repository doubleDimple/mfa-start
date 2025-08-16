package com.doubledimple.mfa.controller;

import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.repository.OTPKeyRepository;
import com.doubledimple.mfa.request.OtpBatchRequest;
import com.doubledimple.mfa.response.OtpResponse;
import com.doubledimple.mfa.response.OtpResponse2;
import com.doubledimple.mfa.service.OTPService;
import com.doubledimple.mfa.service.QRCodeService;
import com.doubledimple.mfa.utils.GoogleAuthMigrationParser;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;

import static com.doubledimple.mfa.utils.DesktopUtils.isMobileRequest;


/**
 * @author doubleDimple
 * @date 2024:10:05日 01:00
 */
@Controller
@Slf4j
public class OTPController {

    @Resource
    private OTPService otpService;

    @Resource
    private QRCodeService qrCodeService;

    @Resource
    private OTPKeyRepository otpKeyRepository;

    // 显示主页
    @GetMapping("/")
    public String index(Model model, HttpServletRequest request) {
        List<OTPKey> otpKeys = otpService.getAllKeys();
        if (otpKeys.size() > 0) {
            model.addAttribute("otpKeys", otpKeys);
        }
        if (isMobileRequest(request)) {
            return "mobile/mobile_index";
        } else {
            return "index";
        }
    }

    // 保存密钥
    @PostMapping("/save-secret2")
    public String saveSecret2(@RequestParam(value = "keyName", required = false) String keyName,
                              @RequestParam(value = "secretKey", required = false) String secretKey,
                              @RequestParam(value = "qrCode", required = false) MultipartFile qrCode) {
        AtomicReference<String> finalSecretKey = new AtomicReference<>(secretKey);
        List<Map<String, String>> accounts = new ArrayList<>();
        if (StringUtils.isEmpty(keyName)) {
            keyName = System.currentTimeMillis() + "";
        }
        try {
            // 如果上传了二维码文件，则解析二维码
            if (qrCode != null && !qrCode.isEmpty()) {
                // 读取图片
                BufferedImage image = ImageIO.read(qrCode.getInputStream());
                if (image == null) {
                    throw new IllegalArgumentException("Invalid image file");
                }

                // 使用ZXing解析二维码
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
                        new BufferedImageLuminanceSource(image)));
                Result result = new MultiFormatReader().decode(binaryBitmap);

                // 解析 otpauth:// URI
                String qrContent = result.getText();
                log.info("qrCode text is: {}", qrContent);
                if (qrContent.startsWith("otpauth://")) {
                    URI uri = new URI(qrContent);
                    String query = uri.getQuery();
                    // 从查询参数中获取 secret
                    Arrays.stream(query.split("&"))
                            .filter(param -> param.startsWith("secret="))
                            .findFirst()
                            .ifPresent(secret -> {
                                finalSecretKey.set(secret.substring(7));// 去掉 "secret=" 前缀
                            });
                    // 验证 secretKey 不为空
                    if (finalSecretKey.get() == null || finalSecretKey.get().trim().isEmpty()) {
                        throw new IllegalArgumentException("Secret key is required");
                    }
                    OTPKey otpKey = new OTPKey(keyName, finalSecretKey.get());
                    otpKey.setIssuer("mfa-start");
                    OTPKey byKeyName = otpKeyRepository.findBySecretKey(otpKey.getSecretKey());
                    if (byKeyName == null) {
                        otpService.saveKey(otpKey);
                    }

                } else if (qrContent.startsWith("otpauth-migration://")) {

                    List<GoogleAuthMigrationParser.OtpParameters> otpParameters = GoogleAuthMigrationParser.parseUri(qrContent);
                    List<OTPKey> otpKeys = new ArrayList<>();
                    for (GoogleAuthMigrationParser.OtpParameters account : otpParameters) {
                        OTPKey otpKey = new OTPKey();
                        otpKey.setKeyName(account.getName());
                        otpKey.setSecretKey(account.getSecretInBase32());
                        if (account.getIssuer() == null) {
                            otpKey.setIssuer("mfa-start");
                        } else {
                            otpKey.setIssuer(account.getIssuer());
                        }
                        String otpAuthUri = String.format("otpauth://totp/%s:%s?secret=%s&issuer=%s",
                                otpKey.getIssuer(), otpKey.getKeyName(), otpKey.getSecretKey(), otpKey.getIssuer());

                        String qrCodeNew = qrCodeService.generateQRCodeImage(otpAuthUri);
                        otpKey.setQrCode(qrCodeNew);
                        OTPKey byKeyName = otpKeyRepository.findBySecretKey(otpKey.getSecretKey());
                        if (byKeyName != null) {
                            otpKeys.add(byKeyName);
                        } else {
                            otpKeys.add(otpKey);
                        }

                    }
                    otpService.saveListKey(otpKeys);
                }
            } else {
                OTPKey otpKey = new OTPKey(keyName, secretKey);
                otpKey.setIssuer("mfa-start");
                OTPKey byKeyName = otpKeyRepository.findByKeyName(keyName);
                if (byKeyName == null) {
                    otpService.saveKey(new OTPKey(keyName, secretKey));
                }
            }
            log.info("result:{}", accounts);
            return "redirect:/";
        } catch (Exception e) {
            log.error("Error saving OTP key", e);
            return "redirect:/";
        }
    }


    /**
     * 统一处理前端提交的密钥和二维码内容。
     * * @param keyName 手动输入的账户名
     *
     * @param secretKey 手动输入的密钥
     * @param qrContent 前端扫描后发送的原始二维码字符串
     * @param qrCode    前端上传的二维码图片文件
     * @return 重定向到首页
     */
    @PostMapping("/save-secret")
    public String saveSecret(@RequestParam(value = "keyName", required = false) String keyName,
                             @RequestParam(value = "secretKey", required = false) String secretKey,
                             @RequestParam(value = "qrContent", required = false) String qrContent,
                             @RequestParam(value = "qrCode", required = false) MultipartFile qrCode) {

        try {
            if (!StringUtils.isEmpty(qrContent)) {
                // 情景1: 前端发送了二维码字符串
                processQrContent(qrContent);
            } else if (qrCode != null && !qrCode.isEmpty()) {
                // 情景2: 前端上传了二维码文件 (兼容旧逻辑)
                BufferedImage image = ImageIO.read(qrCode.getInputStream());
                if (image == null) {
                    throw new IllegalArgumentException("Invalid image file");
                }
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
                        new BufferedImageLuminanceSource(image)));
                Result result = new MultiFormatReader().decode(binaryBitmap);
                processQrContent(result.getText());
            } else if (!StringUtils.isEmpty(secretKey)) {
                // 情景3: 前端手动输入了密钥
                OTPKey otpKey = new OTPKey(keyName, secretKey);
                otpKey.setIssuer("mfa-start");
                OTPKey byKeyName = otpKeyRepository.findByKeyName(keyName);
                if (byKeyName == null) {
                    otpService.saveKey(otpKey);
                }
            } else {
                throw new IllegalArgumentException("No valid key or QR code provided.");
            }

            return "redirect:/";
        } catch (Exception e) {
            log.error("Error saving OTP key", e);
            return "redirect:/";
        }
    }

    /**
     * 统一处理二维码内容字符串的私有方法
     *
     * @param qrContent 二维码内容字符串
     * @throws Exception
     */
    private void processQrContent(String qrContent) throws Exception {
        log.info("Processing QR code content: {}", qrContent);
        if (qrContent.startsWith("otpauth://")) {
            URI uri = new URI(qrContent);
            String query = uri.getQuery();
            AtomicReference<String> finalSecretKey = new AtomicReference<>();
            String finalKeyName = uri.getPath().substring(1);
            String finalIssuer = null;

            // 解析查询参数
            if (query != null) {
                for (String param : query.split("&")) {
                    String[] parts = param.split("=");
                    if (parts.length == 2) {
                        if ("secret".equals(parts[0])) {
                            finalSecretKey.set(parts[1]);
                        }
                        if ("issuer".equals(parts[0])) {
                            finalIssuer = parts[1];
                        }
                    }
                }
            }

            // 如果账户名包含冒号，按规范解析账户名和发行人
            if (finalKeyName.contains(":")) {
                String[] parts = finalKeyName.split(":");
                finalIssuer = parts[0];
                finalKeyName = parts[1];
            }

            if (finalSecretKey.get() == null || finalSecretKey.get().trim().isEmpty()) {
                throw new IllegalArgumentException("Secret key is required from QR content");
            }

            OTPKey otpKey = new OTPKey(finalKeyName, finalSecretKey.get());
            otpKey.setIssuer(finalIssuer != null ? finalIssuer : "mfa-start");

            OTPKey bySecretKey = otpKeyRepository.findBySecretKey(otpKey.getSecretKey());
            if (bySecretKey == null) {
                otpService.saveKey(otpKey);
            } else {
                log.warn("OTP key with same secret already exists, skipping save.");
            }

        } else if (qrContent.startsWith("otpauth-migration://")) {
            List<GoogleAuthMigrationParser.OtpParameters> otpParameters = GoogleAuthMigrationParser.parseUri(qrContent);
            List<OTPKey> otpKeys = new ArrayList<>();
            for (GoogleAuthMigrationParser.OtpParameters account : otpParameters) {
                OTPKey otpKey = new OTPKey();
                otpKey.setKeyName(account.getName());
                otpKey.setSecretKey(account.getSecretInBase32());
                otpKey.setIssuer(account.getIssuer() != null ? account.getIssuer() : "mfa-start");

                OTPKey bySecretKey = otpKeyRepository.findBySecretKey(otpKey.getSecretKey());
                if (bySecretKey == null) {
                    // 为每个密钥生成二维码并保存
                    String otpAuthUri = String.format("otpauth://totp/%s:%s?secret=%s&issuer=%s",
                            otpKey.getIssuer(), otpKey.getKeyName(), otpKey.getSecretKey(), otpKey.getIssuer());
                    String qrCodeNew = qrCodeService.generateQRCodeImage(otpAuthUri);
                    otpKey.setQrCode(qrCodeNew);
                    otpKeys.add(otpKey);
                } else {
                    otpKeys.add(bySecretKey);
                }
            }
            otpService.saveListKey(otpKeys);
        } else {
            // 其他未知格式，可以抛出异常或返回错误信息
            throw new IllegalArgumentException("Unsupported QR code format.");
        }
    }

    // 生成 OTP 码
    @GetMapping("/generate-otp")
    @ResponseBody
    public OtpResponse2 generateOtp(@RequestParam("secretKey") String secretKey) {
        String otpCode = otpService.generateOtpCode(secretKey);
        return new OtpResponse2(otpCode);
    }

    // 生成 OTP 码
    @PostMapping("/generate-otp-batch")
    public ResponseEntity<List<OtpResponse>> generateOtpBatch(@RequestBody OtpBatchRequest request) {
        try {
            List<OtpResponse> otpResponses = otpService.generateOtpBatch(request.getSecretKeys());
            return ResponseEntity.ok(otpResponses);
        } catch (Exception e) {
            log.error("Error generating OTP batch", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/delete-key")
    @ResponseBody
    public OtpResponse2 deleteKey(@RequestBody Map<String, String> payload) {
        String keyName = payload.get("keyName");
        if (keyName == null || keyName.isEmpty()) {
            return new OtpResponse2("keyName is null");
        }
        otpService.deleteKey(keyName);
        return new OtpResponse2("OK");
    }


    @GetMapping("/export-data")
    public void exportToCSV(HttpServletResponse response) throws IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"otp_keys.csv\"");
        PrintWriter writer = response.getWriter();
        writer.println("Key Name,Issuer,Secret Key,Created Date");

        List<OTPKey> otpKeys = otpService.getAllKeys();
        for (OTPKey otpKey : otpKeys) {
            writer.printf("%s,%s,%s,%s%n", otpKey.getKeyName(), otpKey.getIssuer(), otpKey.getSecretKey(), otpKey.getCreateTime());
        }
        writer.flush();
    }

    // 导入密钥
    @PostMapping("/import-keys")
    public String importKeys(@RequestParam("csvFile") MultipartFile csvFile) {
        try {
            if (csvFile.isEmpty()) {
                log.error("CSV file is empty");
                return "redirect:/";
            }

            String content = new String(csvFile.getBytes(), StandardCharsets.UTF_8);
            String[] lines = content.split("\n");

            List<OTPKey> otpKeysToImport = new ArrayList<>();

            // 跳过标题行，从第二行开始处理
            for (int i = 1; i < lines.length; i++) {
                String line = lines[i].trim();
                if (line.isEmpty()) continue;

                // 解析CSV行，处理可能的引号
                String[] parts = parseCSVLine(line);
                if (parts.length >= 3) {
                    String keyName = parts[0].trim();
                    String issuer = parts[1].trim();
                    String secretKey = parts[2].trim();

                    if (!keyName.isEmpty() && !secretKey.isEmpty()) {
                        // 检查是否已存在
                        OTPKey existingKey = otpKeyRepository.findBySecretKey(secretKey);
                        if (existingKey == null) {
                            OTPKey otpKey = new OTPKey(keyName, secretKey);
                            otpKey.setIssuer(issuer.isEmpty() ? "mfa-start" : issuer);
                            String otpAuthUri = String.format("otpauth://totp/%s:%s?secret=%s&issuer=%s",
                                    otpKey.getIssuer(), otpKey.getKeyName(), otpKey.getSecretKey(), otpKey.getIssuer());
                            String qrCodeNew = qrCodeService.generateQRCodeImage(otpAuthUri);
                            otpKey.setQrCode(qrCodeNew);
                            otpKeysToImport.add(otpKey);
                        }
                    }
                }
            }

            if (!otpKeysToImport.isEmpty()) {
                otpService.saveListKey(otpKeysToImport);
                log.info("Successfully imported {} OTP keys", otpKeysToImport.size());
            }

            return "redirect:/";
        } catch (Exception e) {
            log.error("Error importing CSV file", e);
            return "redirect:/";
        }
    }

    // 解析CSV行的辅助方法
    private String[] parseCSVLine(String line) {
        List<String> result = new ArrayList<>();
        boolean inQuotes = false;
        StringBuilder current = new StringBuilder();

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                result.add(current.toString());
                current = new StringBuilder();
            } else {
                current.append(c);
            }
        }
        result.add(current.toString());
        return result.toArray(new String[0]);
    }
}
