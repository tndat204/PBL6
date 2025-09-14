package com.pbl6.authservice.dto;

import lombok.Data;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Data
public class UserDTO {
    UUID id;
    String username;
    String password;
    String email;
    String phone;
    String address;
    Date birthDate;
    boolean isEnabled;
    private List<RoleDTO> roles; // danh sách role kèm permission nếu cần
}