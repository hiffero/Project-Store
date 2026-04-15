import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart'; //import jangan lupa 

class AuthService {
  static const String baseUrl = "http://192.168.9.57:3000";

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/products"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    return jsonDecode(response.body);
  }
}


