import 'package:flutter/material.dart';
import 'package:bukidlink/Pages/LoginPage.dart';
import 'package:bukidlink/Pages/HomePage.dart';
import 'package:bukidlink/Pages/ProfilePage.dart';
import 'package:bukidlink/Pages/MessagePage.dart';
import 'package:bukidlink/pages/farmer/FarmerStorePage.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      // home: const LoginPage(),
      home:
          const FarmerStorePage(), // remove this line after testing or to access the farm store page directly
      routes: {
        // Add any simple, argument-free routes here
        // '/message': (context) => const MessagePage(),
      },

      // Dynamic route handler
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final args = settings.arguments;
          if (args is String) {
            return MaterialPageRoute(
              builder: (context) => ProfilePage(profileID: args),
            );
          } else {
            // Fallback for missing or invalid arguments
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Invalid or missing profile ID')),
              ),
            );
          }
        }

        // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
