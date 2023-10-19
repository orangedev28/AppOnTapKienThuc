import 'package:app_ontapkienthuc/aboutme/about_me.dart';
import 'package:app_ontapkienthuc/account/my_account.dart';
import 'package:app_ontapkienthuc/menuhome/menu.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  int selectedIndex = 0;
  Widget _home = MenuHome();
  Widget _myAccount = MyAccount();
  Widget _aboutMe = AboutMe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text(
          "App Ôn Tập Kiến Thức",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: this.selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Trang Chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Đăng Nhập",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Thông Tin",
          ),
        ],
        onTap: (int index) {
          this.onTapHandler(index);
        },
      ),
    );
  }

  Widget getBody() {
    if (this.selectedIndex == 0) {
      return this._home;
    } else if (this.selectedIndex == 1) {
      return this._myAccount;
    } else {
      return this._aboutMe;
    }
  }

  void onTapHandler(int index) {
    this.setState(() {
      this.selectedIndex = index;
    });
  }
}
