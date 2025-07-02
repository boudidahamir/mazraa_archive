import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../screens/home_screen.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/models/user.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _secureStorage = const FlutterSecureStorage();
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    final apiService = context.read<ApiService>();
    final secureStorage = const FlutterSecureStorage();

    try {
      if (isOnline) {
        await apiService.login(
          _usernameController.text,
          _passwordController.text,
        );

        await secureStorage.write(key: 'username', value: _usernameController.text);
        await secureStorage.write(key: 'password', value: _passwordController.text);

        // Fetch and save user profile
        final localStorageService = LocalStorageService();
        final user = await apiService.getCurrentUserProfile();
        print('Fetched user profile: ${user.toJson()}');
        await localStorageService.saveUser(user);
        if (user.id != null) {
          await localStorageService.saveCurrentUserId(user.id!);
          print('Saved current user ID: ${user.id}');
        } else {
          throw Exception('User ID is null');
        }
      } else {
        final savedUsername = await secureStorage.read(key: 'username');
        final savedPassword = await secureStorage.read(key: 'password');

        if (_usernameController.text != savedUsername || _passwordController.text != savedPassword) {
          throw Exception('Offline login failed');
        }
        
        // For offline login, try to get the saved user profile
        final localStorageService = LocalStorageService();
        final savedUser = await localStorageService.getCurrentUser();
        if (savedUser == null) {
          throw Exception('No saved user profile found');
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir votre nom d\'utilisateur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir votre mot de passe';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
} 