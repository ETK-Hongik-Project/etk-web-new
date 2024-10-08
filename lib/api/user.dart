import 'dart:convert';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class User {
  User({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
  });

  final int userId;
  final String name;
  final String username;
  final String email;

  factory User.from(Map<String, dynamic> data) {
    return User(
      userId: data['id'],
      name: data['name'],
      username: data['username'],
      email: data['email'],
    );
  }
}

Future<User> fetchUserDetails(BuildContext context) async {
  var logger = Logger();

  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/user'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  checkTokenValidation(context, response);

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    dynamic userData = jsonResponse['data'];

    logger.i(userData);

    return User.from(userData);
  } else {
    logger.e('Failed to fetch user details: ${response.statusCode}');
    throw Exception('Failed to load user');
  }
}

Future<void> join(
    String name, String username, String password, String email) async {
  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/join'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "name": name,
      "username": username,
      "password": password,
      "email": email,
    }),
  );

  if (response.statusCode == 201) {
    // 회원가입 성공
  } else if (response.statusCode == 400) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    var error = jsonResponse["message"];

    logger.e("Failed to create an account ($error)");
    throw Exception("$error");
  } else {
    logger.e('Failed to create an account : ${response.statusCode}');
    throw Exception('Failed to create an account');
  }
}
