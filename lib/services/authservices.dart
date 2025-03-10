import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000/api';
  final storage = FlutterSecureStorage();

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> languages,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/agent/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'languages': languages,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Store token and user data
        await _saveAuthData(responseData);
        return {'success': true, 'user': responseData['user']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Login existing user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/agent/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Store token and user data
        await _saveAuthData(responseData);
        return {'success': true, 'user': responseData['user']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/agent/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': responseData['user']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to get profile'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    List<String>? languages,
  }) async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (languages != null) updateData['languages'] = languages;

      final response = await http.put(
        Uri.parse('$baseUrl/auth/agent/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Update stored user data
        await _updateStoredUserData(responseData['user']);
        return {'success': true, 'user': responseData['user']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to update profile'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Forgot password - request OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/agent/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/agent/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to reset password'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        return true; // Already logged out
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/agent/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear stored data regardless of server response
      await _clearAuthData();

      return true;
    } catch (e) {
      // Still clear local data even if server request fails
      await _clearAuthData();
      return true;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData == null) return null;

    return json.decode(userData);
  }

  // Private methods
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final token = data['user']['token'];
    if (token != null) {
      await storage.write(key: 'token', value: token);

      // Store user data without token in shared preferences
      final userData = Map<String, dynamic>.from(data['user']);
      userData.remove('token'); // Don't store token in shared prefs

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(userData));
    }
  }

  Future<void> _updateStoredUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(userData));
  }

  Future<void> _clearAuthData() async {
    await storage.delete(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
