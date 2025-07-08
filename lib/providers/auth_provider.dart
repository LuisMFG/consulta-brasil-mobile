import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
  );
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular chamada de API
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email e senha são obrigatórios');
      }

      if (!email.contains('@')) {
        throw Exception('Email inválido');
      }

      if (password.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }

      _user = User(
        id: '1',
        email: email,
        name: 'Usuário',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular chamada de API
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email e senha são obrigatórios');
      }

      if (!email.contains('@')) {
        throw Exception('Email inválido');
      }

      if (password.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }

      _user = User(
        id: '1',
        email: email,
        name: 'Usuário',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}