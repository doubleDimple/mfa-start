package com.doubledimple.mfa.utils;

import com.google.authenticator.proto.MigrationProtos;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base32;

import java.net.URLDecoder;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

/**
 * @author doubleDimple
 * @date 2024:10:28日 23:02
 */
@Slf4j
public class GoogleAuthDataParser {
    private List<OtpParameters> otpParameters = new ArrayList<>();

    @Data
    public static class OtpParameters {
        private byte[] secret;
        private String name;
        private String issuer;
        private int algorithm = 1;  // 默认 SHA1
        private int digits = 6;     // 默认 6位
        private int type = 2;       // 默认 TOTP

        public String getSecretKey() {
            return new Base32().encodeToString(secret).replaceAll("=", "");
        }
    }

    public static List<OtpParameters> parseData(String migrationUri) {
        try {
            // 1. 提取 data 参数
            String data = migrationUri.substring(migrationUri.indexOf("data=") + 5);

            // 2. URL 解码
            String urlDecoded = URLDecoder.decode(data, StandardCharsets.UTF_8.toString());

            // 3. Base64 解码
            byte[] decoded = Base64.getDecoder().decode(urlDecoded);

            // 4. 解析 protobuf 格式
            ByteBuffer buffer = ByteBuffer.wrap(decoded);
            List<OtpParameters> accounts = new ArrayList<>();

            // 跳过版本和批次大小
            readField(buffer);

            // 读取所有账号
            while (buffer.hasRemaining()) {
                int tag = buffer.get() & 0xFF;
                if (tag == 0x0A) {  // OTP 参数的标记
                    accounts.add(parseOtpParameters(buffer));
                } else {
                    skipField(buffer);
                }
            }

            return accounts;
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse migration data", e);
        }
    }

    private static OtpParameters parseOtpParameters(ByteBuffer buffer) {
        int length = readVarint(buffer);
        byte[] data = new byte[length];
        buffer.get(data);

        ByteBuffer paramBuffer = ByteBuffer.wrap(data);
        OtpParameters params = new OtpParameters();

        while (paramBuffer.hasRemaining()) {
            int tag = paramBuffer.get() & 0xFF;
            int fieldNum = tag >> 3;

            switch (fieldNum) {
                case 0:
                    break;
                case 6:
                    break;
                case 1: // secret
                    length = readVarint(paramBuffer);
                    byte[] secret = new byte[length];
                    paramBuffer.get(secret);
                    params.setSecret(secret);
                    break;

                case 2: // name
                    length = readVarint(paramBuffer);
                    byte[] nameBytes = new byte[length];
                    paramBuffer.get(nameBytes);
                    params.setName(new String(nameBytes, StandardCharsets.UTF_8));
                    break;

                case 3: // issuer
                    length = readVarint(paramBuffer);
                    byte[] issuerBytes = new byte[length];
                    paramBuffer.get(issuerBytes);
                    params.setIssuer(new String(issuerBytes, StandardCharsets.UTF_8));
                    break;

                default:
                    skipField(paramBuffer);
                    break;
            }
        }

        return params;
    }

    private static void skipField(ByteBuffer buffer) {
        int length = readVarint(buffer);
        buffer.position(buffer.position() + length);
    }

    private static void readField(ByteBuffer buffer) {
        int tag = buffer.get() & 0xFF;
        skipField(buffer);
    }

    private static int readVarint(ByteBuffer buffer) {
        int value = 0;
        int shift = 0;
        while (true) {
            byte b = buffer.get();
            value |= (b & 0x7F) << shift;
            if ((b & 0x80) == 0) {
                break;
            }
            shift += 7;
        }
        return value;
    }

    public static void main(String[] args) {
        String migrationUri = "otpauth-migration://offline?data=CjcKEP4eovjWG9YYu7W1FiKPyCISETEwMDQ5NDA3MjVAcXEuY29tGgplMDA0OTQwNzI1IAEoATACCjoKEMMomMAYRQdnMK/xhithGbsSE2xvdmVsZS5jbkBnbWFpbC5jb20aC2Zlcm5hbmRvdGJsIAEoATACCi8KFE2ovHvrdx2A3JFVcUxSXoUsBdAKEgZsb3ZlbGUaCVNwYWNlc2hpcCABKAEwAgo2Cgqx5lCaKX6nJvW6EhVtaXNub21tYXNpY0BnbWFpbC5jb20aC0JpbmFuY2UuY29tIAEoATACCkAKEEo/XpH3OwbB9c83ghKAcr4SF3Jlbnl1YW54aW4wMDFAZ21haWwuY29tGg1ld2FyZG9laHJsZWluIAEoATACCiYKFKNEo83H/I73mqAW8UDECjLthT4MEghyZWRvdHBheSABKAEwAgojChQxp5GWbjM1ghEebGcHRgPnpKkn1BIFdGhQYXkgASgBMAIKJAoKE6gixtdRrzFUuhIQc21zLWFjdGl2YXRlLm9yZyABKAEwAgoyChCwSapRadYxa9JSgjStuEuxEg5tb2thbmRlckBiay5ydRoIbW9rYW5kZXIgASgBMAIKNgoQuZYewwSl8gKRNsQ96ZB8gBISb2JqYm95QGhvdG1haWwuY29tGghtb2thbmRlciABKAEwAhACGAcgAA==";

        List<OtpParameters> accounts = parseData(migrationUri);

        for (OtpParameters account : accounts) {
            System.out.println("\nAccount:");
            System.out.println("Name: " + account.getName());
            System.out.println("Issuer: " + account.getIssuer());
            System.out.println("Secret: " + account.getSecretKey());
            System.out.println("Type: TOTP");
            System.out.println("Algorithm: SHA1");
            System.out.println("Digits: 6");
        }
    }
}
