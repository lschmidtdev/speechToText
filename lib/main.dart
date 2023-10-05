import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:voice_notes_app/pages/auth_page/auth_page.dart';
import 'package:voice_notes_app/pages/home_page/home_page.dart';
import 'package:voice_notes_app/pages/speech_to_text/speech_to_text.dart';
import 'package:voice_notes_app/providers/authentication.dart';
import 'package:voice_notes_app/providers/notes/notes.dart';
import 'package:voice_notes_app/utils/widgets/custom_route_animation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.bottom,
    ],
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Authentication(),
        ),
        ChangeNotifierProxyProvider<Authentication, Notes>(
          update: (ctx, authData, previousNotes) => Notes(
            authData.token != null ? authData.token! : '',
            authData.userId != null ? authData.userId! : '',
            previousNotes!.notes,
          ),
          create: (ctx) => Notes('', '', []),
        ),
      ],
      child: Consumer<Authentication>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomRouteAnimation(),
              },
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
            ),
            textTheme: TextTheme(
              titleLarge: GoogleFonts.mavenPro(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              titleMedium: GoogleFonts.mavenPro(
                color: Colors.black,
                fontSize: 16,
              ),
              titleSmall: GoogleFonts.mavenPro(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          home: (authData.isAuthenticated)
              ? const HomePage()
              : FutureBuilder(
            future: authData.tryAutoLogin(),
            builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const AuthPage(),
          ),
          routes: {
            SpeechToTextPage.routeName: (context) =>
            const SpeechToTextPage(),
            HomePage.routeName: (context) => const HomePage(),
          },
        ),
      ),
    );
  }
}
