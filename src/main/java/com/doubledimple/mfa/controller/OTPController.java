package com.doubledimple.mfa.controller;

import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.service.OTPKeyRepository;
import com.doubledimple.mfa.service.impl.OTPService;
import com.doubledimple.mfa.service.impl.QRCodeService;
import com.doubledimple.mfa.utils.GoogleAuthMigrationParser;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.hibernate.criterion.Example;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.URLEncoder;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.atomic.AtomicReference;


/**
 * @author doubleDimple
 * @date 2024:10:05日 01:00
 */
@Controller
@Slf4j
public class OTPController {

    String issuer = "mfa-start";
    String accountName = "user@example.com";

    @Autowired
    private OTPService otpService;

    @Autowired
    private QRCodeService qrCodeService;

    @Resource
    private OTPKeyRepository otpKeyRepository;

    // 显示主页
    @GetMapping("/")
    public String index(Model model) throws IOException, WriterException {
        List<OTPKey> otpKeys = otpService.getAllKeys();
        if (otpKeys.size() > 0){
            model.addAttribute("otpKeys", otpKeys);
        }
        return "index"; // 对应 index.html 文件
    }

    // 保存密钥
    @PostMapping("/save-secret")
    public String saveSecret(@RequestParam(value ="keyName", required = false) String keyName,
                             @RequestParam(value ="secretKey", required = false) String secretKey,
                             @RequestParam(value = "qrCode", required = false) MultipartFile qrCode) {
        AtomicReference<String> finalSecretKey = new AtomicReference<>(secretKey);
        List<Map<String, String>> accounts = new ArrayList<>();
        if(StringUtils.isEmpty(keyName)){
            keyName = System.currentTimeMillis()+"";
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
            log.info("qrCode text is: {}",qrContent);
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

                otpService.saveKey(new OTPKey(keyName, finalSecretKey.get()));

            } else if (qrContent.startsWith("otpauth-migration://")) {

                List<GoogleAuthMigrationParser.OtpParameters> otpParameters = GoogleAuthMigrationParser.parseUri(qrContent);

                for (GoogleAuthMigrationParser.OtpParameters account : otpParameters) {
                    if (log.isDebugEnabled()){
                        log.info("\nAccount:");
                        log.info("Name: " + account.getName());
                        log.info("Issuer: " + account.getIssuer());
                        log.info("Secret: " + account.getSecretInBase32());
                        log.info("");
                    }

                    OTPKey otpKey = new OTPKey();
                    otpKey.setKeyName(account.getName());
                    otpKey.setSecretKey(account.getSecretInBase32());
                    if (account.getIssuer() == null){
                        otpKey.setIssuer("mfa-start");
                    }else {
                        otpKey.setIssuer(account.getIssuer());
                    }
                    otpService.saveKey(otpKey);
                }
            }
        }else {
            otpService.saveKey(new OTPKey(keyName,secretKey));
        }
        log.info("result:{}",accounts);
        return "redirect:/";
    } catch (Exception e) {
        log.error("Error saving OTP key", e);
        return "redirect:/?error=" + URLEncoder.encode(e.getMessage());
    }
    }

    // 生成 OTP 码
    @GetMapping("/generate-otp")
    @ResponseBody
    public OtpResponse generateOtp(@RequestParam("secretKey") String secretKey) {
        String otpCode = otpService.generateOtpCode(secretKey);
        return new OtpResponse(otpCode);
    }

    @PostMapping("/delete-key")
    @ResponseBody
    public OtpResponse deleteKey(@RequestBody Map<String, String> payload) {
        String keyName = payload.get("keyName");
        if (keyName == null || keyName.isEmpty()) {
            return new OtpResponse("keyName is null");
        }
        otpService.deleteKey(keyName);
        return new OtpResponse("OK");
    }

    // 响应类
    public static class OtpResponse {
        private String otpCode;

        public OtpResponse(String otpCode) {
            this.otpCode = otpCode;
        }

        public String getOtpCode() {
            return otpCode;
        }

        public void setOtpCode(String otpCode) {
            this.otpCode = otpCode;
        }
    }

    @GetMapping("/export")
    public void exportToCSV(HttpServletResponse response) throws IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"otp_keys.csv\"");
        PrintWriter writer = response.getWriter();
        writer.println("ID,KeyName,SecretKey");

        List<OTPKey> otpKeys = otpService.getAllKeys();
        for (OTPKey otpKey : otpKeys) {
            writer.printf("%d,%s,%s%n", otpKey.getId(), otpKey.getKeyName(), otpKey.getSecretKey());
        }
        writer.flush();
    }
}
