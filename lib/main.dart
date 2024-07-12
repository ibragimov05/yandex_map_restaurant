import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lesson_16/firebase_options.dart';
import 'package:lesson_16/logic/services/location_service.dart';
import 'package:lesson_16/ui/screens/map_screen/map_screen.dart';

import 'logic/map_cubit/map_cubit.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocationService.checkPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => MapCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? '/sign-in'
              : '/mapScreen',
          routes: {
            '/sign-in': (context) {
              return SignInScreen(
                providers: providers,
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.pushReplacementNamed(context, '/mapScreen');
                  }),
                ],
              );
            },
            '/mapScreen': (context) {
              return const MapScreen();
            },
          },
        ));
  }
}
