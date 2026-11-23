import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Alamat backend CukurIn yang berjalan di komputer lokal.
  static const String baseUrl = 'http://localhost:5000/api';

  // Nama kunci untuk menyimpan JWT.
  static const String _tokenKey = 'token';

  // Menyimpan token setelah login berhasil.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Mengambil token yang tersimpan.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Menghapus token ketika logout.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Menyiapkan header untuk setiap request.
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Mengolah respons dari backend.
  static dynamic _handleResponse(http.Response response) {
    final dynamic data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    final message = data is Map
        ? data['message'] ?? 'Terjadi kesalahan pada server'
        : 'Terjadi kesalahan pada server';

    throw Exception(message);
  }

  // Mengirim request GET.
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // Mengirim request POST.
  static Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Mengirim request PUT.
  static Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Mengirim request PATCH.
  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Mengirim request DELETE.
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }


  // Login pengguna.
  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final response = await post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    // Simpan token jika login berhasil.
    if (response is Map && response['token'] != null) {
      await saveToken(response['token']);
    }

    return response;
  }
}
