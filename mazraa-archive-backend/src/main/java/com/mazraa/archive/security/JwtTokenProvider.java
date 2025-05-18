package com.mazraa.archive.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.List;

@Slf4j
@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private int jwtExpirationInMs;

    private Key getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateToken(Authentication authentication) {
        try {
            Object principal = authentication.getPrincipal();
    
            String username;
            List<String> roles;
            Long userId;
    
            if (principal instanceof UserDetailsImpl userDetails) {
                username = userDetails.getUsername();
                roles = userDetails.getAuthorities().stream()
                        .map(GrantedAuthority::getAuthority)
                        .toList();
                userId = userDetails.getId();
            } else {
                throw new IllegalStateException("Unsupported principal type: " + principal.getClass());
            }
    
            Date now = new Date();
            Date expiryDate = new Date(now.getTime() + jwtExpirationInMs);
            log.info("[JWT] Creating token for: " + username + " with roles: " + roles);

            return Jwts.builder()
                    .setSubject(username)
                    .claim("roles", roles)
                    .claim("userId", userId)
                    .setIssuedAt(now)
                    .setExpiration(expiryDate)
                    .signWith(getSigningKey())
                    .compact();
    
        } catch (Exception ex) {
            log.error("JWT generation failed", ex);
            throw new RuntimeException("JWT generation failed", ex);
        }
    }
    
    public String getUsernameFromJWT(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();

        return claims.getSubject();
    }

    public boolean validateToken(String authToken) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(authToken);
            return true;
        } catch (SecurityException ex) {
            log.error("Invalid JWT signature");
        } catch (MalformedJwtException ex) {
            log.error("Invalid JWT token");
        } catch (ExpiredJwtException ex) {
            log.error("Expired JWT token");
        } catch (UnsupportedJwtException ex) {
            log.error("Unsupported JWT token");
        } catch (IllegalArgumentException ex) {
            log.error("JWT claims string is empty");
        }
        return false;
    }

    public List<String> getRolesFromJWT(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    
        Object rawRoles = claims.get("roles");
    
        if (rawRoles instanceof List<?> list) {
            return list.stream()
                .filter(String.class::isInstance)
                .map(String.class::cast)
                .toList();
        }
    
        // fallback to empty list
        log.warn("[JWT] Roles claim missing or not a list: {}", rawRoles);
        return List.of();
    }
    
    
    
}