import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),
        ProxyProvider2<ApiService, LocalStorageService, SyncService>(
          update: (_, apiService, localStorage, __) =>
              SyncService(apiService, localStorage),
        ),
      ],
      child: MaterialApp(
        title: 'Mazraa Archive',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
