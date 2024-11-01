package com.doubledimple.mfa.service.impl;


import com.doubledimple.mfa.controller.OTPController;
import com.doubledimple.mfa.entity.OTPKey;
import com.doubledimple.mfa.response.OtpResponse;
import com.doubledimple.mfa.service.OTPKeyRepository;
import com.doubledimple.mfa.utils.TOTPUtils;
import com.google.zxing.WriterException;
import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorConfig;
import com.warrenstrange.googleauth.ICredentialRepository;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base32;
import org.apache.commons.codec.binary.Hex;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import javax.persistence.criteria.Predicate;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @author doubleDimple
 * @date 2024:10:05日 13:01
 */
@Service
@Slf4j
public class OTPService {

    String issuer = "mfa-start";
    String accountName = "user@example.com";

    @Autowired
    private OTPKeyRepository otpKeyRepository;

    @Autowired
    private QRCodeService qrCodeService;

    @Resource
    private GoogleAuthService googleAuthService;

    @Resource
    private GoogleAuthenticatorDef googleAuthenticatorDef;


    public List<OTPKey> getAllKeys() {
        return otpKeyRepository.findAll();
    }

    @Transactional
    public void saveKey(OTPKey otpKey) {

        OTPKey otpKeyDb = otpKeyRepository.queryOTPKeyByKeyName(otpKey.getKeyName());
        String secretKey = otpKey.getSecretKey();
        String otpAuthUri = String.format("otpauth://totp/%s:%s?secret=%s&issuer=%s",
                issuer, accountName, secretKey, issuer);
        try {
            String qrCode = qrCodeService.generateQRCodeImage(otpAuthUri);
            otpKey.setQrCode(qrCode);
        } catch (WriterException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        if (null != otpKeyDb){
            otpKey.setId(otpKeyDb.getId());
        }
        otpKeyRepository.save(otpKey);
    }

    public String generateOtpCode(String secretKey) {
        return googleAuthenticatorDef.generateCode(secretKey);
    }

    @Transactional
    public void deleteKey(String keyName) {
        otpKeyRepository.deleteByKeyName(keyName);
    }


    public Page<OTPKey> getPagedKeys(String searchTerm, Pageable pageable) {
        Specification<OTPKey> spec = (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (searchTerm != null && !searchTerm.isEmpty()) {
                predicates.add(criteriaBuilder.like(criteriaBuilder.lower(root.get("keyName")), "%" + searchTerm.toLowerCase() + "%"));
            }
            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
        return otpKeyRepository.findAll(spec, pageable);
    }

    @Transactional
    public void saveListKey(List<OTPKey> otpKey) {
        otpKeyRepository.saveAll(otpKey);
    }

    public List<OtpResponse> generateOtpBatch(List<String> secretKeys) {
        List<OtpResponse> otpResponses = new ArrayList<>(secretKeys.size());
        for (String secretKey : secretKeys) {
            OtpResponse response = new OtpResponse();
            String code = generateOtpCode(secretKey);
            response.setOtpCode(code);
            response.setSecretKey(secretKey);
            otpResponses.add(response);
        }
        return otpResponses;
    }
}
