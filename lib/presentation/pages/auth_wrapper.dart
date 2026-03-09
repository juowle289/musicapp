import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/datas/providers/loved_provider.dart';
import 'package:musicapp/presentation/pages/login_page.dart';
import 'package:musicapp/presentation/pages/home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasLoadedLovedSongs = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Load loved songs when user is authenticated
        if (authProvider.isAuthenticated &&
            authProvider.userEmail != null &&
            !_hasLoadedLovedSongs) {
          _hasLoadedLovedSongs = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LovedProvider>().loadLovedSongs(
              authProvider.userEmail,
            );
          });
        }

        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
