package com.mazraa.archive;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class ArchiveManagementApplication {
    public static void main(String[] args) {
        SpringApplication.run(ArchiveManagementApplication.class, args);
    }
} 