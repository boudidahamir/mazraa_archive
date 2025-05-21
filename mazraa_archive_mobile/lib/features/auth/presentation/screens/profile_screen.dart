import 'package:flutter/material.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _localStorageService.getCurrentUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Aucun utilisateur connecté.'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Nom complet', _user!.fullName),
            _buildRow('Nom d\'utilisateur', _user!.username),
            _buildRow('Email', _user!.email),
            _buildRow('Rôle', _user!.role.name.toUpperCase()),
            _buildRow('Compte actif', _user!.enabled ? 'Oui' : 'Non'),
            if (_user!.deviceId != null) _buildRow('ID Appareil', _user!.deviceId!),
            _buildRow('Créé le', _user!.createdAt.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
