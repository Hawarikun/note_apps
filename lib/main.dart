import 'package:flutter/material.dart';
import 'package:note_apps/data/shared_preferences.dart';
import 'package:note_apps/page/auth/login.dart';
import 'package:note_apps/page/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /// Males Nyieun GoRoutes.
    return FutureBuilder<String?>(
      future: LocalPrefsRepository().getToken(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Jika masih menunggu hasil, tampilkan loading atau indikator lainnya.
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            // Jika ada error saat mengambil token, tampilkan pesan error.
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              ),
            );
          } else {
            // Jika token berhasil didapatkan, arahkan ke halaman yang sesuai.
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme:
                    const ColorScheme.light(primary: Colors.deepPurple),
                useMaterial3: true,
              ),
              home:
                  snapshot.data != null ? const HomePage() : const LoginPage(),
            );
          }
        }
      },
    );
  }
}
