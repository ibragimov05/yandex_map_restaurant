import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lesson_16/logic/map_cubit/map_cubit.dart';
import 'package:lesson_16/logic/services/location_service.dart';
import 'package:lesson_16/ui/screens/map_screen/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.checkPermissions();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => MapCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.black87),
        home: const MapScreen(),
      ),
    );
  }
}
