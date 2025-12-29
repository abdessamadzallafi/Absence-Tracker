import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api_client.dart';
import '../domain/auth_repo.dart';
import '../domain/professor.dart';
import 'package:dio/dio.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  Professor? _user;

  AuthRepoImpl({ApiClient? apiClient, FlutterSecureStorage? storage})
      : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Professor?> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final userMap = data['user'];

        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
        }
        
        // Save user data securely or in shared preferences if needed, 
        // for now just keeping in memory and potentially secure storage for persistence
        if (userMap != null) {
           _user = Professor.fromMap(userMap);
           await _storage.write(key: 'user_data', value: jsonEncode(_user!.toMap()));
        }

        return _user;
      }
    } catch (e) {
      print('Login error: $e');
      if (e is DioException) {
         // handle specific errors
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _user = null;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }

  @override
  Future<Professor?> currentUser() async {
    if (_user != null) return _user;
    
    // Try to restore from storage
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      try {
        _user = Professor.fromMap(jsonDecode(userData));
        return _user;
      } catch (e) {
        return null;
      }
    }
    
    // Optionally verify token validity with /auth/me
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
       try {
         final response = await _apiClient.get('/auth/me');
         if (response.statusCode == 200) {
            _user = Professor.fromMap(response.data);
            await _storage.write(key: 'user_data', value: jsonEncode(_user!.toMap()));
            return _user;
         }
       } catch (e) {
         // Token might be expired
         await logout();
       }
    }

    return null;
  }
}
