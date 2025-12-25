import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RandomUser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RandomUserScreen(),
    );
  }
}

class RandomUser {
  final String fullName;
  final String email;
  final String country;
  final String city;
  final String phone;
  final String avatar;

  RandomUser({
    required this.fullName,
    required this.email,
    required this.country,
    required this.city,
    required this.phone,
    required this.avatar,
  });

  factory RandomUser.fromJson(Map<String, dynamic> json) {
    final user = json["results"][0];
    return RandomUser(
      fullName:
          "${user["name"]["first"]} ${user["name"]["last"]}".trim(),
      email: user["email"],
      country: user["location"]["country"],
      city: user["location"]["city"],
      phone: user["phone"],
      avatar: user["picture"]["large"],
    );
  }
}

class RandomUserService {
  static const _url = "https://randomuser.me/api/";

  Future<RandomUser> fetchUser() async {
    try {
      final res = await http.get(Uri.parse(_url));
      if (res.statusCode != 200) {
        throw Exception("Ошибка сервера ${res.statusCode}");
      }
      final data = json.decode(res.body);
      return RandomUser.fromJson(data);
    } catch (e) {
      throw Exception("Не удалось получить данные: $e");
    }
  }
}

class RandomUserScreen extends StatefulWidget {
  const RandomUserScreen({super.key});

  @override
  State<RandomUserScreen> createState() => _RandomUserScreenState();
}

class _RandomUserScreenState extends State<RandomUserScreen> {
  final _service = RandomUserService();

  RandomUser? _user;
  String? _error;
  bool _loading = false;
  bool _hasGenerated = false;

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
      _hasGenerated = true;
    });

    try {
      final user = await _service.fetchUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _user = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1FA2FF), Color(0xFF12D8FA), Color(0xFFA6FFCB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Random User',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Случайный профиль с сервера RandomUser.me',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 32),

             
                ElevatedButton(
                  onPressed: _loading ? null : _loadUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Получить пользователя',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 28),

                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: _buildContent(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const CircularProgressIndicator(
        key: ValueKey("loading"),
        strokeWidth: 6,
        valueColor: AlwaysStoppedAnimation(Colors.white),
      );
    }

    if (_error != null) {
      return Card(
        key: const ValueKey("error"),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    if (_user != null) {
      final u = _user!;
      return Card(
        key: const ValueKey("user"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 14,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(u.avatar),
              ),
              const SizedBox(height: 16),
              Text(
                u.fullName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                u.email,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                "${u.country}, ${u.city}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                u.phone,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasGenerated) {
      return const Text(
        "Нажмите кнопку\nчтобы получить профиль",
        key: ValueKey("empty"),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 20),
      );
    }

    return const SizedBox.shrink();
  }
}