import 'package:assets_inventory_app_ghum/common/utils/theme/app_bar_theme.dart';
import 'package:assets_inventory_app_ghum/common/utils/theme/input_decoration_theme.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/features/home/screens/home.dart';
import 'package:assets_inventory_app_ghum/firebase_options.dart';
import 'package:assets_inventory_app_ghum/services/controller/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    var user = ref.read(authControllerProvider.notifier).getSignedInUser();
    if (user != null) {
      var userModel = await ref
          .read(authControllerProvider.notifier)
          .getUserData(user.uid, context);

      ref.read(userProvider.notifier).update((state) => userModel);
    }
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assets inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: GAppBarTheme.appBarTheme,
          inputDecorationTheme: GInputDecorationTheme.inputDecorationTheme),
      home: const Home(),
    );
  }
}
