import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/provider/FavouriteProvider.dart';
import 'package:movie_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
  });

  testWidgets('HomeScreen has title', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
    final titleFinder = find.text('FILM FAN');
    expect(titleFinder, findsOneWidget);
  });
  //test if property loading is true
  testWidgets("test if initial values are correct", (widgetTester) async{
    final widget = buildTestableWidget(const HomeScreen());
    await widgetTester.pumpWidget(widget);
    final state = widgetTester.state<HomeScreenState>(find.byType(HomeScreen));
    expect(state.isLoadingMovieList, true);
    expect(state.movieList, []);
  });

  testWidgets("test if initially loading indicator is displayed", (tester) async {
    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
    if(Platform.isIOS) {
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    }else{
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }
    final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
    expect(loadingIndicatorFinder, findsOneWidget);
  });

  //test if getMovieList is called
  testWidgets("test if getMovieList is called", (tester) async {
    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
    final state = tester.state<HomeScreenState>(find.byType(HomeScreen));
    expect(state.loadMovieList, isNotNull);
  });

}

Widget buildTestableWidget(HomeScreen homeScreen) {
  return ChangeNotifierProvider(
    create: (_) => FavouriteProvider(),
    child: MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme()
      ),
      home: const HomeScreen(),
    ),
  );
}
