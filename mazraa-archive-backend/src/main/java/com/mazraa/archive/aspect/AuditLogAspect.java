package com.mazraa.archive.aspect;

import com.mazraa.archive.security.UserDetailsImpl;
import com.mazraa.archive.service.AuditLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.UserDTO;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.UserRepository;

@Aspect
@Component
@RequiredArgsConstructor
public class AuditLogAspect {

    private final AuditLogService auditLogService;
    private final UserRepository userRepository;

    @Around("@annotation(auditLog)")
    public Object logAudit(ProceedingJoinPoint joinPoint, AuditLog auditLog) throws Throwable {
        Object result = joinPoint.proceed();

        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated()) {
                HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
                String ipAddress = request.getRemoteAddr();

                Object principal = authentication.getPrincipal();
                Long userId = null;

                if (principal instanceof UserDetailsImpl) {
                    userId = ((UserDetailsImpl) principal).getId();
                } else if (principal instanceof org.springframework.security.core.userdetails.User) {
                    String username = ((org.springframework.security.core.userdetails.User) principal).getUsername();
                    userId = userRepository.findByUsername(username)
                                           .map(User::getId)
                                           .orElse(null);
                }

                if (userId != null) {
                    // Improved entity ID extraction
                    Long entityId = extractEntityId(joinPoint, auditLog, result);
                    
                    auditLogService.logAction(
                        auditLog.action(),
                        auditLog.entityType(),
                        entityId,
                        auditLog.details(),
                        ipAddress,
                        userId
                    );
                } else {
                    System.err.println("[AuditLogAspect] Warning: could not resolve userId for audit");
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // Don't break business logic
        }

        return result;
    }

    private Long extractEntityId(ProceedingJoinPoint joinPoint, AuditLog auditLog, Object result) {
        // If the method returns a User entity, get its ID
        if (result instanceof ResponseEntity) {
            Object body = ((ResponseEntity<?>) result).getBody();
            if (body instanceof UserDTO userDto) {
                return userDto.getId();
            }
        }
        
        // Check method arguments for ID
        for (Object arg : joinPoint.getArgs()) {
            if (arg instanceof Long) {
                return (Long) arg;
            } else if (arg instanceof String && "username".equals(auditLog.entityType())) {
                // If the argument is username and entityType is "user", look up the ID
                return userRepository.findByUsername((String) arg)
                                    .map(User::getId)
                                    .orElse(null);
            }
        }
        
        return null;
    }
}