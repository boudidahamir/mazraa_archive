package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.UserCreateRequest;
import com.mazraa.archive.dto.UserDTO;
import com.mazraa.archive.dto.UserUpdateRequest;
import com.mazraa.archive.dto.RegisterRequest;
import com.mazraa.archive.exception.ResourceAlreadyExistsException;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.UserRepository;
import com.mazraa.archive.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public UserDTO register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ResourceAlreadyExistsException("Username already exists");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException("Email already exists");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setFullName(request.getFullName());
        user.setRole(User.UserRole.USER);
        user.setRoles("ROLE_" + user.getRole().name());
        user.setEnabled(true);
        user.setActive(true);
        
        return convertToDTO(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserDTO createUser(UserCreateRequest request, Long createdById) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException(
                    "User with email " + request.getEmail() + " already exists");
        }

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ResourceAlreadyExistsException(
                    "User with username " + request.getUsername() + " already exists");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setUsername(request.getUsername());
        user.setFullName(request.getFullName());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(User.UserRole.valueOf(request.getRole()));
        user.setEnabled(request.getEnabled());
        user.setRoles("ROLE_" + request.getRole());
        user.setActive(true);
        
        if (createdById != null) {
            userRepository.findById(createdById).ifPresent(user::setCreatedBy);
        }

        return convertToDTO(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserDTO updateUser(Long id, UserUpdateRequest request, Long updatedById) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!user.getEmail().equals(request.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException(
                    "User with email " + request.getEmail() + " already exists");
        }

        user.setEmail(request.getEmail());
        user.setFullName(request.getFullName());
        user.setRole(User.UserRole.valueOf(request.getRole()));
        user.setEnabled(request.getEnabled());

        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        if (updatedById != null) {
            userRepository.findById(updatedById).ifPresent(user::setUpdatedBy);
        }

        return convertToDTO(userRepository.save(user));
    }

    @Override
    public UserDTO getUser(Long id) {
        return convertToDTO(userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found")));
    }

    @Override
    public UserDTO getUserByUsername(String username) {
        return convertToDTO(userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found")));
    }

    @Override
    public UserDTO getUserByEmail(String email) {
        return convertToDTO(userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found")));
    }

    @Override
    public Page<UserDTO> searchUsers(String searchTerm, String role, String status, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        Specification<User> spec = Specification.where(null);

        // Add search term filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            spec = spec.and((root, query, cb) -> {
                String pattern = "%" + searchTerm.toLowerCase() + "%";
                return cb.or(
                    cb.like(cb.lower(root.get("fullName")), pattern),
                    cb.like(cb.lower(root.get("email")), pattern),
                    cb.like(cb.lower(root.get("username")), pattern)
                );
            });
        }

        // Add role filter
        if (role != null && !role.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("role"), User.UserRole.valueOf(role))
            );
        }

        // Add status filter
        if (status != null && !status.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("enabled"), status.equals("active"))
            );
        }

        // Add date range filter
        if (startDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), startDate.atStartOfDay())
            );
        }
        if (endDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), endDate.atTime(LocalTime.MAX))
            );
        }

        return ((JpaSpecificationExecutor<User>)userRepository).findAll(spec, pageable).map(this::convertToDTO);
    }

    @Override
    @Transactional
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        userRepository.delete(user);
    }

    @Override
    @Transactional
    public void changePassword(Long id, String currentPassword, String newPassword) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    @Override
    @Transactional
    public void toggleUserStatus(Long id, boolean enabled) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(enabled);
        userRepository.save(user);
    }

    @Override
    public List<UserDTO> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void updateLastLogin(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    private UserDTO convertToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setUsername(user.getUsername());
        dto.setFullName(user.getFullName());
        dto.setRole(user.getRole().name());
        dto.setEnabled(user.isEnabled());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        dto.setPassword(user.getPassword());

        if (user.getCreatedBy() != null) {
            dto.setCreatedById(user.getCreatedBy().getId());
            dto.setCreatedByName(user.getCreatedBy().getFullName());
        }
        
        if (user.getUpdatedBy() != null) {
            dto.setUpdatedById(user.getUpdatedBy().getId());
            dto.setUpdatedByName(user.getUpdatedBy().getFullName());
        }
        
        return dto;
    }
} 