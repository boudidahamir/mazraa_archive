package com.mazraa.archive;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@SpringBootApplication
@EnableJpaAuditing
public class ArchiveManagementApplication {
    public static void main(String[] args) {
        SpringApplication.run(ArchiveManagementApplication.class, args);
        String rawPassword = "admin";
        String encoded = new BCryptPasswordEncoder().encode(rawPassword);
        System.out.println("💡 Password in DB = " + encoded);
    }
} 