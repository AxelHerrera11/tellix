package com.tellix.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Habilita Virtual Threads de Java 21 para tareas asíncronas.
 * El servidor Tomcat ya los usa automáticamente vía spring.threads.virtual.enabled=true.
 * Este bean los activa también para @Async.
 */
@Configuration
@EnableAsync
public class VirtualThreadConfig {

    @Bean(name = "taskExecutor")
    public Executor virtualThreadExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }
}
