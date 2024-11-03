package ociserver;

import com.doubledimple.mfa.MfaStartApplication;
import com.doubledimple.mfa.task.SyncTaskService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;

@SpringBootTest(classes = {MfaStartApplication.class})
@Slf4j
@Transactional
class MfaStartApplicationTests {


    @Resource
    SyncTaskService syncTaskService;


    @Test
    public void testTask(){
        syncTaskService.checkAndSync();
    }

}
