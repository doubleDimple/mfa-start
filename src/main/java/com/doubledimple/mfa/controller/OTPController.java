package com.doubledimple.mfa.controller;

import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.service.impl.OTPService;
import com.doubledimple.mfa.service.impl.QRCodeService;
import com.google.zxing.WriterException;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author doubleDimple
 * @date 2024:10:05日 01:00
 */
@Controller
public class OTPController {

    String issuer = "mfa-start";
    String accountName = "user@example.com";

    @Autowired
    private OTPService otpService;

    @Autowired
    private QRCodeService qrCodeService;

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
    public String saveSecret(@RequestParam("keyName") String keyName, @RequestParam("secretKey") String secretKey) {
        otpService.saveKey(new OTPKey(keyName, secretKey));
        return "redirect:/";
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
}
