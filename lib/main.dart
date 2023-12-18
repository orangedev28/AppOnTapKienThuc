import 'package:app_ontapkienthuc/login/login_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_ontapkienthuc/home/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: "App Ôn Tập Kiến Thức",
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? MyHomePage() : LoginAccount();
          },
        ),
      ),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  int _userId = 0;
  bool _isInitialRouteSet = false;

  bool get isLoggedIn => _isLoggedIn;
  int get userId => _userId;

  void setLoggedIn(int userId) {
    _isLoggedIn = userId != 0;
    _userId = userId;
    notifyListeners();
  }

  void setInitialRoute(bool isSet) {
    _isInitialRouteSet = isSet;
    notifyListeners();
  }

  bool isInitialRouteSet() {
    return _isInitialRouteSet;
  }
}
