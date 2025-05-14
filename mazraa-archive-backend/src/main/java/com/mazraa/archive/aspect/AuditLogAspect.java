package com.mazraa.archive.aspect;

import com.mazraa.archive.security.CustomUserDetails;
import com.mazraa.archive.service.AuditLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import com.mazraa.archive.annotation.AuditLog;

@Aspect
@Component
@RequiredArgsConstructor
public class AuditLogAspect {

    private final AuditLogService auditLogService;

    @Around("@annotation(auditLog)")
    public Object logAudit(ProceedingJoinPoint joinPoint, AuditLog auditLog) throws Throwable {
        Object result = joinPoint.proceed();

        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated()) {
                HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
                String ipAddress = request.getRemoteAddr();
                Long userId = ((CustomUserDetails) authentication.getPrincipal()).getId();

                String entityType = auditLog.entityType();
                Long entityId = extractEntityId(joinPoint.getArgs());
                String details = auditLog.details();

                auditLogService.logAction(auditLog.action(), entityType, entityId, details, ipAddress, userId);
            }
        } catch (Exception e) {
            // Log the error but don't interrupt the main flow
            e.printStackTrace();
        }

        return result;
    }

    private Long extractEntityId(Object[] args) {
        for (Object arg : args) {
            if (arg instanceof Long) {
                return (Long) arg;
            }
        }
        return null;
    }
} 