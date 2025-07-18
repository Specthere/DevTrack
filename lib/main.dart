import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracedev/controller/auth_controller.dart';
import 'package:tracedev/controller/ganti_password_controller.dart';
import 'package:tracedev/controller/laporan_controller.dart';
import 'package:tracedev/controller/mandor_project_controller.dart';
import 'package:tracedev/controller/mandor_project_project_controller.dart';
import 'package:tracedev/controller/project_controller.dart';
import 'package:tracedev/controller/riwayat_controller.dart';
import 'package:tracedev/controller/users_controller.dart';
import 'package:tracedev/view/dashboard_dev.dart';
import 'package:tracedev/view/edit_password.dart';
import 'package:tracedev/view/laporan_page.dart';
import 'package:tracedev/view/login_screen.dart';
import 'package:tracedev/view/main_page.dart';
import 'package:tracedev/view/mandor_dashboard.dart';
import 'package:tracedev/view/tambah_mandor.dart';
import 'package:tracedev/view/tambah_projek.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectController()),
        ChangeNotifierProvider(create: (_) => UsersController()),
        ChangeNotifierProvider(create: (_) => MandorProjectController()),
        ChangeNotifierProvider(create: (_) => MandorProjectProjectController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LaporanController()),
        ChangeNotifierProvider(create: (_) => RiwayatController()),
        ChangeNotifierProvider(create: (_) => GantiPasswordController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: {
        '/home': (context) => const MainPage(),
        '/tambah-projek': (context) => const TambahProjek(),
        '/tambah-mandor': (context) => const TambahMandor(),
        '/mandor': (context) => const MandorDashboard(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
