import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/features/detail/controller/detail_provider.dart';
import 'package:rick_and_morty/features/favorite/controller/favorite_provider.dart';
import 'package:rick_and_morty/features/home/controller/characters_list_provider.dart';
import 'package:rick_and_morty/util/constants.dart';
import 'package:rick_and_morty/features/main_bottom_navigation/view/main_bottom_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(charactersBoxLocalDb);
  await Hive.openBox(favoriteBoxLocalDb);
  await Hive.openBox(editedCharactersBoxLocalDb);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CharactersListProvider()),
        ChangeNotifierProvider(create: (context) => DetailProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: color1,
          surface: color1,
          primary: color1,
        ),
        highlightColor: color2,
        splashColor: color2,
      ),
      home: const MainBottomNavigation(),
      debugShowCheckedModeBanner: debugMode,
    );
  }
}
