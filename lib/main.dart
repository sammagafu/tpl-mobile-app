import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure to import provider package
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/views/latest_page.dart';
import 'screens/views/pl_fantasy_page.dart';
import 'screens/views/stats_page.dart';
import 'screens/views/more_page.dart';
import 'screens/views/premierlegue.dart';
import 'providers/auth_provider.dart'; // Ensure you import your AuthProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanzania Football Fantasy',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkIsAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == true) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
      routes: {
        '/registration': (context) => const RegistrationPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        // '/pl': (context) => PremierLeagueDetail(matchdaydetail: ,),
      },
    );
  }

  Future<bool> _checkIsAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs
        .getString('authToken'); // Ensure this key matches your implementation
    return token != null; // Returns true if token is found, otherwise false
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key})
      : super(key: key); // Add a key parameter for const constructor

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    LatestPage(),
    PremierLeague(),
    PLFantasyPage(),
    StatsPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Tanzania Football Fantasy'),
      // ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_new),
            label: 'Latest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'PL',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Fantasy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
