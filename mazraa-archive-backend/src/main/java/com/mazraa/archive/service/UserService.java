package com.mazraa.archive.service;

import com.mazraa.archive.dto.UserCreateRequest;
import com.mazraa.archive.dto.UserDTO;
import com.mazraa.archive.dto.UserUpdateRequest;
import com.mazraa.archive.dto.RegisterRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.List;

public interface UserService {
    UserDTO createUser(UserCreateRequest request, Long createdById);
    UserDTO updateUser(Long id, UserUpdateRequest request, Long updatedById);
    UserDTO getUser(Long id);
    UserDTO getUserByUsername(String username);
    UserDTO getUserByEmail(String email);
    Page<UserDTO> searchUsers(String searchTerm, String role, String status, LocalDate startDate, LocalDate endDate, Pageable pageable);
    void deleteUser(Long id);
    void changePassword(Long id, String currentPassword, String newPassword);
    void toggleUserStatus(Long id, boolean enabled);
    UserDTO register(RegisterRequest request);
    List<UserDTO> getAllUsers();
    void updateLastLogin(String email);
} 