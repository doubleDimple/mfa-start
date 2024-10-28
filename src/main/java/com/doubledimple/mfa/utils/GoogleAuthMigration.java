package com.doubledimple.mfa.utils;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

/**
 * @author doubleDimple
 * @date 2024:10:28日 21:39
 */
@Slf4j
public class GoogleAuthMigration {
    public static class MigrationPayload {
        private final List<OtpParameters> otpParameters;

        private MigrationPayload(byte[] data) throws Exception {
            // 添加详细的日志
            log.debug("Parsing migration payload, data length: {}", data.length);

            ByteBuffer buffer = ByteBuffer.wrap(data);
            buffer.order(ByteOrder.BIG_ENDIAN);

            // 读取头部信息
            if (buffer.remaining() < 2) {
                throw new IllegalArgumentException("Data too short for header");
            }

            // 读取版本号
            int version = buffer.getShort() & 0xffff;
            log.debug("Version: {}", version);

            otpParameters = new ArrayList<>();

            // 确保还有数据可读
            while (buffer.remaining() > 0) {
                try {
                    otpParameters.add(new OtpParameters(buffer));
                } catch (Exception e) {
                    log.error("Error parsing OTP parameters", e);
                    break;
                }
            }

            if (otpParameters.isEmpty()) {
                throw new IllegalArgumentException("No valid OTP parameters found");
            }
        }

        public List<OtpParameters> getOtpParameters() {
            return otpParameters;
        }
    }

    @Data
    public static class OtpParameters {
        private final String name;
        private final String issuer;
        private final byte[] secret;

        private OtpParameters(ByteBuffer buffer) throws Exception {
            // 读取密钥
            if (buffer.remaining() < 1) {
                throw new IllegalArgumentException("No data for secret length");
            }
            int secretLength = buffer.get() & 0xff;
            if (buffer.remaining() < secretLength) {
                throw new IllegalArgumentException("Not enough data for secret");
            }
            secret = new byte[secretLength];
            buffer.get(secret);

            // 读取名称
            if (buffer.remaining() < 1) {
                throw new IllegalArgumentException("No data for name length");
            }
            int nameLength = buffer.get() & 0xff;
            if (buffer.remaining() < nameLength) {
                throw new IllegalArgumentException("Not enough data for name");
            }
            byte[] nameBytes = new byte[nameLength];
            buffer.get(nameBytes);
            name = new String(nameBytes, StandardCharsets.UTF_8);

            // 读取发行者
            if (buffer.remaining() < 1) {
                throw new IllegalArgumentException("No data for issuer length");
            }
            int issuerLength = buffer.get() & 0xff;
            if (buffer.remaining() < issuerLength) {
                throw new IllegalArgumentException("Not enough data for issuer");
            }
            byte[] issuerBytes = new byte[issuerLength];
            buffer.get(issuerBytes);
            issuer = new String(issuerBytes, StandardCharsets.UTF_8);

            // 跳过剩余字段
            if (buffer.remaining() >= 4) {
                buffer.position(buffer.position() + 4);
            }
        }

        // Getters remain the same
    }

    public static MigrationPayload parseMigrationPayload(String qrContent) throws Exception {
        // 移除可能的空白字符
        qrContent = qrContent.trim();

        try {
            // 先尝试标准 Base64
            byte[] data = Base64.getDecoder().decode(qrContent);
            return new MigrationPayload(data);
        } catch (IllegalArgumentException e) {
            // 如果失败，尝试 URL 安全的 Base64
            return new MigrationPayload(Base64.getUrlDecoder().decode(qrContent));
        }
    }
}
