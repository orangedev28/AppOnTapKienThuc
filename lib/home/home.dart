import 'package:app_ontapkienthuc/aboutme/about_me.dart';
import 'package:app_ontapkienthuc/menu/menu.dart';
import 'package:app_ontapkienthuc/user/info.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  int selectedIndex = 0;
  Widget _home = MenuHome();
  Widget _myInfo = UserInfoWidget();
  Widget _aboutUs = AboutUs();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thoát ứng dụng'),
              content: Text('Có chắc bạn muốn thoát ứng dụng không?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Có'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Không'),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              label: "Tài Khoản",
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
      ),
    );
  }

  Widget getBody() {
    if (this.selectedIndex == 0) {
      return this._home;
    } else if (this.selectedIndex == 1) {
      return this._myInfo;
    } else {
      return this._aboutUs;
    }
  }

  void onTapHandler(int index) {
    this.setState(() {
      this.selectedIndex = index;
    });
  }
}
